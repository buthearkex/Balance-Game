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

    var continueLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-Medium")
    
    init(size: CGSize, points:Int) {
        
        super.init(size: size)
        
        backgroundColor = SKColor.white
        let pointsLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-Medium")
        //points.text = "You won!"
        pointsLabel.text = "You won with points: " + String(points) + " !"
        pointsLabel.fontSize = 40
        pointsLabel.fontColor = SKColor.black
        pointsLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(pointsLabel)
        
 
        continueLabel.text = "Back to main menu"
        continueLabel.fontSize = 20
        continueLabel.fontColor = SKColor.black
        continueLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
        addChild(continueLabel)
        
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
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) missing")
    }
}
