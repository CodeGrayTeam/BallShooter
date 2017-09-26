//
//  OpenningVC.swift
//  BallShooter
//
//  Created by Dylan Gray on 2017-09-17.
//  Copyright © 2017 CodeGray. All rights reserved.
//

import UIKit

class OpenningVC: UIViewController {
    
    @IBAction func gameModes(_ sender: UIButton) {
        let gameModeVC = self.storyboard?.instantiateViewController(withIdentifier: "gameModeVC") as! GameModeVC
        self.present(gameModeVC, animated: true, completion: nil)
    }
    
    @IBAction func store(_ sender: UIButton) {
        let storeVC = self.storyboard?.instantiateViewController(withIdentifier: "storeVC") as! StoreVC
        self.present(storeVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
