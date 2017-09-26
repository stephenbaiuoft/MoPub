//
//  JSQMethods.swift
//  ChatChat
//
//  Created by stephen on 9/25/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import JSQMessagesViewController

// Methods for creating messages
extension ChatViewController {
  func addMessage(withId id: String, name: String, text: String) {
        
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
}
