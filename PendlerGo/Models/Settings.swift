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
    
    private static let appGroupName = "group.com.simplesense.pendlergo.sharedDefaults"
    private static let defaults = UserDefaults(suiteName: appGroupName)
    
    static func initialize() {
        
        migrateUserDefaultsToAppGroups()
        
        if defaults?.value(forKey: Settings.includeTrainsKey) == nil {
            defaults?.setValue(true, forKey: Settings.includeTrainsKey)
        }
        
        if defaults?.value(forKey: Settings.includeSTrainsKey) == nil {
            defaults?.setValue(true, forKey: Settings.includeSTrainsKey)
        }
        
        if defaults?.value(forKey: Settings.includeMetroKey) == nil {
            defaults?.setValue(true, forKey: Settings.includeMetroKey)
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
                let id = defaults?.string(forKey: Settings.homeIdKey),
                let x = defaults?.string(forKey: Settings.homeXKey),
                let y = defaults?.string(forKey: Settings.homeYKey),
                let name =  defaults?.string(forKey: Settings.homeNameKey) {
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
            defaults?.setValue(newValue?.id, forKey: Settings.homeIdKey)
            defaults?.setValue(newValue?.xCoordinate, forKey: Settings.homeXKey)
            defaults?.setValue(newValue?.yCoordinate, forKey: Settings.homeYKey)
            defaults?.setValue(newValue?.name, forKey: Settings.homeNameKey)
            defaults?.synchronize()
        }
    }
    
    static var workLocation: Location? {
        get {
            if
                let id = defaults?.string(forKey: Settings.workIdKey),
                let x = defaults?.string(forKey: Settings.workXKey),
                let y = defaults?.string(forKey: Settings.workYKey),
                let name =  defaults?.string(forKey: Settings.workNameKey) {
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
            defaults?.setValue(newValue?.id, forKey: Settings.workIdKey)
            defaults?.setValue(newValue?.xCoordinate, forKey: Settings.workXKey)
            defaults?.setValue(newValue?.yCoordinate, forKey: Settings.workYKey)
            defaults?.setValue(newValue?.name, forKey: Settings.workNameKey)
            defaults?.synchronize()
        }
    }
    
    
    static var includeTrainsVariable  = Variable<Bool>(true)
    static var includeSTrainsVariable = Variable<Bool>(true)
    static var includeMetroVariable  = Variable<Bool>(true)
    
    static var includeTrains: Bool {
        get {
            return defaults?.bool(forKey: Settings.includeTrainsKey) ?? false
        }
        set {
            includeTrainsVariable.value = newValue
            defaults?.setValue(newValue, forKey: Settings.includeTrainsKey)
        }
    }
    
    static var includeSTrains: Bool {
        get {
            return defaults?.bool(forKey: Settings.includeSTrainsKey) ?? false
        }
        set {
            includeSTrainsVariable.value = newValue
            defaults?.setValue(newValue, forKey: Settings.includeSTrainsKey)
        }
    }
    
    static var includeMetro: Bool {
        get {
            return defaults?.bool(forKey: Settings.includeMetroKey) ?? false
        }
        set {
            includeMetroVariable.value = newValue
            defaults?.setValue(newValue, forKey: Settings.includeMetroKey)
        }
    }
    
    static func migrateUserDefaultsToAppGroups() {
        
        // User Defaults - Old
        let userDefaults = UserDefaults.standard
        
        // App Groups Default - New
        let groupDefaults = UserDefaults(suiteName: appGroupName)
        
        // Key to track if we migrated
        let didMigrateToAppGroups = "DidMigrateToAppGroups"
        
        if let groupDefaults = groupDefaults {
            if !groupDefaults.bool(forKey: didMigrateToAppGroups) {
                for key in userDefaults.dictionaryRepresentation().keys {
                    groupDefaults.set(userDefaults.dictionaryRepresentation()[key], forKey: key)
                }
                groupDefaults.set(true, forKey: didMigrateToAppGroups)
                groupDefaults.synchronize()
                print("Successfully migrated defaults")
            } else {
                print("No need to migrate defaults")
            }
        } else {
            print("Unable to create NSUserDefaults with given app group")
        }
        
    }
    
}
