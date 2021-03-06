//
//  JourneyDetail.swift
//  PendlerGo
//
//  Created by Philip Engberg on 11/03/16.
//
//

import Foundation
import SwiftyJSON

struct JourneyDetail {
    let messages: [Message]
}

extension JourneyDetail : JSONAble {
    typealias T = JourneyDetail
    
    static func fromJSON(_ dict : JSONDict) -> JourneyDetail? {
        let json = JSON(dict)
        
        let detail = json["JourneyDetail"].dictionaryValue
        let list = detail["MessageList"]?.dictionaryValue
        
        if let messages = list?["Message"]?.arrayValue {
            
            if messages.count > 0 {
                return JourneyDetail(messages: messages.flatMap({ (JSON) -> Message? in
                    return Message.fromJSON(JSON.dictionaryObject!)
                }))
            } else {
                return JourneyDetail(messages: [Message.fromJSON(list!["Message"]!.dictionaryObject!)!])
            }
        }
        
        return JourneyDetail(messages: [])
    }
}

extension JourneyDetail {
    var allMessages: String {
        get {
            var string = ""
            for (index, message) in self.messages.enumerated() {
                string += "\(message.header)\(message.header.hasSuffix(".") ? "" : ".") \(message.text)\(message.text.hasSuffix(".") ? "" : ".")"
                if index < messages.count - 1 {
                    string += "\n"
                }
            }
            return string
        }
    }
}
