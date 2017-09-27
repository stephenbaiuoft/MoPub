//
//  MapViewController.swift
//  MoPub
//
//  Created by stephen on 9/26/17.
//  Copyright © 2017 Bai Cloud AI Co. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class MapViewController: UIViewController {
    // MARK: IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: FireBase properties
    var user: User? = nil
    // Each channel is created Only by a annotation!
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    // channelRefHandle: listen & observe
    private var channelRefHandle: DatabaseHandle?
    
    // MARK: Properties
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Listen to FireBase updates
        observeChannels()
        
        // location configuration
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    deinit {
        // remove the observer!!! here
        if let refHandle = channelRefHandle {
            channelRef.removeObserver(withHandle: refHandle)
        }
    }
    
    // reloadAnnotation from the mapView
    func reloadAnnotation( annotation: MKAnnotation ) {
        
        DispatchQueue.main.async {
            // remove in case of duplicates: Will be fixed later on!
            self.mapView.removeAnnotation(annotation)
            self.mapView.addAnnotation(annotation)
        }
    }
}

// Firebase methods
extension MapViewController {
    func observeChannels() {
        // Use the observe method to listen for new
        // channels being written to the Firebase DB
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in // 1
            let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
            let id = snapshot.key
            if let longtitude = channelData[Constant.FB.longtitude] as! Double!,
               let latitude = channelData[Constant.FB.latitude] as! Double!,
                let title = channelData[Constant.FB.title] as! String!,
                let subtitle = channelData[Constant.FB.hostName] as! String!
                { // 3
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = latitude
                annotation.coordinate.longitude = longtitude
                annotation.title = title
                annotation.subtitle = subtitle
                    
                self.reloadAnnotation(annotation: annotation)
                
            } else {
                print("Error! Could not decode channel data")
            }
        })
    }
}

// CLLocationManagerDelegate Methods
extension MapViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("location:: \(location)")
            // zoom to nearby location
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}
