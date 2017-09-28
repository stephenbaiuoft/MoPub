//
//  CollectionVC.swift
//  MoPub
//
//  Created by stephen on 9/28/17.
//  Copyright © 2017 Bai Cloud AI Co. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CollectionVC: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var imageStringSet: [String]? {
        // whenever changed, reloadData for collectionView
        didSet{
            collectionView?.reloadData()
        }
    }
    
    var longtitude: Double?
    var latitude: Double?
    
    // MARK: flowLayout Variables
    let cellSpace:CGFloat = 5.0
    let edgeSpace:CGFloat = 3.0
    let itemsPerRow: CGFloat = 3
    var didLoadView = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        setFlowLayout(size: view.frame.width)
        didLoadView = true
        
        loadImageData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if(didLoadView) {
            print("viewWillTransition with width: \(size.width)" )
            setFlowLayout(size: size.width)
        }
    }
    
    // set equal spacing for based on itemsPerRow
    func setFlowLayout(size: CGFloat) {
        let dimension = (size - cellSpace * (itemsPerRow - 1) - 2 * edgeSpace ) / itemsPerRow
        flowLayout.minimumInteritemSpacing = cellSpace
        flowLayout.minimumLineSpacing = cellSpace
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        flowLayout.sectionInset = UIEdgeInsetsMake(edgeSpace, edgeSpace, edgeSpace, edgeSpace)
    }

    // display if there is no picture available
    func showLabel() {
        let label = UILabel.init()
        label.text = "This pin has no images"
        label.textAlignment = .center
        // have to set false so autolayout calcualtes our constraints!
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.init(item: label, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint.init(item: label, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.5, constant: 0).isActive = true
        NSLayoutConstraint.init(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        
    }

}


// MARK: CollectionView Delegate Methods
extension CollectionVC {
    
    // MARK: Configuring Cell Image
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        let activityIndicator = cell.activityIndicator!
        // create activityIndicator & start animating
        // stop it when imageData finishes loading
        
        activityIndicator.hidesWhenStopped = true
        
        print("start animating now!")
        DispatchQueue.main.async {
            activityIndicator.startAnimating()
        }
        
        let imageUrlString = imageStringSet![indexPath.row]
        // get imageData from imageUrlString
        let task = FClient.sharedInstance.taskForRequestImageData(filePath: imageUrlString, completionHandlerForRequestImageData: { (imageData, errString)
            in
            
            if(errString == nil) {
                DispatchQueue.main.async {
                    // stop activityIndicator
                    activityIndicator.stopAnimating()
                    cell.imageView.image = UIImage.init(data: imageData!)
                }
            }
            else {
                self.showAlert(alertMsg: "Network may be down")
            }
        })
        
        return cell
        
    }
    

    
    
    // # of items
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let set = imageStringSet {
            return  set.count
            
        } else {
            return 0
        }
    }
    
    
}



// MARK: Methods for Retrieving ImageData
extension CollectionVC {
    
    func loadImageData() {
        
        // initialize the task for getting imageUrl now
        FClient.sharedInstance.requestImageUrlSet(longtitude: (longtitude)!, latitude: (latitude)!, completionHandlerForRequestData: { (imageUrlDataSet, errorString)
            in
            // Success got 1-12 imageData
            if (errorString == nil) {
                if( imageUrlDataSet?.count == 0 ){
                    DispatchQueue.main.async {
                        self.showLabel()
                    }
                }
                else {
                    // allocate this dataSet to imageUrlDataSet
                    self.imageStringSet = imageUrlDataSet
                }
            }
                
            else {
                // Error ==> a network Error!
                self.showAlert(alertMsg: "Network may be down!")
            }
            
        })
    }
    
    func showAlert(alertMsg: String) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertMsg, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }
}
