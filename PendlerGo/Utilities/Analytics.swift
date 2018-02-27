//
//  Analytics.swift
//  PendlerGo
//
//  Created by Philip Engberg on 21/09/16.
//
//

import Foundation
import Amplitude_iOS
import CoreLocation

struct Analytics {
    
    static func initialize() {
        Amplitude.instance().initializeApiKey("9cc9a98f97150e75ebbf2fb012aae2bd")
    }
    
    struct Events {
        
        static func trackSettingsButtonTapped() {
            Analytics.Internal.track("Settings button tapped")
        }
        
        static func trackFilterButtonTapped() {
            Analytics.Internal.track("Filter button tapped")
        }
        
        static func trackHelpButtonTapped() {
            Analytics.Internal.track("Help button tapped")
        }
        
        static func trackToggledIncludeTrains(to include: Bool) {
            Analytics.Internal.track("Toggled include Trains", properties: ["Include": include as AnyObject])
        }
        
        static func trackToggledIncludeSTrains(to include: Bool) {
            Analytics.Internal.track("Toggled include S-Trains", properties: ["Include": include as AnyObject])
        }
        
        static func trackToggledIncludeMetro(to include: Bool) {
            Analytics.Internal.track("Toggled include Metro", properties: ["Include": include as AnyObject])
        }
        
        static func trackForceRefreshDepartureBoard(for type: Settings.LocationType) {
            Analytics.Internal.track("Force refreshed departure board", properties: ["Board type": type.eventName as AnyObject])
        }
        
        static func trackForceLoadedMoreDepartures(for type: Settings.LocationType, numberOfExistingDepartures: Int) {
            Analytics.Internal.track("Force loaded more departures", properties: ["Board type": type.eventName as AnyObject, "# of existing departures": numberOfExistingDepartures as AnyObject])
        }
        
        static func trackManuallySwitchedDepartureBoard(to type: Settings.LocationType) {
            Analytics.Internal.track("Manually switched departure board", properties: ["Board type": type.eventName as AnyObject])
        }
        
        static func trackAutomaticallySwitchedDepartureBoard(to type: Settings.LocationType) {
            Analytics.Internal.track("Automatically switched departure board", properties: ["Board type": type.eventName as AnyObject])
        }
        
    }
    
    struct UserState {
        static func updateUser() {
            Analytics.Internal.updateUser()
        }
    }
    
    fileprivate struct Internal {
        
        fileprivate static func updateUser() {
            
            let properties = ["Includes Trains": Settings.includeTrains,
                              "Includes S-Trains": Settings.includeSTrains,
                              "Includes Metro": Settings.includeMetro,
                              "Home": Settings.homeLocation?.name ?? "",
                              "Work": Settings.workLocation?.name ?? "",
                              "Location services enabled": CLLocationManager.authorizationStatus() == .authorizedWhenInUse] as [String : Any]
            
            Amplitude.instance().setUserProperties(properties as [AnyHashable: Any])
        }
        
        fileprivate static func track(_ event: String) {
            Amplitude.instance().logEvent(event)
        }
        
        fileprivate static func track(_ event: String, properties: Dictionary<String, AnyObject>) {
            Amplitude.instance().logEvent(event, withEventProperties: properties)
        }
    }
}
