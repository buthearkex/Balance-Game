//
//  GameScene.swift
//  balancer
//
//  Created by Mikko on 13/12/2016.
//  Copyright (c) 2016 Mikko. All rights reserved.
//

import CoreMotion
import SpriteKit


//Different collision types in the game
enum CollisionTypes:UInt32 {
    case player = 1
    case circle = 2
    case test = 4
    // next on ewould be 4 and 8
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var motionManager: CMMotionManager!
    var player: SKSpriteNode!
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        /*let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Balancer"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))*/
        
        
        //self.addChild(myLabel)
        
        
        createPlayer()
        
        createCircle()
        
        //removing the gravity from the player
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        //set delegate to take care of the collisiions
        physicsWorld.contactDelegate = self
        
        //start the sensors
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
        // set bounding box to the screen
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if let accelerometerData = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
    }

    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "SKSpriteNode")
        player.position = CGPoint(x: 100, y: 100)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody!.allowsRotation = false
        player.physicsBody!.linearDamping = 0.5
        
        player.physicsBody!.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody!.contactTestBitMask = CollisionTypes.circle.rawValue
        player.physicsBody!.collisionBitMask = CollisionTypes.test.rawValue
        addChild(player)
    }
    
    func createCircle(){
        let circle = SKShapeNode(circleOfRadius: 100 )
        circle.position = CGPointMake(frame.midX, frame.midY)
        circle.strokeColor = SKColor.blackColor()
        
        
        // if you want the circle to start moving add this
        circle.physicsBody = SKPhysicsBody(circleOfRadius: 100)
        circle.physicsBody!.categoryBitMask = CollisionTypes.circle.rawValue
        circle.physicsBody!.contactTestBitMask = CollisionTypes.player.rawValue
        circle.physicsBody!.collisionBitMask = CollisionTypes.test.rawValue
        circle.physicsBody?.dynamic = false
        self.addChild(circle)
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        player.removeFromParent()
        createPlayer()
        print("noin")
    }
    
    
}
