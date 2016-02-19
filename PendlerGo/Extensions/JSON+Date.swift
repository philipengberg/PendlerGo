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
    
    public var date: NSDate? {
        get {
            switch self.type {
            case .String:
                return NSDateFormatter.dateFormatter().dateFromString(self.object as! String)
            default:
                return nil
            }
        }
    }
    
    public var dateTime: NSDate? {
        get {
            switch self.type {
            case .String:
                return NSDateFormatter.timeFormatter().dateFromString(self.object as! String)
            default:
                return nil
            }
        }
    }
    
}