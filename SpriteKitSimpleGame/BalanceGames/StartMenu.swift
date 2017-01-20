//
//  StartMenu.swift
//  SpriteKitSimpleGame
//
//  Created by Mikko on 01/01/2017.
//  Copyright © 2017 Mikko. All rights reserved.
//

import Foundation
import SpriteKit

class StartMenu: SKScene {
    
    let headerFontSize = CGFloat(40)
    
//    let startMazeButton = SKLabelNode(fontNamed: "AppleSDGothicNeo-Medium")
    
    var startCircleButton = SKLabelNode()
    var startMazeButton = SKLabelNode()
    
    
//    player = self.childNodeWithName("player") as? SKSpriteNode
    
    override func didMove(to view: SKView) {
        //backgroundColor = SKColor.white
        //addButtons()
        //let start = StartMenu(size: view.bounds.size)
        //self.view?.presentScene(start)
        startCircleButton = childNode(withName: "startCircleButton") as! SKLabelNode
        startMazeButton = childNode(withName: "startMazeButton") as! SKLabelNode
    }
    
    
    
//    private func addButtons(){
//        let label = SKLabelNode(fontNamed: "AppleSDGothicNeo-Medium")
//        label.text = "Welcome to the balance games!"
//        label.fontSize = headerFontSize
//        label.fontColor = SKColor.black
//        label.position = CGPoint(x: size.width/2, y: size.height/3 * 2)
//        addChild(label)
//        
//        let typeLabel = SKLabelNode(fontNamed: "AppleSDGothicNeo-Medium")
//        typeLabel.text = "Select a game type:"
//        typeLabel.fontSize = headerFontSize / 2
//        typeLabel.fontColor = SKColor.black
//        typeLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
//        addChild(typeLabel)
//        
//        startCircleButton.text = "Circle Game"
//        startCircleButton.fontSize = headerFontSize / 3
//        startCircleButton.fontColor = SKColor.darkGray
//        startCircleButton.position = CGPoint(x: size.width/2 - 100, y: size.height/2 - 50)
//        addChild(startCircleButton)
//        
//        startMazeButton.text = "Maze Game"
//        startMazeButton.fontSize = headerFontSize / 3
//        startMazeButton.fontColor = SKColor.darkGray
//        startMazeButton.position = CGPoint(x: size.width/2 + 100, y: size.height/2 - 50)
//        addChild(startMazeButton)
//    }
    
    private func startMazeGame(){
        let gameScene = MazeGameScene(size: view!.bounds.size)
        let transition = SKTransition.fade(withDuration: 0.15)
        self.view!.presentScene(gameScene, transition: transition)
    }
    
    private func startCircleGame(){
        let gameScene = GameScene(size: view!.bounds.size)
        let transition = SKTransition.fade(withDuration: 0.15)
        self.view!.presentScene(gameScene, transition: transition)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches{
            let location = touch.location(in: self)
            if startMazeButton.contains(location){
                startMazeGame()
            }
            if startCircleButton.contains(location){
                startCircleGame()
            }
        }
    }

}
