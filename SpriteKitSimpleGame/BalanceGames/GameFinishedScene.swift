//
//  GameFinishedScene.swift
//  SpriteKitSimpleGame
//
//  Created by Mikko on 05/01/2017.
//  Copyright © 2017 Mikko. All rights reserved.
//

import Foundation
import SpriteKit

class GameFinishedScene: SKScene {

    var continueLabel = SKLabelNode()
    var pointsLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        continueLabel = childNode(withName: "continueLabel") as! SKLabelNode
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if continueLabel.contains(touch.location(in: self)){
                let startMenu = StartMenu(fileNamed: "StartMenu")
                let transition = SKTransition.fade(withDuration: 0.15)
                self.view!.presentScene(startMenu!, transition: transition)
            }
        }
    }
}
