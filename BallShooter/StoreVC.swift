//
//  StoreVC.swift
//  BallShooter
//
//  Created by Dylan Gray on 2017-09-24.
//  Copyright © 2017 CodeGray. All rights reserved.
//

import UIKit

class StoreVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    
    @IBAction func back(_ sender: Any) {
        let openVC = self.storyboard?.instantiateViewController(withIdentifier: "openVC") as! OpenningVC
        self.present(openVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.layer.cornerRadius = 10
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.white.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
