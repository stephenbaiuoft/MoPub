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


class LoginViewController: UIViewController  {
    
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
        
        _authHandle = Auth.auth().addStateDidChangeListener({ (auth: Auth, user: User?) in
            if self.user == nil {
                
            }
            else if let activeUser = user   {
                self.user = activeUser
                print("Current User Exists, lets go to MapView")
                
                self.performSegue(withIdentifier: Constant.VC.segueToMapView, sender: self)
            }
            else {
                // sign in
            }
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
        // remove the listener
        Auth.auth().removeStateDidChangeListener(_authHandle)
        
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
                self.performSegue(withIdentifier: Constant.VC.segueToMapView, sender: self)
            }
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.VC.segueToHostEvent{
            let hostVC = segue.destination as! HostEventViewController // 1
            hostVC.user = user!
            print("hosting user is \(user!)")
        }
    }
    
    
}

// Methods for Firebase Helper Functions
extension LoginViewController {
    
    func configureAuth() {
        let providerList: [FUIAuthProvider ] = [FUIGoogleAuth()]
        FUIAuth.defaultAuthUI()?.providers = providerList
        self.loginSession()
        
    }
    
    // Display the FireBaseUI Components
    func loginSession() {
        let authViewController = FUIAuth.defaultAuthUI()?.authViewController()
        present(authViewController!, animated: true, completion: nil)
    }
}

// Keyboard
extension LoginViewController {
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
