//
//  Conversation.swift
//  MoPub
//
//  Created by stephen on 9/26/17.
//  Copyright © 2017 Bai Cloud AI Co. All rights reserved.
//

import Foundation

internal class Channel {
    // id: uniquely generated by Firebase.child() ==> for this channel!
    internal let uniqueId: String
    // hostName: the hostName who created this channel
    internal let hostName: String
    // title of this event
    internal let title: String
    // keywords: bunch of keywords for this event
    internal let keywords: [String]
    
    // location information of the channel
    internal let longtitude: Double
    internal let latitude: Double
    
    internal let size: Int
    internal let description: String
    
    
    init(id: String, name: String, title: String, keywords: [String],
         longtitude: Double, latitude: Double, size: Int, description: String) {
        
        self.uniqueId = id
        self.hostName = name
        self.title = title
        self.keywords = keywords
        
        self.longtitude = longtitude
        self.latitude = latitude
        
        self.size = size
        self.description = description
    }
}
