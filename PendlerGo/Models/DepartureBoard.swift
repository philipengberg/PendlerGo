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
    
    static func fromJSON(dict : JSONDict) -> DepartureBoard? {
        let json = JSON(dict)
       
        let board = json["DepartureBoard"].dictionaryValue
        
        return DepartureBoard(departures: board["Departure"]!.arrayValue.flatMap({ (JSON) -> Departure? in
            return Departure.fromJSON(JSON.dictionaryObject!)
        }))
    }
}