//
//  Departure.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import Foundation
import SwiftyJSON

struct Departure {
    let name: String
    let typeString: String
    let stop: String
    let time: String
    let realTime: String
    let date: NSDate
    let realDate: NSDate?
    let track: String
    let realTrack: String?
    let finalStop: String
    let direction: String
}

extension Departure {
    
    enum Type : String {
        case IC = "IC"
        case Lyn = "LYN"
        case Regional = "REG"
        case STrain = "S"
        case OtherTrain = "TOG"
        case Bus = "BUS"
        case ExpressBus = "EXB"
        case NightBus = "NB"
        case TeleBuse = "TB"
        case Ferry = "F"
        case Metro = "M"
        case Unknown
    }
    
    var type : Type {
        get {
            return Type(rawValue: self.typeString) ?? .Unknown
        }
    }
    
    enum STrainType : String {
        case A = "A"
        case B = "B"
        case Bx = "Bx"
        case C = "C"
        case E = "E"
        case F = "F"
        case H = "H"
        case Unknown
    }
    
    var sTrainType : STrainType {
        get {
            return STrainType(rawValue: self.name) ?? .Unknown
        }
    }
    
    var departureTime: NSDate {
        get {
            return NSDateFormatter.timeFormatter().dateFromString(self.time)!
        }
    }
    
    var realDepartureTime: NSDate {
        get {
            return NSDateFormatter.timeFormatter().dateFromString(self.realTime)!
        }
    }
}

extension Departure : JSONAble {
    typealias T = Departure
    
    static func fromJSON(dict : JSONDict) -> Departure? {
        let json = JSON(dict)
        
        return Departure(
            name: json["name"].stringValue,
            typeString: json["type"].stringValue,
            stop: json["stop"].stringValue,
            time: json["time"].stringValue,
            realTime: json["rtTime"].stringValue,
            date: json["date"].date!,
            realDate: json["rtDate"].date,
            track: json["track"].stringValue,
            realTrack: json["rtTrack"].string,
            finalStop: json["finalStop"].stringValue,
            direction: json["direction"].stringValue)
    }
}