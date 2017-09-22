//
//  GameOverVC.swift
//  BallShooter
//
//  Created by Dylan Gray on 2017-09-22.
//  Copyright © 2017 CodeGray. All rights reserved.
//

import UIKit

class GameOverVC: UIViewController {

    var score:Int!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBAction func `continue`(_ sender: UIButton) {
        let openVC = self.storyboard?.instantiateViewController(withIdentifier: "openVC") as! OpenningVC
        self.present(openVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scoreLabel.text = "Score: \(score!)"
        
        continueButton.layer.cornerRadius = 10
        continueButton.layer.borderWidth = 1
        continueButton.layer.borderColor = UIColor.white.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
