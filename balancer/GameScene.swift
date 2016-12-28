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
enum CollisionObjects:UInt32 {
    case player = 1
    case circle = 2
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
        
        physicsWorld.contactDelegate = self
        
        createPlayer()
        
        createCircle()
        
        //removing the gravity from the player
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
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
        
        /*for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
             
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }*/
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if let accelerometerData = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
    }

    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "SKSpriteNode")
        player.position = CGPoint(x: 500, y: 672)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody!.allowsRotation = false
        player.physicsBody!.linearDamping = 0.5
        
        /*player.physicsBody!.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody!.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue*/
        player.physicsBody!.categoryBitMask = 1
        player.physicsBody!.contactTestBitMask = 2
        player.physicsBody!.collisionBitMask = 2
        addChild(player)
    }
    
    func createCircle(){
        let circle = SKShapeNode(circleOfRadius: 300 )
        circle.position = CGPointMake(frame.midX, frame.midY)
        circle.strokeColor = SKColor.blackColor()
        
        
        // if you want the circle to start moving add this
        circle.physicsBody = SKPhysicsBody(circleOfRadius: 300)
        circle.physicsBody!.categoryBitMask = 2
        circle.physicsBody!.contactTestBitMask = 1
        circle.physicsBody!.collisionBitMask = 1
        self.addChild(circle)
    }
    
    
    func didBegin(contact: SKPhysicsContact) {
        print("hey")
        print(contact.bodyA.node?.name)
        
        //if contact.bodyA.node?.name == "ball" {
        //    collisionBetween(ball: contact.bodyA.node!, object: contact.bodyB.node!)
        //}
    }
    
    
}
