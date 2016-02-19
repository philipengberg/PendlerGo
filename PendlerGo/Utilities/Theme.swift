//
//  Theme.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import Foundation
import UIKit

struct Theme {
    
    struct color {
        static var darkTextColor:               UIColor { return UIColor(gray: 97) }
        static var textColor:                   UIColor { return UIColor(gray: 170) }
        static var lightTextColor:              UIColor { return UIColor(gray: 216) }
        
        static var sTrainA:                     UIColor { return UIColor(red: 0, green: 151, blue: 211) }
        static var sTrainB:                     UIColor { return UIColor(red: 64, green: 163, blue: 55) }
        static var sTrainBx:                    UIColor { return UIColor(red: 137, green: 192, blue: 96) }
        static var sTrainC:                     UIColor { return UIColor(red: 228, green: 120, blue: 35) }
        static var sTrainE:                     UIColor { return UIColor(red: 99, green: 90, blue: 149) }
        static var sTrainF:                     UIColor { return UIColor(red: 242, green: 176, blue: 30) }
        static var sTrainH:                     UIColor { return UIColor(red: 211, green: 51, blue: 32) }
        
        static var trainIC:                     UIColor { return UIColor(red: 249, green: 15, blue: 0) }
        static var trainReg:                    UIColor { return UIColor(red: 0, green: 193, blue: 10) }
        static var trainOther:                  UIColor { return UIColor(gray: 154) }
    }
    
    
    struct font {
        static func light(size size: FontSize) -> UIFont? {
            return UIFont(name: "AvenirNext-Light", size: size.rawValue)
        }
        
        static func regular(size size: FontSize) -> UIFont? {
            return UIFont(name: "AvenirNext-Regular", size: size.rawValue)
        }
        
        static func medium(size size: FontSize) -> UIFont? {
            return UIFont(name: "AvenirNext-Medium", size: size.rawValue)
        }
        
        static func demiBold(size size: FontSize) -> UIFont? {
            return UIFont(name: "AvenirNext-DemiBold", size: size.rawValue)
        }
        
        static func bold(size size: FontSize) -> UIFont? {
            return UIFont(name: "AvenirNext-Bold", size: size.rawValue)
        }
    }
    
    
    enum FontSize: CGFloat {
        case Micro = 8
        case Tiny = 9
        case XtraSmall = 10
        case Small = 12
        case Medium = 14
        case Large = 16
        case XtraLarge = 18
        case Big = 24
        case Huge = 50
    }
    
}

extension UIColor {
    convenience init(red: UInt8, green: UInt8, blue: UInt8) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: 1)
    }
    
    convenience init(gray: UInt8) {
        self.init(
            red: CGFloat(gray) / 255.0,
            green: CGFloat(gray) / 255.0,
            blue: CGFloat(gray) / 255.0,
            alpha: 1)
    }
}