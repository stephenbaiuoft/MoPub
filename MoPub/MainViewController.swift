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
    // Asynchronous Login
    @IBOutlet weak var nameField: UITextField!
    
    
    // Properties
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    // current user information
    var user: User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    // MARK: View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // Authenticatation Login Methods
    @IBAction func logInAuth(_ sender: AnyObject) {
        // set up the configure?
        configureAuth()
    }
    
    // Asynchronous Login
    @IBAction func logInAsync(_ sender: AnyObject) {
        if nameField?.text != "" {
            Auth.auth().signInAnonymously { (user, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return
                }
                // store the user variable
                self.user = user
                
                // go to Segue
                print("Going to MapView Segue")
            }
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//        let navVc = segue.destination as! UINavigationController // 1
//        let channelVc = navVc.viewControllers.first as! ChannelListViewController // 2
//
//        channelVc.senderDisplayName = nameField?.text // 3
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
                let emailName = user!.email!.components(separatedBy: "@")[0]
                print("\(emailName) is Sign in!")
                print("Going to MapView Segue")
                
            }
            else {
                // sign in
                self.loginSession()
            }
        })
        
    }
    
    // Display the FireBaseUI Components
    func loginSession() {
        let authViewController = FUIAuth.defaultAuthUI()?.authViewController()
        present(authViewController!, animated: false, completion: nil)
    }
}

// Keyboard
extension MainViewController {
    @objc func keyboardWillShow(_ notification:Notification) {
        let keyboardHeight = getKeyboardHeight(notification)
        // shifting upwards, from 0 to keybaord height
        view.frame.origin.y = -keyboardHeight
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
}
