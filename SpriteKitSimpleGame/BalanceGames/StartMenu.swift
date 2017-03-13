//
//  StartMenu.swift
//  BalanceGame
//
//  Created by Mikko Honkanen on 01/01/2017.
//  Copyright © 2017 Mikko. All rights reserved.
//

import Foundation
import SpriteKit

class StartMenu: SKScene {
    
    let headerFontSize = CGFloat(40)
    
    var startCircleButton = SKLabelNode()
    var startMazeButton = SKLabelNode()
    var uploadData = SKLabelNode()
    
    override func didMove(to view: SKView) {
        startCircleButton = childNode(withName: "startCircleButton") as! SKLabelNode
        startMazeButton = childNode(withName: "startMazeButton") as! SKLabelNode
        uploadData = childNode(withName: "uploadData") as! SKLabelNode
    }
    
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
    
    private func sendEmail(){
        let gvc:GameViewController = UIApplication.shared.keyWindow?.rootViewController as! GameViewController
        if let userData = self.userData{
            gvc.sendEmail(text: userData.object(forKey: "resultcsv") as! String)
        }
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
            if uploadData.contains(location){
                sendEmail()
            }
        }
    }

}
