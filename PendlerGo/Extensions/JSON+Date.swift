//
//  JSON+Date.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import Foundation
import SwiftyJSON

extension JSON {
    
    public var date: Date? {
        get {
            switch self.type {
            case .string:
                return DateFormatter.dateFormatter().date(from: self.object as! String)
            default:
                return nil
            }
        }
    }
    
    public var dateTime: Date? {
        get {
            switch self.type {
            case .string:
                return DateFormatter.timeFormatter().date(from: self.object as! String)
            default:
                return nil
            }
        }
    }
    
}
