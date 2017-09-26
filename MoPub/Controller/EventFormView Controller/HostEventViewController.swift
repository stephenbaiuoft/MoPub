//
//  HostEventViewController.swift
//  MoPub
//
//  Created by stephen on 9/26/17.
//  Copyright © 2017 Bai Cloud AI Co. All rights reserved.
//

import UIKit
import MapKit

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
    
    // MARK: Properties
    let locationManager = CLLocationManager()
    var locationSearchTable: LocationSearchTableVC!
    var searchBar: UISearchBar!
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
    }

    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction func hostEvent(_ sender: Any) {
        
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
        
        // Mark: creating in FireBase
    }
}
