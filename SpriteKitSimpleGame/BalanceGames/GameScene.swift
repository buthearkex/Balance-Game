//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Mikko on 31/12/2016.
//  Copyright © 2016 Mikko. All rights reserved.
//

struct CollisionCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Ball      : UInt32 = 0b1
    static let Circle    : UInt32 = 0b10
}

import CoreMotion
import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let circleRadius = 150
    
    let ball = SKSpriteNode(imageNamed: "ball")
    let circle = SKShapeNode(circleOfRadius: 150)
    
    var motionManager: CMMotionManager!
    var lastTouchPosition: CGPoint?
    
    var backButton = SKLabelNode(fontNamed: "Helvetica Neue UltraLight")
    
    override func didMove(to view: SKView) {

        backgroundColor = SKColor.gray
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        createCircle()
        createBall()
        
        backButton.text = "< Back to menu"
        backButton.fontColor = SKColor.black
        backButton.fontSize = 16
        backButton.position = CGPoint(x: 100, y: size.height - 50)
        addChild(backButton)
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    }
    
    private func createBall(){
        ball.position = CGPoint(x: size.width/2, y: size.height/2)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody!.allowsRotation = false
        ball.physicsBody!.linearDamping = 0.5
        
        ball.physicsBody!.categoryBitMask = CollisionCategory.Ball
        ball.physicsBody!.contactTestBitMask = CollisionCategory.Circle
        //ball.physicsBody!.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(ball)
    }
    
    private func createCircle(){
        circle.position = CGPoint(x: size.width/2, y: size.height/2)
        circle.strokeColor = SKColor.black
        circle.glowWidth = 1.0
        circle.fillColor = SKColor.gray
        addChild(circle)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
    
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
        
        if (checkPosition() == false){
            
            let gameOverScene = GameOverScene(fileNamed: "GameOverScene")
            let transition = SKTransition.fade(withDuration: 0.15)
            self.view!.presentScene(gameOverScene!, transition: transition)

        }
    }
    
    private func checkPosition() -> Bool{
        if (ball.position.x < size.width/2 - CGFloat(circleRadius) || ball.position.x > size.width/2 + CGFloat(circleRadius)){
            return false
        }
        if (ball.position.y < size.height/2 - CGFloat(circleRadius) || ball.position.y > size.height/2 + CGFloat(circleRadius)){
            return false
        }
        return true
    }
    
    
    ////////////////////////////////////////////////////////////////
    //////        TOUCH EVENTS                        //////////////
    ////////////////////////////////////////////////////////////////
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            lastTouchPosition = location
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
        if let touch = touches.first {
            if backButton.contains(touch.location(in: self)){
                let toMenu = StartMenu(fileNamed: "StartMenu")
                let transition = SKTransition.fade(withDuration: 0.15)
                self.view!.presentScene(toMenu!, transition: transition)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    

}
