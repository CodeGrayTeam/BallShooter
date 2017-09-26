//
//  GameModeVC.swift
//  BallShooter
//
//  Created by Dylan Gray on 2017-09-24.
//  Copyright © 2017 CodeGray. All rights reserved.
//

import UIKit

class GameModeVC: UIViewController {

    //Properties
    @IBOutlet weak var normalHighScore: UILabel!
    @IBOutlet weak var reversedHighScore: UILabel!
    @IBOutlet weak var bombDropHighScore: UILabel!
    @IBOutlet weak var normalButton: UIButton!
    @IBOutlet weak var reversedButton: UIButton!
    @IBOutlet weak var bombDropButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    //Actions
    @IBAction func normalGame(_ sender: UIButton) {
        let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "gameVC") as! GameViewController
        gameVC.mode = "normal"
        self.present(gameVC, animated: true, completion: nil)
    }
    
    @IBAction func reversedGame(_ sender: UIButton) {
        let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "gameVC") as! GameViewController
        gameVC.mode = "reversed"
        self.present(gameVC, animated: true, completion: nil)
    }
    
    @IBAction func bombDropGame(_ sender: UIButton) {
        let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "gameVC") as! GameViewController
        gameVC.mode = "bombDrop"
        self.present(gameVC, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        let openVC = self.storyboard?.instantiateViewController(withIdentifier: "openVC") as! OpenningVC
        self.present(openVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        normalHighScore.text = "Best: \(defaults.object(forKey: "normalHighScore") as? Int ?? 0)"
        reversedHighScore.text = "Best: \(defaults.object(forKey: "reversedHighScore") as? Int ?? 0)"
        bombDropHighScore.text = "Best: \(defaults.object(forKey: "bombDropHighScore") as? Int ?? 0)"
        
        normalButton.layer.cornerRadius = 10
        normalButton.layer.borderWidth = 1
        normalButton.layer.borderColor = UIColor.white.cgColor
        
        reversedButton.layer.cornerRadius = 10
        reversedButton.layer.borderWidth = 1
        reversedButton.layer.borderColor = UIColor.white.cgColor
        
        bombDropButton.layer.cornerRadius = 10
        bombDropButton.layer.borderWidth = 1
        bombDropButton.layer.borderColor = UIColor.white.cgColor
        
        backButton.layer.cornerRadius = 10
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.white.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
