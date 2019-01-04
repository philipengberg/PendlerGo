//
//  Date+Utility.swift
//  PendlerGo
//
//  Created by Philip Engberg on 04/01/2019.
//

import DateToolsSwift
import Foundation

extension TimeChunk {
    
    init(seconds: Int) {
        self.init(seconds: seconds, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    init(minutes: Int) {
        self.init(seconds: 0, minutes: minutes, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    init(hours: Int) {
        self.init(seconds: 0, minutes: 0, hours: hours, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    init(days: Int) {
        self.init(seconds: 0, minutes: 0, hours: 0, days: days, weeks: 0, months: 0, years: 0)
    }
    
    init(weeks: Int) {
        self.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: weeks, months: 0, years: 0)
    }
    
    init(months: Int) {
        self.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: months, years: 0)
    }
    
    init(years: Int) {
        self.init(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: years)
    }
    
}
