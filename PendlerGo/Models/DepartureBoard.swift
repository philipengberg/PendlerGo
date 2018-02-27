//
//  DepartureBoard.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import Foundation
import SwiftyJSON

struct DepartureBoard {
    let departures: [Departure]
}

extension DepartureBoard : JSONAble {
    typealias T = DepartureBoard
    
    static func fromJSON(_ dict : JSONDict) -> DepartureBoard? {
        let json = JSON(dict)
       
        let board = json["DepartureBoard"].dictionaryValue
        
        guard let departure = board["Departure"]?.arrayValue else { return DepartureBoard(departures: []) }
        
        return DepartureBoard(departures: departure.flatMap({ (JSON) -> Departure? in
            return Departure.fromJSON(JSON.dictionaryObject!)
        }))
    }
}
