//
//  Message.swift
//  PendlerGo
//
//  Created by Philip Engberg on 11/03/16.
//
//

import Foundation
import SwiftyJSON

struct Message {
    let header: String
    let text: String
}

extension Message : JSONAble {
    typealias T = Message
    
    static func fromJSON(_ dict : JSONDict) -> Message? {
        let json = JSON(dict)
        
        let header = String(htmlEncodedString: json["Header"].dictionaryValue["$"]!.stringValue.trimmingCharacters(in: .whitespacesAndNewlines))
        let text = String(htmlEncodedString: json["Text"].dictionaryValue["$"]!.stringValue.trimmingCharacters(in: .whitespacesAndNewlines))
        
        return Message(
            header: header ?? "",
            text: text ?? "")
    }
}
