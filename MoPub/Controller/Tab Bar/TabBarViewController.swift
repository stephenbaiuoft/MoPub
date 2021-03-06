//
//  TabBarViewController.swift
//  MoPub
//
//  Created by stephen on 9/27/17.
//  Copyright © 2017 Bai Cloud AI Co. All rights reserved.
//

import UIKit
import Firebase

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("TabBarViewControlle Entered Here?")
        // Do any additional setup after loading the view.
    }

    @IBAction func logOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            // go back to Login
            performSegue(withIdentifier: Constant.VC.segueToLogin, sender: self)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.VC.segueToLogin {
            print("preparing to go back and setting value for loggedin ")
            UserDefaults.standard.set(false, forKey: "loggedin")
        }
    }
    
}
