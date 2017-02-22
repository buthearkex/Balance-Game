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
import TremorTrackerFramework

class MazeGameScene: SKScene, SKPhysicsContactDelegate{
    
    var ball: SKSpriteNode!
    var elementWidth = 0
    var elementHeight = 0
    
    var motionManager: CMMotionManager!
    var lastTouchPosition: CGPoint?
    
    var isGameOver = false
    
    var backButton: SKLabelNode!
    var scoreLabel: SKLabelNode!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var logs = [String]()
    var tremorTracker: TremorTracker?
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 255,green: 246,blue: 217,alpha: 100)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        createMap()
        createPlayer()
        createInstructionsDialog()
        
        //block ball inside the screen borders
        let screenBorders = SKPhysicsBody(edgeLoopFrom: self.frame)
        screenBorders.friction = 0
        self.physicsBody = screenBorders
        
        // create label for showing the score
        scoreLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-Medium")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontColor = SKColor.black
        scoreLabel.fontSize = 20
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        addChild(scoreLabel)
        
        // create label for showing the back button
        backButton = SKLabelNode(fontNamed: "AppleSDGothicNeo-Medium")
        backButton.text = "< Back to menu"
        backButton.fontColor = SKColor.black
        backButton.fontSize = 16
        backButton.position = CGPoint(x: 80, y: size.height - 30)
        addChild(backButton)
    }
    
    private func createInstructionsDialog(){
        let button = UIButton(type: .system)
        button.setTitle("OK", for: .normal)
        button.addTarget(self, action: #selector(self.instructionsRead(_:)), for: .touchDown)
        button.sizeToFit()
        button.center = CGPoint(x: 100, y: 120)
        
        let textLabel = UILabel(frame: CGRect(x: 1, y: 1, width: 200, height: 200))
        textLabel.text = "You must collect all\nstars to finish!"
        textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        textLabel.numberOfLines = 3
        textLabel.center = CGPoint(x: 120, y: 50)
        
        
        let frame = CGRect(x: size.width / 2 - 100, y: size.height / 2 - 75, width: 200, height: 150)
        let view = UIView(frame: frame)
        view.tag = 100
        view.backgroundColor = SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        view.addSubview(textLabel)
        view.addSubview(button)
        self.view?.addSubview(view)
    }
    
    func instructionsRead(_ button: UIButton) {
        // remove dialog
        self.view!.viewWithTag(100)!.removeFromSuperview()
        
        //activate sensors
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        tremorTracker = TremorTracker(motionManager: motionManager)
        
        _ = tremorTracker?.startMeasuringSession{ (intermediateResults) in
            print(intermediateResults)
        }
        
        
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
                        
                        let position = CGPoint(x: (elementWidth * column) + 30, y: (elementHeight * row) + 10)
                        
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
        let node = SKSpriteNode(imageNamed: "flag")
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
        let trapTexture = SKTexture(imageNamed: "trap.png")
        let node = SKSpriteNode(texture: trapTexture)
        node.name = "trap"
        node.position = position
        //let node2 = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        let circularSpaceShip = SKSpriteNode(texture: trapTexture)
        node.physicsBody = SKPhysicsBody(texture: trapTexture, size: CGSize(width: circularSpaceShip.size.width, height: circularSpaceShip.size.height))
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
        if let motionManager = self.motionManager {
            if let accelerometerData = motionManager.accelerometerData {
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
                
                let toLog = String(accelerometerData.acceleration.x) + " " + String(accelerometerData.acceleration.y) + " " + String(accelerometerData.acceleration.z)
                logs.append(toLog)
            }
            
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
        if node.name == "trap" {
            ball.physicsBody!.isDynamic = false
            isGameOver = true
//            score -= 1
            
            let move = SKAction.move(to: node.position, duration: 0.1)
            let scale = SKAction.scale(to: 0.0001, duration: 0.1)
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
            if(score == 8){
                let finishScene = GameFinishedScene(fileNamed: "GameFinishedScene")
                let transition = SKTransition.fade(withDuration: 0.15)
                self.view!.presentScene(finishScene!, transition: transition)
                
                print(logs)
                logs = [String]()
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////
    //////                  TOUCH EVENTS              //////////////
    ////////////////////////////////////////////////////////////////
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            lastTouchPosition = location
            
//            if scoreLabel.contains(touch.location(in: self)){
//                let startMenu = StartMenu(size: view!.bounds.size)
//                let transition = SKTransition.fade(withDuration: 0.15)
//                self.view!.presentScene(startMenu, transition: transition)
//            }
            if let instructions = self.view?.viewWithTag(100){
                instructions.removeFromSuperview()
            }
            if backButton.contains(touch.location(in: self)){
                
                let toMenu = StartMenu(fileNamed: "StartMenu")
                let transition = SKTransition.fade(withDuration: 0.15)
                self.view!.presentScene(toMenu!, transition: transition)
                
                print(logs)
                
                let file = String(NSDate().timeIntervalSince1970) + ".txt" //this is the file. we will write to and read from it
                
                let text = logs.joined(separator: "-")
                
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    
                    let path = dir.appendingPathComponent(file)
                    
                    //writing
                    do {
                        try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
                    }
                    catch {
                        // errors here
                        
                    }
                    
                }
                
                logs = [String]()
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
