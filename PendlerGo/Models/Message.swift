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
    
    static func fromJSON(dict : JSONDict) -> Message? {
        let json = JSON(dict)
        
        return Message(
            header: json["Header"].dictionaryValue["$"]!.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()),
            text: json["Text"].dictionaryValue["$"]!.stringValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
    }
}