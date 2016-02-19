//
//  Location.swift
//  PendlerGo
//
//  Created by Philip Engberg on 19/02/16.
//
//

import Foundation
import SwiftyJSON

struct Location {
    let name: String
    let xCoordinate: String
    let yCoordinate: String
    let id: String
}

extension Location : JSONAble {
    typealias T = Location
    
    static func fromJSON(dict : JSONDict) -> Location? {
        let json = JSON(dict)
        
        return Location(
            name: json["name"].stringValue,
            xCoordinate: json["x"].stringValue,
            yCoordinate: json["y"].stringValue,
            id: json["id"].stringValue)
    }
}