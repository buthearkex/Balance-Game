//
//  GameViewController.swift
//  BalanceGame
//
//  Created by Mikko Honkanen on 31/12/2016.
//  Copyright © 2016 Mikko. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import MessageUI

class GameViewController: UIViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = StartMenu(fileNamed:"StartMenu") {
            let skView = self.view as! SKView

            skView.presentScene(scene)
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func sendEmail(text:String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            // please change the email addresses, if you're using the code :)
            mail.setToRecipients(["mikko.honkanen@campus.tu-berlin.de", "data@thomasfett.de", "d.delgado@campus.tu-berlin.de"])
            mail.setMessageBody(text, isHTML: true)
            
            present(mail, animated: true)
        } else {

        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
