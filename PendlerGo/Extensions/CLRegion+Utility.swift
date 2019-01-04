//
//  CLRegion+Utility.swift
//  PendlerGo
//
//  Created by Philip Engberg on 04/01/2019.
//

import CoreLocation
import Foundation

extension CLCircularRegion {
    
    convenience init(center: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, notifyOnEntry: Bool, notifyOnExit: Bool) {
        self.init(center: center, radius: radius, identifier: identifier)
        
        self.notifyOnEntry = notifyOnEntry
        self.notifyOnExit  = notifyOnExit
    }
    
}
