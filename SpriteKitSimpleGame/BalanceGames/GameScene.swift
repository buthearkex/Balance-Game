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
import TremorTrackerFramework


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let circleRadius = 150
    
    let ball = SKSpriteNode(imageNamed: "ball")
    let circle = SKShapeNode(circleOfRadius: 150)
    
    var motionManager: CMMotionManager!
    var lastTouchPosition: CGPoint?
    
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
        // old implementation
        motionManager.startAccelerometerUpdates()
        
        // add tracking
        tremorTracker = TremorTracker(motionManager: motionManager)
        
        tremorTracker?.startMeasuringSession(callback: nil)
        
        //new implementation
//        if motionManager.isAccelerometerAvailable {
//            motionManager.accelerometerUpdateInterval = 0.01
//            motionManager.startAccelerometerUpdates(to: OperationQueue.main) {
//                [weak self] (data: CMAccelerometerData?, error: Error?) in
//                if let acceleration = data?.acceleration {
//                    print(NSDate().timeIntervalSince1970)
//                    //let rotation = atan2(acceleration.x, acceleration.y) - M_PI
//                    //self?.imageView.transform = CGAffineTransform(rotationAngle: rotation)
//                }
//            }
//        }
        
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
        #if (arch(i386) || arch(x86_64))
            if let currentTouch = lastTouchPosition {
                let diff = CGPoint(x: currentTouch.x - ball.position.x, y: currentTouch.y - ball.position.y)
                physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
                // for debugging
                print(CGVector(dx: diff.x / 100, dy: diff.y / 100))
            }
        #else
        
        if let motionManager = self.motionManager {
            if let accelerometerData = motionManager.accelerometerData {
//                print(acceleromaterData)
                physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
            }
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
                if let instructions = self.view?.viewWithTag(100){
                    instructions.removeFromSuperview()
                }
                
                let toMenu = StartMenu(fileNamed: "StartMenu")
                let transition = SKTransition.fade(withDuration: 0.15)
                self.view!.presentScene(toMenu!, transition: transition)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    
    // stuff for saving csv formatted accelerator data
//    var dataDump = [(String, String, String)]()
//    let filepath = ""
//    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//    var lastOp: CSVDumpOperation?
//    
//    func addDataTuple(accelerometerData: (String, String, String)) {
//        dataDump.append(accelerometerData)
//        
//        if dataDump.count >= 300 {
//            let toBeDump = dataDump
//            dataDump = [(String, String, String)]()
//            dumpArray(data: toBeDump)
//        }
//    }
//    
//    func dumpArray(data: [(String, String, String)]!) {
//        let op = CSVDumpOperation(file: paths, data: data)
//        if lastOp != nil && !lastOp!.isFinished {
//            op.addDependency(lastOp!)
//        }
//        lastOp = op
//        // how should this work?
////        dumpQueue.addOperation(op)
//    }
}


//directly copied from http://www.mydrivesolutions.com/engineering/swift-data-collection/
//class CSVDumpOperation: Operation {
//    
//    let data = [(String, String, String)]()
//    let os : OutputStream
//    
//    init(file: String, data: [(String, String, String)]) {
//        os = OutputStream(toFileAtPath: file, append: true)!
//        os.open()
//        
//        super.init()
//        
//        self.data = data
//    }
//    
//    override func main() {
//        for row in data {
//            let rowStr = "(row.x),(row.y),(row.z)...n"
//            if let rowData = rowStr.data(using: String.Encoding.utf8, allowLossyConversion: false) {
//                let bytes = UnsafePointer<UInt8>(rowData.bytes)
//                os.write(bytes, maxLength: rowData.length)
//            }
//        }
//        
//        os.close()
//    }
//}
