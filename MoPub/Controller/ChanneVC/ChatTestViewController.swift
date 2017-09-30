//
//  ChatTestViewController.swift
//  MoPub
//
//  Created by stephen on 9/27/17.
//  Copyright © 2017 Bai Cloud AI Co. All rights reserved.
//  Modified the following content in order for Bai's own Development

/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import JSQMessagesViewController
import Firebase
import Photos

class ChatTestViewController: JSQMessagesViewController {
    // IBOutlet
    var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Chat properties
    var messages = [JSQMessage]()
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    // MARK: connectedReference!!!
    var connectedRef: DatabaseReference?
    var connectedRefHandle : DatabaseHandle?
    
    // MARK: Store Photo
    lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://mopub-4760c.appspot.com/")
    let imageURLNotSetKey = "NOTSET"
    // MARK: Displaying Images
    private var photoMessageMap = [String: JSQPhotoMediaItem]()

    // MARK: Firebase Properties
    
    // Will be set to uniqueId path
    var channelRef: DatabaseReference? = nil
    var channel: Channel? {
        didSet {
            // updating the title name ==> hostName's Event Group
            title = channel?.hostName ?? "Anonymous Host" + " Event Group"
        }
    }

    // Now will be set & add message node/child
    private lazy var messageRef = self.channelRef!.child("messages")
    private var newMessageRefHandle: DatabaseHandle?
    // Handle for any updates to the message that occur later ==> in this case: when image URL is updated after it's saved to storage
    private var updatedMessageRefHandle: DatabaseHandle?
    
    // MARK: Detecting if Current User is Typing
    private lazy var userIsTypingRef: DatabaseReference =
        self.channelRef!.child("typingIndicator").child(self.senderId) // 1
    private var localTyping = false // 2
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            // 3 ==> updating this value only!
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    // Mark: Detecting is Channel Users are Typing II
    private lazy var usersTypingQuery: DatabaseQuery =
        self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeNetwork()
        
        // MARK: instantiate activityIndicator
        activityIndicator = UIActivityIndicatorView.init()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        view.addSubview(activityIndicator)
        
        let margins = view.layoutMarginsGuide
        activityIndicator.centerXAnchor.constraint(equalTo: margins.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: margins.centerYAnchor).isActive = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        
        // have to set senderId to something unique!
        // fortunately firebase auth provides this unique information ;)
        self.senderId = Auth.auth().currentUser?.uid
        print("senderId is:\(senderId!)")
        
        // real-time observe messages
        observeMessages()
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        observeTyping()
    }
    
    // make sure you unsubscribe/remove observing the database!
    deinit {
        // remove the observer!!! here
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = connectedRefHandle {
            connectedRef?.removeObserver(withHandle: refHandle)
        }
        
    }
    
    // Mark: Know when a User is Typing
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
    
    
    func observeTyping() {
        // MARK: updating the Current User
        let typingIndicatorRef = channelRef!.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        // 1
        usersTypingQuery.observe(.value) { (data: DataSnapshot) in
            // 2 You're the only one typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            // 3 Are there others typing?
            // ===> showTypingIndicator is also built-in
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
        
    }
    
    // MARK: observe network state
    func observeNetwork() {
        
        connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRefHandle = connectedRef!.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                print("Connected")
            } else {
                self.showAlert(alertMsg: "No Network Connection")
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

    
    func observeMessages() {
        messageRef = channelRef!.child("messages")
        
        // This Region is for updated messages
        
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String> // 1
            
            if let photoURL = messageData["photoURL"] as String! { // 2
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] { // 3
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key) // 4
                }
            }
        })
        
        
        //This Region is for added messages
        // 1. !!! important querying up to # of limits
        let messageQuery = messageRef.queryLimited(toLast:25)
        
        // 2. We can use the observe method to listen for new
        // messages being written to the Firebase DB
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            
            // 3
            let messageData = snapshot.value as! Dictionary<String, String>
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                // 4
                self.addMessage(withId: id, name: name, text: text)
                
                self.stopActivityIndicator()
                // 5
                self.finishReceivingMessage()
            }
                
                // Hanlde photoUrl
            else if let id = messageData["senderId"] as String!,
                let photoURL = messageData["photoURL"] as String! { // 1
                // 2
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    // 3
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    // 4
                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                    self.stopActivityIndicator()
                }
            }
                
            else {
                self.showAlert(alertMsg: "Could not get data: check your network")
            }
        })
    }

    // MARK: stop ActivityIndicator
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            if self.activityIndicator.isAnimating {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    // MARK: Photo Module!!!
    // Sending Photo?
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        // returning the itemRef --> created by childByAutoId
        return itemRef.key
    }
    
    // Method to change the realDatabase storage reference
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        // retriving the particular child node
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    // MARK: Camera Icon Pressed, JSQ: Handling selecting the image from ImagePicker
    override func didPressAccessoryButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
//        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
//            picker.sourceType = UIImagePickerControllerSourceType.camera
//        } else {
//            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
//        }
        
        // fix to photoLib for now ==> will have to change later!
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(picker, animated: true, completion:nil)
    }
    
    
    func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
    
    // Fetching from Firebase Storage
    func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        // 1
        let storageRef = Storage.storage().reference(forURL: photoURL)
        
        // 2 Getting data from FireBase storage
        storageRef.getData(maxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            // 3
            storageRef.getMetadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                // 4
//                if (metadata?.contentType == "image/gif") {
//                    mediaItem.image = UIImage.gifWithData(data!)
//                } else {
//                    mediaItem.image = UIImage.init(data: data!)
//                }
                mediaItem.image = UIImage.init(data: data!)
                self.collectionView.reloadData()
                
                // 5
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
    
    // MARK: Sending Button Overridden
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId() // 1
        let messageItem = [ // 2
            "senderId": senderId!,
            "senderName": channel!.hostName,
            "text": text!,
            ]
        
        // activityIndicator is not instantiated? by code?
        activityIndicator.startAnimating()
        itemRef.setValue(messageItem) // 3
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        
        // animating sendingMsg action!!!
        finishSendingMessage() // 5
        
        isTyping = false // reset the typing value
        
    }
    
}

// MARK: Image Picker Delegate
extension ChatTestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: imagePickerController Delegate Methods Region
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        // 1
        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
            // Handle picking a Photo from the Photo Library
            // 2
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
            let asset = assets.firstObject
            
            // 3
            if let key = sendPhotoMessage() {
                // 4
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    // imageFileURL is the actual file url on device
                    let imageFileURL = contentEditingInput?.fullSizeImageURL
                    
                    // 5  ==> unwrap --> removing the optinal value
                    let path = "\(String(describing: Auth.auth().currentUser!.uid))/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
                    
                    // 6
                    self.storageRef.child(path).putFile(from: imageFileURL!, metadata: nil) { (storagemetadata, error) in
                        if let error = error {
                            print("Error uploading photo: \(error.localizedDescription)")
                            return
                        }
                        // 7
                        self.setImageURL(self.storageRef.child((storagemetadata?.path)!).description, forPhotoMessageWithKey: key)
                    }
                })
            }
            
        } else {
            // Handle the picture from the Camera
            // 1
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            // 2
            if let key = sendPhotoMessage() {
                // 3
                
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                // 4
                let imagePath = Auth.auth().currentUser!.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
                // 5
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                // 6  Uploading the photoData directly
                storageRef.child(imagePath).putData(imageData!, metadata: metadata, completion: { (storagemetadata, error) in
                    if let error = error {
                        print("Error uploading photo: \(error)")
                        return
                    }
                    // 7
                    self.setImageURL(self.storageRef.child((storagemetadata?.path)!).description, forPhotoMessageWithKey: key)
                })
                
            }
            
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}

