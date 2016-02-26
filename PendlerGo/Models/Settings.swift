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
    
    static var sharedSettings = Settings()
    
    private static let homeIdKey   = "homeId"
    private static let homeNameKey = "homeName"
    private static let workIdKey   = "workd"
    private static let workNameKey = "workName"
    
    mutating func initialize() {
        homeLocation = homeLocation
        workLocation = workLocation
    }
    
    var homeLocationVariable = Variable<Location?>(nil)
    var workLocationVariable = Variable<Location?>(nil)
    
    var homeLocation: Location? {
        get {
            if
                let id = NSUserDefaults.standardUserDefaults().stringForKey(Settings.homeIdKey),
                let name =  NSUserDefaults.standardUserDefaults().stringForKey(Settings.homeNameKey) {
                    return Location(
                        name: name,
                        xCoordinate: "",
                        yCoordinate: "",
                        id: id)
            }
            return nil
        }
        set {
            homeLocationVariable.value = newValue
            NSUserDefaults.standardUserDefaults().setValue(newValue?.id, forKey: Settings.homeIdKey)
            NSUserDefaults.standardUserDefaults().setValue(newValue?.name, forKey: Settings.homeNameKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var workLocation: Location? {
        get {
            if
                let id = NSUserDefaults.standardUserDefaults().stringForKey(Settings.workIdKey),
                let name =  NSUserDefaults.standardUserDefaults().stringForKey(Settings.workNameKey) {
                    return Location(
                        name: name,
                        xCoordinate: "",
                        yCoordinate: "",
                        id: id)
            }
            return nil
        }
        set {
            workLocationVariable.value = newValue
            NSUserDefaults.standardUserDefaults().setValue(newValue?.id, forKey: Settings.workIdKey)
            NSUserDefaults.standardUserDefaults().setValue(newValue?.name, forKey: Settings.workNameKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
}