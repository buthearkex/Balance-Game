//
//  GameOverScene.swift
//  SpriteKitSimpleGame
//
//  Created by Mikko on 01/01/2017.
//  Copyright © 2017 Mikko. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    var newGameLabel = SKLabelNode()
    var toMenuLabel = SKLabelNode()
    
    
    override func didMove(to view: SKView) {
        
        newGameLabel = childNode(withName: "newGameLabel") as! SKLabelNode
        toMenuLabel = childNode(withName: "toMenuLabel") as! SKLabelNode
    
    }
//    override init(size: CGSize) {
//        
//        super.init(size: size)
//        
//        backgroundColor = SKColor.white
//        
//        newGameLabel = childNode(withName: "newGameLabel") as! SKLabelNode
//        toMenuLabel = childNode(withName: "toMenuLabel") as! SKLabelNode
//        
////        let label = SKLabelNode(fontNamed: "AppleSDGothicNeo-Medium")
////        label.text = "Game over"
////        label.fontSize = 40
////        label.fontColor = SKColor.black
////        label.position = CGPoint(x: size.width/2, y: size.height/2)
////        addChild(label)
//        
////        newGameLabel.text = "Start again"
////        newGameLabel.fontSize = 20
////        newGameLabel.fontColor = SKColor.black
////        newGameLabel.position = CGPoint(x: size.width/2 - 100, y: size.height/2 - 100)
////        addChild(newGameLabel)
////        
////        toMenuLabel.text = "Back to menu"
////        toMenuLabel.fontSize = 20
////        toMenuLabel.fontColor = SKColor.black
////        toMenuLabel.position = CGPoint(x: size.width/2 + 100, y: size.height/2 - 100)
////        addChild(toMenuLabel)
//        
//    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if newGameLabel.contains(touch.location(in: self)){
                let newGame = GameScene(size: view!.bounds.size)
                let transition = SKTransition.fade(withDuration: 0.15)
                self.view!.presentScene(newGame, transition: transition)
            }
            if toMenuLabel.contains(touch.location(in: self)){
                
                let toMenu = StartMenu(fileNamed: "StartMenu")
                let transition = SKTransition.fade(withDuration: 0.15)
                self.view!.presentScene(toMenu!, transition: transition)
            }
        }
    }
    
}
