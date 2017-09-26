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
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var eventTitle: UITextField!
    @IBOutlet weak var partySize: UITextField!
    @IBOutlet weak var eventKeyWords: UITextField!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var hostButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func hostEvent(_ sender: Any) {
        
    }
    
}
