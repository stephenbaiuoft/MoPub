//
//  ViewController.swift
//  MoPub
//
//  Created by stephen on 9/21/17.
//  Copyright © 2017 Bai Cloud AI Co. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI


class MainViewController: UIViewController  {
    
    // Outlet
    @IBOutlet weak var loginButton: UIButton!
    
    
    // Properties
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    // current user information
    var user: User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    @IBAction func logInPressed() {
        // set up the configure?
        configureAuth()
    }
    
}

// Methods for Firebase Helper Functions
extension MainViewController {
    
    func configureAuth() {
        let providerList: [FUIAuthProvider ] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = providerList
        
        _authHandle = Auth.auth().addStateDidChangeListener({ (auth: Auth, user: User?) in
            
            if let activeUser = user {
                
                self.user = activeUser
                let name = user!.email!.components(separatedBy: "@")[0]
                
                print("Is Sign in!")
            }
            else {
                // sign in
                self.loginSession()
            }
            
        })
        
    }
    
    func loginSession() {
        let authViewController = FUIAuth.defaultAuthUI()?.authViewController()
        present(authViewController!, animated: false, completion: nil)
        
    }
}
