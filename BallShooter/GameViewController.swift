//
//  GameViewController.swift
//  BallShooter
//
//  Created by Dylan Gray on 2017-09-15.
//  Copyright © 2017 CodeGray. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var mode:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.backgroundColor = SKColor(red: (113/255), green: (114/255), blue: (164/255), alpha: 1.0)
                scene.viewController = self
                scene.mode = mode
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            //view.showsFPS = true
            //view.showsNodeCount = true
            //view.showsPhysics = true
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
    
    func transitionToGameOver(score: Int) {
        let gameOverVC = storyboard?.instantiateViewController(withIdentifier: "gameOverVC") as! GameOverVC
        gameOverVC.score = score
        present(gameOverVC, animated: true, completion: nil)
    }
}
