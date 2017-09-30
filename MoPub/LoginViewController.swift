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


class LoginViewController: UIViewController, FUIAuthDelegate  {
    
    // Outlet
    // Asynchronous Login
    @IBOutlet weak var nameField: UITextField!
    
    
    // Properties
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    // current user information
    var user: User? = nil
    var logOut: Bool = false
    var isInit: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
        FUIAuth.defaultAuthUI()?.delegate = self
        nameField.delegate = self
    }

    // MARK: View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let hold = UserDefaults.standard.bool(forKey: "loggedin")
        
        if UserDefaults.standard.bool(forKey: "loggedin") {
            // logged already ==> launch mapView
            print("User already logged in")
            performSegue(withIdentifier: Constant.VC.segueToMapView, sender: self)
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        // remove the listener
        // Auth.auth().removeStateDidChangeListener(_authHandle)
    }
    
     // Authenticatation Login Methods
    @IBAction func logInAuth(_ sender: AnyObject) {
        
        configureAuth()
        
//        // Set up listener only when the button is clicked
//        _authHandle = Auth.auth().addStateDidChangeListener { (auth: Auth, user: User?) in
//            // check if there is a current user
//            print (  " userGoogle: \(user?.displayName),  userDefault: \(self.user?.displayName)")
//
//            if let activeUser = user {
//                // switched account or new just logged in
//                if self.user != activeUser {
//                    self.user = activeUser
//                }
//            }
//
//            DispatchQueue.main.async {
//                let controller =
//                    self.storyboard?.instantiateViewController(withIdentifier: Constant.VC.segueToMapView) as! UINavigationController
//                self.present(controller, animated: true)
//            }
//
//        }
        
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
       print("preparing to go to mapView Controller")
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
    
    
    // Call back function from uiAuth
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let activeUser = user {
            self.user = activeUser
            print("Going to MapView Segue")
            UserDefaults.standard.set(true, forKey: "loggedin")
            performSegue(withIdentifier: Constant.VC.segueToMapView, sender: self)
        }
    }
    
}

// Keyboard
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
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
