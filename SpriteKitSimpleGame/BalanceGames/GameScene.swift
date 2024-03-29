//
//  GameScene.swift
//  BalanceGame
//
//  Created by Mikko Honkanen on 31/12/2016.
//  Copyright © 2016 Mikko. All rights reserved.
//

// set the different object types
struct CollisionCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Ball      : UInt32 = 0b1
    static let Circle    : UInt32 = 0b10
}

import CoreMotion
import SpriteKit
import GameplayKit
import TremorTrackerFramework


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // size of the circle the player has to stay inside
    let circleRadius = 150
    
    let ball = SKSpriteNode(imageNamed: "ball")
    let circle = SKShapeNode(circleOfRadius: 150)
    
    var motionManager: CMMotionManager!
    var touchedPoint: CGPoint?
    
    var backButton = SKLabelNode(fontNamed: "Helvetica Neue UltraLight")
    
    var tremorTracker:TremorTracker?
    
    override func didMove(to view: SKView) {

        backgroundColor = SKColor.gray
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        createCircle()
        createBall()
        createInstructionsDialog()
        
        // create back button
        backButton.text = "< Back to menu"
        backButton.fontColor = SKColor.black
        backButton.fontSize = 16
        backButton.position = CGPoint(x: 100, y: size.height - 50)
        addChild(backButton)
        
    }
    
    private func createInstructionsDialog(){
        let button = UIButton(type: .system)
        button.setTitle("OK", for: .normal)
        // this only activates sensors if the ok-button is hit, not something outside of it
        button.addTarget(self, action: #selector(self.instructionsRead(_:)), for: .touchDown)
        button.sizeToFit()
        button.center = CGPoint(x: 100, y: 120)
        
        let textLabel = UILabel(frame: CGRect(x: 1, y: 1, width: 200, height: 200))
        textLabel.text = "Stay inside the circle\nas long as you can!"
        textLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        textLabel.numberOfLines = 3
        textLabel.center = CGPoint(x: 120, y: 50)
        
        let frame = CGRect(x: size.width / 2 - 100, y: size.height / 2 - 75, width: 200, height: 150)
        let view = UIView(frame: frame)
        view.tag = 100
        view.backgroundColor = SKColor.white
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
        
        // add tracking
        tremorTracker = TremorTracker(motionManager: motionManager)
        
        tremorTracker?.startMeasuringSession(callback: nil)
    }
    
    private func createBall(){
        ball.position = CGPoint(x: size.width/2, y: size.height/2)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody!.allowsRotation = false
        ball.physicsBody!.linearDamping = 0.5
        
        ball.physicsBody!.categoryBitMask = CollisionCategory.Ball
        ball.physicsBody!.contactTestBitMask = CollisionCategory.Circle
        addChild(ball)
    }
    
    private func createCircle(){
        circle.position = CGPoint(x: size.width/2, y: size.height/2)
        circle.strokeColor = SKColor.black
        circle.glowWidth = 1.0
        circle.fillColor = SKColor.gray
        addChild(circle)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // if using emulator, touches are used to move the ball
        #if (arch(i386) || arch(x86_64))
            if let currentTouch = touchedPoint {
                let diff = CGPoint(x: currentTouch.x - ball.position.x, y: currentTouch.y - ball.position.y)
                physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
            }
        #else
        if let motionManager = self.motionManager {
            if let accelerometerData = motionManager.accelerometerData {
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
            }
        }
        #endif
        
        if (checkPosition() == false){
            
            // send data as email
            tremorTracker?.stopMeasuringSession()
            let result = "CircleGame " + tremorTracker!.getCSVStringFromSessionData()
            let gameOverScene = GameOverScene(fileNamed: "GameOverScene")
            gameOverScene?.userData = NSMutableDictionary()
            gameOverScene?.userData?.setValue(result, forKey: "resultcsv")
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
            touchedPoint = location
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            touchedPoint = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchedPoint = nil
        if let touch = touches.first {
            if backButton.contains(touch.location(in: self)){
                if let instructions = self.view?.viewWithTag(100){
                    instructions.removeFromSuperview()
                }
                
                // send data as email
                let result = "CircleGame " + tremorTracker!.getCSVStringFromSessionData()
                let toMenu = StartMenu(fileNamed: "StartMenu")
                toMenu?.userData = NSMutableDictionary()
                toMenu?.userData?.setValue(result, forKey: "resultcsv")
                
                let transition = SKTransition.fade(withDuration: 0.15)
                self.view!.presentScene(toMenu!, transition: transition)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        touchedPoint = nil
    }
}

