//
//  OpenningVC.swift
//  BallShooter
//
//  Created by Dylan Gray on 2017-09-17.
//  Copyright © 2017 CodeGray. All rights reserved.
//

import UIKit

class OpenningVC: UIViewController {
    
    
    @IBAction func play(_ sender: UIButton) {
        let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "gameVC") as! GameViewController
        self.present(gameVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
