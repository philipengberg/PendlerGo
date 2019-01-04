//
//  LocationResults.swift
//  PendlerGo
//
//  Created by Philip Engberg on 19/02/16.
//
//

import Foundation
import SwiftyJSON

struct LocationResults {
    
    let locations: [Location]
    
}

extension LocationResults : JSONAble {
    typealias T = LocationResults
    
    static func fromJSON(_ dict : JSONDict) -> LocationResults? {
        let json = JSON(dict)
        
        let results = json["LocationList"].dictionaryValue
        
        if let locations = results["StopLocation"]?.arrayValue {
            return LocationResults(locations: locations.compactMap({ (JSON) -> Location? in
                return Location.fromJSON(JSON.dictionaryObject!)
            }))
        } else {
            return LocationResults(locations: [])
        }
    }
}
