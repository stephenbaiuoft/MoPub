//
//  HostEventViewController.swift
//  MoPub
//
//  Created by stephen on 9/26/17.
//  Copyright © 2017 Bai Cloud AI Co. All rights reserved.
//

import UIKit
import MapKit

class HostEventViewController: UIViewController {
    
    // MARK: IBOutlets
    
    // Location Search!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var partySize: UITextField!
    @IBOutlet weak var eventKeyWords: UITextField!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var hostButton: UIButton!
    
    // MARK: Properties
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // location configuration
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        print("requesting location when in usage?")
        locationManager.requestLocation()
        
        // configure tap recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        
    }

    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction func hostEvent(_ sender: Any) {
        
    }
    
    func toggleView( hideTableView: Bool) {
        tableView.isHidden = hideTableView
        mapView.isHidden = !hideTableView
    }
}

// Gesture Delegates
extension HostEventViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        //toggleView(hideTableView: false)
        return searchBar.isFirstResponder
    }
}

// UISearchBarDelegates
extension HostEventViewController: UISearchBarDelegate {
    
    // each time the search text changes we want to cancel any current download and start a new one
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
//        // cancel the last task
//        if let task = searchTask {
//            task.cancel()
//        }
//
//        // if the text is empty we are done
//        if searchText == "" {
//            movies = [TMDBMovie]()
//            movieTableView?.reloadData()
//            return
//        }
//
//        // new search
//        searchTask = TMDBClient.sharedInstance().getMoviesForSearchString(searchText) { (movies, error) in
//            self.searchTask = nil
//            if let movies = movies {
//                self.movies = movies
//                performUIUpdatesOnMain {
//                    self.movieTableView!.reloadData()
//                }
//            }
//        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //toggleView(hideTableView: true)
        searchBar.resignFirstResponder()
    }
}

// Tableview Delegates
extension HostEventViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let CellReuseId = "LocationID"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as UITableViewCell!
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
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
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}
