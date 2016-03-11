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
    let message: Message
}

extension JourneyDetail : JSONAble {
    typealias T = JourneyDetail
    
    static func fromJSON(dict : JSONDict) -> JourneyDetail? {
        let json = JSON(dict)
        
        let detail = json["JourneyDetail"].dictionaryValue
        let list = detail["MessageList"]?.dictionaryValue
        
        return JourneyDetail(message: Message.fromJSON(list!["Message"]!.dictionaryObject!)!)
    }
}