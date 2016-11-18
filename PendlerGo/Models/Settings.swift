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
        case home
        case work
        
        var eventName: String {
            switch self {
            case .home:
                return "Home"
            case .work:
                return "Work"
            }
        }
    }
    
    fileprivate static let homeIdKey   = "homeId"
    fileprivate static let homeNameKey = "homeName"
    fileprivate static let homeXKey    = "homeX"
    fileprivate static let homeYKey    = "homeY"
    
    fileprivate static let workIdKey   = "workd"
    fileprivate static let workNameKey = "workName"
    fileprivate static let workXKey    = "workX"
    fileprivate static let workYKey    = "workY"
    
    fileprivate static let includeTrainsKey  = "includeTrains"
    fileprivate static let includeSTrainsKey = "includeSTrains"
    fileprivate static let includeMetroKey   = "includeMetro"
    
    static func initialize() {
        
        if UserDefaults.standard.value(forKey: Settings.includeTrainsKey) == nil {
            UserDefaults.standard.setValue(true, forKey: Settings.includeTrainsKey)
        }
        
        if UserDefaults.standard.value(forKey: Settings.includeSTrainsKey) == nil {
            UserDefaults.standard.setValue(true, forKey: Settings.includeSTrainsKey)
        }
        
        if UserDefaults.standard.value(forKey: Settings.includeMetroKey) == nil {
            UserDefaults.standard.setValue(true, forKey: Settings.includeMetroKey)
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
                let id = UserDefaults.standard.string(forKey: Settings.homeIdKey),
                let x = UserDefaults.standard.string(forKey: Settings.homeXKey),
                let y = UserDefaults.standard.string(forKey: Settings.homeYKey),
                let name =  UserDefaults.standard.string(forKey: Settings.homeNameKey) {
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
            UserDefaults.standard.setValue(newValue?.id, forKey: Settings.homeIdKey)
            UserDefaults.standard.setValue(newValue?.xCoordinate, forKey: Settings.homeXKey)
            UserDefaults.standard.setValue(newValue?.yCoordinate, forKey: Settings.homeYKey)
            UserDefaults.standard.setValue(newValue?.name, forKey: Settings.homeNameKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var workLocation: Location? {
        get {
            if
                let id = UserDefaults.standard.string(forKey: Settings.workIdKey),
                let x = UserDefaults.standard.string(forKey: Settings.workXKey),
                let y = UserDefaults.standard.string(forKey: Settings.workYKey),
                let name =  UserDefaults.standard.string(forKey: Settings.workNameKey) {
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
            UserDefaults.standard.setValue(newValue?.id, forKey: Settings.workIdKey)
            UserDefaults.standard.setValue(newValue?.xCoordinate, forKey: Settings.workXKey)
            UserDefaults.standard.setValue(newValue?.yCoordinate, forKey: Settings.workYKey)
            UserDefaults.standard.setValue(newValue?.name, forKey: Settings.workNameKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    
    static var includeTrainsVariable  = Variable<Bool>(true)
    static var includeSTrainsVariable = Variable<Bool>(true)
    static var includeMetroVariable  = Variable<Bool>(true)
    
    static var includeTrains: Bool {
        get {
            UserDefaults.standard.value(forKey: Settings.includeTrainsKey)
            let val = UserDefaults.standard.bool(forKey: Settings.includeTrainsKey)
            return val
        }
        set {
            includeTrainsVariable.value = newValue
            UserDefaults.standard.setValue(newValue, forKey: Settings.includeTrainsKey)
        }
    }
    
    static var includeSTrains: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Settings.includeSTrainsKey)
        }
        set {
            includeSTrainsVariable.value = newValue
            UserDefaults.standard.setValue(newValue, forKey: Settings.includeSTrainsKey)
        }
    }
    
    static var includeMetro: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Settings.includeMetroKey)
        }
        set {
            includeMetroVariable.value = newValue
            UserDefaults.standard.setValue(newValue, forKey: Settings.includeMetroKey)
        }
    }
    
}
