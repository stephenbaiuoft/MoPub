//
//  Constant.swift
//  MoPub
//
//  Created by stephen on 9/21/17.
//  Copyright © 2017 Bai Cloud AI Co. All rights reserved.
//

import Foundation

class Constant {
    struct VC {
        static let segueToHostEvent = "segueToHostEvent"
        static let segueToMapView = "segueToMapView"
        static let segueChannelToChatVC = "segueChannelToChatVC"
        static let segueToChatVC = "segueToChatVC"
        static let segueToLogin = "segueToLogin"
        static let segueToCollectionVC = "segueToCollectionVC"
    }
    
    struct FB {
        static let hostName = "hostName"
        static let uniqueId = "uniqueId"
        static let title = "title"
        // keywords: bunch of keywords for this event
        static let keywords = "keywords"
        static let longtitude = "longtitude"
        static let latitude = "latitude"
        static let description = "description"
        static let hostSize = "size"
    }
    
    struct Alert {
        static let location = "Please enter a valid location"
        static let title = "Please enter a valid title"
        static let partySize = "Please enter a valid number"
        static let description = "Description is limited to 255 only"
    }
}
