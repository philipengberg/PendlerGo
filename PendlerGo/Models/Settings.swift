//
//  Settings.swift
//  PendlerGo
//
//  Created by Philip Engberg on 19/02/16.
//
//

import Foundation
import RxSwift
import RxCocoa

struct Settings {
    
    enum LocationType : Int {
        case Home
        case Work
    }
    
    private static let homeIdKey   = "homeId"
    private static let homeNameKey = "homeName"
    private static let homeXKey    = "homeX"
    private static let homeYKey    = "homeY"
    
    private static let workIdKey   = "workd"
    private static let workNameKey = "workName"
    private static let workXKey    = "workX"
    private static let workYKey    = "workY"
    
    private static let includeTrainsKey  = "includeTrains"
    private static let includeSTrainsKey = "includeSTrains"
    private static let includeMetroKey   = "includeMetro"
    
    static func initialize() {
        
        if NSUserDefaults.standardUserDefaults().valueForKey(Settings.includeTrainsKey) == nil {
            NSUserDefaults.standardUserDefaults().setValue(true, forKey: Settings.includeTrainsKey)
        }
        
        if NSUserDefaults.standardUserDefaults().valueForKey(Settings.includeSTrainsKey) == nil {
            NSUserDefaults.standardUserDefaults().setValue(true, forKey: Settings.includeSTrainsKey)
        }
        
        if NSUserDefaults.standardUserDefaults().valueForKey(Settings.includeMetroKey) == nil {
            NSUserDefaults.standardUserDefaults().setValue(true, forKey: Settings.includeMetroKey)
        }
        
        Settings.homeLocation = Settings.homeLocation
        Settings.workLocation = Settings.workLocation
        
        Settings.includeTrains = Settings.includeTrains
        Settings.includeSTrains = Settings.includeSTrains
        Settings.includeMetro = Settings.includeMetro
    }
    
    static var homeLocationVariable = Variable<Location?>(nil)
    static var workLocationVariable = Variable<Location?>(nil)
    
    static var homeLocation: Location? {
        get {
            if
                let id = NSUserDefaults.standardUserDefaults().stringForKey(Settings.homeIdKey),
                let x = NSUserDefaults.standardUserDefaults().stringForKey(Settings.homeXKey),
                let y = NSUserDefaults.standardUserDefaults().stringForKey(Settings.homeYKey),
                let name =  NSUserDefaults.standardUserDefaults().stringForKey(Settings.homeNameKey) {
                    return Location(
                        name: name,
                        xCoordinate: x,
                        yCoordinate: y,
                        id: id)
            }
            return nil
        }
        set {
            homeLocationVariable.value = newValue
            NSUserDefaults.standardUserDefaults().setValue(newValue?.id, forKey: Settings.homeIdKey)
            NSUserDefaults.standardUserDefaults().setValue(newValue?.xCoordinate, forKey: Settings.homeXKey)
            NSUserDefaults.standardUserDefaults().setValue(newValue?.yCoordinate, forKey: Settings.homeYKey)
            NSUserDefaults.standardUserDefaults().setValue(newValue?.name, forKey: Settings.homeNameKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    static var workLocation: Location? {
        get {
            if
                let id = NSUserDefaults.standardUserDefaults().stringForKey(Settings.workIdKey),
                let x = NSUserDefaults.standardUserDefaults().stringForKey(Settings.workXKey),
                let y = NSUserDefaults.standardUserDefaults().stringForKey(Settings.workYKey),
                let name =  NSUserDefaults.standardUserDefaults().stringForKey(Settings.workNameKey) {
                    return Location(
                        name: name,
                        xCoordinate: x,
                        yCoordinate: y,
                        id: id)
            }
            return nil
        }
        set {
            workLocationVariable.value = newValue
            NSUserDefaults.standardUserDefaults().setValue(newValue?.id, forKey: Settings.workIdKey)
            NSUserDefaults.standardUserDefaults().setValue(newValue?.xCoordinate, forKey: Settings.workXKey)
            NSUserDefaults.standardUserDefaults().setValue(newValue?.yCoordinate, forKey: Settings.workYKey)
            NSUserDefaults.standardUserDefaults().setValue(newValue?.name, forKey: Settings.workNameKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    
    static var includeTrainsVariable  = Variable<Bool>(true)
    static var includeSTrainsVariable = Variable<Bool>(true)
    static var includeMetroVariable  = Variable<Bool>(true)
    
    static var includeTrains: Bool {
        get {
            NSUserDefaults.standardUserDefaults().valueForKey(Settings.includeTrainsKey)
            let val = NSUserDefaults.standardUserDefaults().boolForKey(Settings.includeTrainsKey)
            return val
        }
        set {
            includeTrainsVariable.value = newValue
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: Settings.includeTrainsKey)
        }
    }
    
    static var includeSTrains: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(Settings.includeSTrainsKey)
        }
        set {
            includeSTrainsVariable.value = newValue
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: Settings.includeSTrainsKey)
        }
    }
    
    static var includeMetro: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(Settings.includeMetroKey)
        }
        set {
            includeMetroVariable.value = newValue
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: Settings.includeMetroKey)
        }
    }
    
}