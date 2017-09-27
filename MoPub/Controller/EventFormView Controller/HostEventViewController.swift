//
//  HostEventViewController.swift
//  MoPub
//
//  Created by stephen on 9/26/17.
//  Copyright © 2017 Bai Cloud AI Co. All rights reserved.
//

import UIKit
import MapKit
import Firebase

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class HostEventViewController: UIViewController {
    
    // MARK: IBOutlets
    // Location Search!
    
    @IBOutlet weak var placeHolderView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var partySize: UITextField!
    @IBOutlet weak var eventKeyWords: UITextField!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var hostButton: UIButton!
    
    
    // MARK: FireBase properties
    // lazy ==> channelRef is instantiated ONLY when this property is accessed
    var user: User? = nil
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    // channelRefHandle: listen & observe
    private var channelRefHandle: DatabaseHandle?
    
    // MARK: Properties
    let locationManager = CLLocationManager()
    var locationSearchTable: LocationSearchTableVC!
    var searchBar: UISearchBar!
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // textField
        eventTitle.delegate = self
        partySize.delegate = self
        eventKeyWords.delegate = self
        eventDescription.delegate = self
        
        // location configuration
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        // Set up resultSearchController's tableVC
        locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTableVC") as! LocationSearchTableVC
        locationSearchTable.handleMapSearchDelegate = self
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        // The locationSearchTable will also serve as the searchResultsUpdater delegate.
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        // Set up searchBar
        searchBar = resultSearchController!.searchBar
        view.addSubview(searchBar)
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"

        navigationItem.titleView = searchBar
      
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    
        locationSearchTable.mapView = mapView
        // configure tap recognizer
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
//        tapRecognizer.numberOfTapsRequired = 1
//        tapRecognizer.delegate = self
//        view.addGestureRecognizer(tapRecognizer)
        
        // Delegate Set up
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        //print back to mapVC
        dismiss(animated: true, completion: nil)
    }

    @IBAction func hostEvent(_ sender: Any) {
        if selectedPin == nil {
            showAlert(alertMsg: Constant.Alert.location )
        } else if eventTitle.text! == "" {
            showAlert(alertMsg: Constant.Alert.title )
        } else if ( partySize.text! == "" || Int(partySize.text!) == nil ){
            showAlert(alertMsg: Constant.Alert.partySize)
        } else if eventDescription.text!.characters.count > 255 {
            showAlert(alertMsg: Constant.Alert.description)
        }
        // Successful case to Firebase!
        else {
            let newChannelRef = channelRef.childByAutoId()
            let keywords = eventKeyWords.text!.split(separator: ",")
            
            let channelItem = [
                Constant.FB.hostName: "host_bot1",
                Constant.FB.latitude: selectedPin!.coordinate.latitude,
                Constant.FB.longtitude: selectedPin!.coordinate.longitude,
                Constant.FB.title: eventTitle.text!,
                Constant.FB.keywords: keywords,
                Constant.FB.description: eventDescription.text!,
                Constant.FB.hostSize: Int(partySize.text!) ?? 10
                ] as [String : Any]
            
            newChannelRef.setValue(channelItem)
            
            print("Going back to mapView Controller")
            
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    func showAlert(alertMsg: String) {
        let alert = UIAlertController(title: alertMsg, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    
}

// Gesture Delegates
extension HostEventViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        //toggleView(hideTableView: false)
        return searchBar.isFirstResponder
    }
}


// CLLocationManagerDelegate Methods
extension HostEventViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("location:: \(location)")
            let span = MKCoordinateSpanMake(0.08, 0.08)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

// Handling drop in pin
extension HostEventViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        annotation.subtitle =  placemark.name
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
    }
    
}

// TextField Delegate Methods
extension HostEventViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }

}

// Keyboard show & hide methods
extension HostEventViewController {
    
    @objc func keyboardWillShow(_ notification:Notification) {
        let keyboardHeight = getKeyboardHeight(notification)
        if ( view.frame.origin.y == 0 && eventTitle.isEditing == false){
            // shifting upwards, from 0 to keybaord height
            view.frame.origin.y = -keyboardHeight
        }
        
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
