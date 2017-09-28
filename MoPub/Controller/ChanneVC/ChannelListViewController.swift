//
//  ChannelListViewController.swift
//  MoPub
//
//  Created by stephen on 9/27/17.
//  Copyright © 2017 Bai Cloud AI Co. All rights reserved.
//

import UIKit
import Firebase

class ChannelListViewController: UITableViewController {
    // MARK: Properties
    private var channels: [Channel] = []
    var user: User?
    
    // MARK: Firebase
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
    private var channelRefHandle: DatabaseHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting Title
        title = "Event Message Channel List"
        // link the firebaseRef
        observeChannels()
    }


    deinit {
        // remove the observer!!! here
        if let refHandle = channelRefHandle {
            channelRef.removeObserver(withHandle: refHandle)
        }
    }
    
    private func observeChannels() {
        // Use the observe method to listen for new
        // channels being written to the Firebase DB
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in // 1
            let channelData = snapshot.value as! Dictionary<String, AnyObject> // 2
            let uniqueId = snapshot.key
            if let hostName = channelData[Constant.FB.hostName] as! String!, hostName.characters.count > 0,
                let description = channelData[Constant.FB.description] as! String!,
                let keywords = channelData[Constant.FB.keywords] as! [String]!,
                let latitude = channelData[Constant.FB.latitude] as! Double!,
                let longtitude = channelData[Constant.FB.longtitude] as! Double!,
                let size = channelData[Constant.FB.hostSize] as! Int!,
                let title = channelData[Constant.FB.title] as! String!
            { // 3
                let newC = Channel.init(id: uniqueId, name: hostName, title: title, keywords: keywords,
                                        longtitude: longtitude, latitude: latitude, size: size, description: description )
                
                self.channels.append(newC)
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode channel data")
            }
        })
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return channels.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath)

        // return title & hostName
        cell.textLabel?.text = channels[indexPath.row].title
        cell.detailTextLabel?.text = channels[indexPath.row].hostName

        return cell
    }
 
    // Upon selecting a row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedChannel = channels[indexPath.row]
        self.performSegue(withIdentifier: "segueChannelToChatVC", sender: selectedChannel)
        
    }


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let selectedChannel = sender as? Channel {
            let chatVc = segue.destination as! ChatTestViewController
            chatVc.channel = selectedChannel
            chatVc.channelRef = channelRef.child(selectedChannel.uniqueId)
            chatVc.senderDisplayName = user?.displayName ?? "Anonymous User"
//            chatVc.channel = channel
//            chatVc.channelRef = channelRef.child(channel.id)
        }
    }
    

}
