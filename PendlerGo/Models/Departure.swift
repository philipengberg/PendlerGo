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
    let date: Date
    let realDate: Date?
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
    
    enum DepartureType : String {
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
    
    var type : DepartureType {
        get {
            return DepartureType(rawValue: self.typeString) ?? .Unknown
        }
    }
    
    enum TransportationType {
        case train
        case sTrain
        case metro
        case bus
        case ferry
        case unknown
    }
    
    var transportationType : TransportationType {
        switch self.type {
        case .IC, .Lyn, .Regional, .OtherTrain:
            return .train
        case .STrain:
            return .sTrain
        case .Bus, .ExpressBus, .NightBus, .TeleBuse:
            return .bus
        case .Ferry:
            return .ferry
        case .Metro:
            return .metro
        default:
            return .unknown
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
    
    var departureTime: Date {
        get {
            return DateFormatter.timeFormatter().date(from: self.time)!
        }
    }
    
    var combinedDepartureDateTime: Date {
        get {
            let time = DateFormatter.timeFormatter().date(from: self.time)!
            return combineDateWithTime(self.date, time: time)
        }
    }
    
    var realDepartureTime: Date {
        get {
            return DateFormatter.timeFormatter().date(from: self.realTime)!
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
            return self.detailRef.substring(from: self.detailRef.range(of: "=")!.lowerBound).removingPercentEncoding!
        }
    }
    
    fileprivate func combineDateWithTime(_ date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        
        let dateComponents = (calendar as NSCalendar).components([.year, .month, .day], from: date)
        let timeComponents = (calendar as NSCalendar).components([.hour, .minute, .second], from: time)
        
        var mergedComponments = DateComponents()
        mergedComponments.year = dateComponents.year
        mergedComponments.month = dateComponents.month
        mergedComponments.day = dateComponents.day
        mergedComponments.hour = timeComponents.hour
        mergedComponments.minute = timeComponents.minute
        mergedComponments.second = timeComponents.second
        
        return calendar.date(from: mergedComponments) ?? date
    }
}

extension Departure : JSONAble {
    typealias T = Departure
    
    static func fromJSON(_ dict : JSONDict) -> Departure? {
        let json = JSON(dict)
        
        return Departure(
            name: json["name"].stringValue,
            typeString: json["type"].stringValue,
            stop: json["stop"].stringValue,
            time: json["time"].stringValue,
            realTime: json["rtTime"].stringValue,
            date: json["date"].date! as Date,
            realDate: json["rtDate"].date as Date?,
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
