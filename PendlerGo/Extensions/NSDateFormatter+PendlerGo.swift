//
//  NSDateFormatter+PendlerGo.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import Foundation

extension NSDateFormatter {
    
    static func timeFormatter() -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    static func dateFormatter() -> NSDateFormatter {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }
}