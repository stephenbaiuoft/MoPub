//
//  DoubleExtension.swift
//  MoPub
//
//  Created by stephen on 9/28/17.
//  Copyright © 2017 Bai Cloud AI Co. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    
}
