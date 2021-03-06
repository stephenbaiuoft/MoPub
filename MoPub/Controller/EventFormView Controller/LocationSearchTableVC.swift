//
//  LocationSearchTableVC.swift
//  MoPub
//
//  Created by stephen on 9/26/17.
//  Copyright © 2017 Bai Cloud AI Co. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTableVC: UITableViewController {
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate:HandleMapSearch? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }


    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "City" and "Province"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    // select that particular cell
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        // delegate method (defined in HostEventController --> to communicate)
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        
        // dismiss LocationSearchVC & back to HostEventController
        dismiss(animated: true, completion: nil)
    }
    
}

extension LocationSearchTableVC : UISearchResultsUpdating {
    
    func showAlert(alertMsg: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertMsg, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        
        if (searchBarText.characters.count == 0) { return }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        
        
        
        let search = MKLocalSearch(request: request)
      
        search.start { response, error in
            if let error = error {
                self.showAlert(alertMsg: "Failed to Search Location: Check Network")
            }
            
            guard let response = response else {
                return
            }
            
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

