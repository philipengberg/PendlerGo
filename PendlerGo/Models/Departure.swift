//
//  Departure.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import Foundation
import SwiftyJSON
import DateTools

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
    let cancelled: Bool
    let messages: Int
    let detailRef: String
    let detail: JourneyDetail?
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
    
    enum TransportationType {
        case Train
        case STrain
        case Metro
        case Bus
        case Ferry
        case Unknown
    }
    
    var transportationType : TransportationType {
        switch self.type {
        case .IC, .Lyn, .Regional, .OtherTrain:
            return .Train
        case .STrain:
            return .STrain
        case .Bus, .ExpressBus, .NightBus, .TeleBuse:
            return .Bus
        case .Ferry:
            return .Ferry
        case .Metro:
            return .Metro
        default:
            return .Unknown
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
    
    var combinedDepartureDateTime: NSDate {
        get {
            let time = NSDateFormatter.timeFormatter().dateFromString(self.time)!
            return combineDateWithTime(self.date, time: time)
        }
    }
    
    var realDepartureTime: NSDate {
        get {
            return NSDateFormatter.timeFormatter().dateFromString(self.realTime)!
        }
    }
    
    var isDelayed: Bool {
        get {
            return !self.realTime.isEmpty && self.time != self.realTime
        }
    }
    
    var hasChangedTrack: Bool {
        get {
            return self.realTrack != self.track
        }
    }
    
    var hasMessages: Bool {
        get {
            return self.messages > 0
        }
    }
    
    var detailPath: String {
        get {
            return self.detailRef.substringFromIndex(self.detailRef.rangeOfString("=")!.startIndex.advancedBy(1)).stringByRemovingPercentEncoding!
        }
    }
    
    private func combineDateWithTime(date: NSDate, time: NSDate) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let dateComponents = calendar.components([.Year, .Month, .Day], fromDate: date)
        let timeComponents = calendar.components([.Hour, .Minute, .Second], fromDate: time)
        
        let mergedComponments = NSDateComponents()
        mergedComponments.year = dateComponents.year
        mergedComponments.month = dateComponents.month
        mergedComponments.day = dateComponents.day
        mergedComponments.hour = timeComponents.hour
        mergedComponments.minute = timeComponents.minute
        mergedComponments.second = timeComponents.second
        
        return calendar.dateFromComponents(mergedComponments) ?? date
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
            direction: json["direction"].stringValue,
            cancelled: json["cancelled"].boolValue,
            messages: json["messages"].intValue,
            detailRef: (json["JourneyDetailRef"].dictionaryValue)["ref"]!.stringValue,
            detail: nil)
    }
}