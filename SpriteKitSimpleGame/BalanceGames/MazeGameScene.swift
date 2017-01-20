//
//  MazeGameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Mikko on 01/01/2017.
//  Copyright © 2017 Mikko. All rights reserved.
//
enum CollisionTypes: UInt32 {
    case ball = 1
    case wall = 2
    case star = 4
    case hole = 8
    case goal = 16
}

import Foundation
import CoreMotion
import SpriteKit

class MazeGameScene: SKScene, SKPhysicsContactDelegate{
    
    var ball: SKSpriteNode!
    var elementWidth = 0
    var elementHeight = 0
    
    var motionManager: CMMotionManager!
    var lastTouchPosition: CGPoint?
    
    var isGameOver = false
    
    var scoreLabel: SKLabelNode!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 255,green: 246,blue: 217,alpha: 100)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        createMap()
        createPlayer()
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        let screenBorders = SKPhysicsBody(edgeLoopFrom: self.frame)
        screenBorders.friction = 0
        self.physicsBody = screenBorders
        
        
        scoreLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-Medium")
        scoreLabel.name = "backbutton"
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        addChild(scoreLabel)
    }
    
    private func createMap(){
        
        if let path = Bundle.main.path(forResource: "level1", ofType: "txt") {
            
            if let mapString = try? String(contentsOfFile: path) {
                let lines = mapString.components(separatedBy: "\n")
                
                for (row, line) in lines.reversed().enumerated() {
                    for (column, letter) in line.characters.enumerated() {
                        
                        //width should be width/numberOfElementsHorizontally
                        elementWidth = Int(size.width) / line.characters.count
                        //height should be height/numberOfElements
                        elementHeight = Int(size.height) / lines.count
                        
                        let position = CGPoint(x: (elementWidth * column) + 10, y: (elementHeight * row) + 10)
                        
                        if letter == "x" {
                            createWall(position: position)
                        } else if letter == "v"  {
                            createHole(position: position)
                        } else if letter == "s"  {
                            createStar(position: position)
                        } else if letter == "f"  {
                            createGoal(position: position)
                        }
                    }
                }
            }
        }
    }
    
    private func createGoal(position:CGPoint){
        let node = SKSpriteNode(imageNamed: "flag white-1")
        node.name = "finish"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody!.isDynamic = false
        node.scale(to: CGSize(width: elementWidth, height: elementWidth))
        node.physicsBody!.categoryBitMask = CollisionTypes.goal.rawValue
        node.physicsBody!.contactTestBitMask = CollisionTypes.ball.rawValue
        node.physicsBody!.collisionBitMask = 0
        node.position = position
        addChild(node)
    }
    
    private func createStar(position: CGPoint){
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody!.isDynamic = false
        node.setScale(0.5)
        node.physicsBody!.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody!.contactTestBitMask = CollisionTypes.ball.rawValue
        node.physicsBody!.collisionBitMask = 0
        node.position = position
        addChild(node)
    }
    
    private func createWall(position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "wall")
        node.position = position
        node.scale(to: CGSize(width: elementWidth, height: elementHeight))
        
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody!.categoryBitMask = CollisionTypes.wall.rawValue
        node.physicsBody!.isDynamic = false
        addChild(node)
    }
    
    private func createHole(position: CGPoint){
        let node = SKSpriteNode(imageNamed: "trap")
        node.name = "vortex"
        node.position = position
        //node.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi, duration: 1)))
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.setScale(0.2)
        node.physicsBody!.isDynamic = false
        
        node.physicsBody!.categoryBitMask = CollisionTypes.hole.rawValue
        node.physicsBody!.contactTestBitMask = CollisionTypes.ball.rawValue
        node.physicsBody!.collisionBitMask = 0
        addChild(node)
    }
    
    private func createPlayer() {
        ball = SKSpriteNode(imageNamed: "ball")
        ball.position = CGPoint(x: size.width/2, y: size.height/2)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody!.allowsRotation = false
        ball.physicsBody!.linearDamping = 0.5
        ball.scale(to: CGSize(width: elementWidth / 2, height: elementWidth / 2))
        
        ball.physicsBody!.categoryBitMask = CollisionTypes.ball.rawValue
        ball.physicsBody!.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.hole.rawValue | CollisionTypes.goal.rawValue
        ball.physicsBody!.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(ball)
    }
    
    override func update(_ currentTime: TimeInterval) {
        #if (arch(i386) || arch(x86_64))
            if let currentTouch = lastTouchPosition {
                let diff = CGPoint(x: currentTouch.x - ball.position.x, y: currentTouch.y - ball.position.y)
                physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
            }
        #else
            if let accelerometerData = motionManager.accelerometerData {
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
            }
        #endif
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node == ball {
            ballCollided(with: contact.bodyB.node!)
        } else if contact.bodyB.node == ball {
            ballCollided(with: contact.bodyA.node!)
        }
    }
    
    func ballCollided(with node: SKNode) {
        if node.name == "vortex" {
            ball.physicsBody!.isDynamic = false
            isGameOver = true
            score -= 1
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            ball.run(sequence) { [unowned self] in
                self.createPlayer()
                self.isGameOver = false
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            let finishScene = GameFinishedScene(size: self.size , points: score)
            let transition = SKTransition.fade(withDuration: 0.15)
            self.view!.presentScene(finishScene, transition: transition)
        }
    }
    
    ////////////////////////////////////////////////////////////////
    //////                  TOUCH EVENTS              //////////////
    ////////////////////////////////////////////////////////////////
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            lastTouchPosition = location
            
            if scoreLabel.contains(touch.location(in: self)){
                let startMenu = StartMenu(size: view!.bounds.size)
                let transition = SKTransition.fade(withDuration: 0.15)
                self.view!.presentScene(startMenu, transition: transition)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            lastTouchPosition = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        lastTouchPosition = nil
    }
}
