//
//  GameOverScene.swift
//  BalanceGame
//
//  Created by Mikko Honkanen on 01/01/2017.
//  Copyright © 2017 Mikko. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    var newGameLabel = SKLabelNode()
    var toMenuLabel = SKLabelNode()
    var uploadButton = SKLabelNode()
    
    
    override func didMove(to view: SKView) {
        newGameLabel = childNode(withName: "newGameLabel") as! SKLabelNode
        toMenuLabel = childNode(withName: "toMenuLabel") as! SKLabelNode
        uploadButton = childNode(withName: "uploadButton") as! SKLabelNode
    }
    
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
            if uploadButton.contains(touch.location(in: self)){
                let gvc:GameViewController = UIApplication.shared.keyWindow?.rootViewController as! GameViewController
                gvc.sendEmail(text: self.userData?.object(forKey: "resultcsv") as! String)
            }
        }
    }
    
}
