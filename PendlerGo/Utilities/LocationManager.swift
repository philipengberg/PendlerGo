//
//  LocationManager.swift
//  PendlerGo
//
//  Created by Philip Engberg on 04/01/2019.
//

import CoreLocation
import Foundation
import RxSwift

class LocationManager: NSObject {
    
    // One-to-one mapping of `CLAuthorizationStatus` to avoid
    // dependencies having to import the `CoreLocation` framework
    enum LocationAuthorization {
        case notDetermined       // User has not yet made a choice with regards to this application
        case restricted          // User cannot change this status, and may not have personally denied authorization (Parental controls)
        case denied              // User has explicitly denied authorization
        case authorizedAlways    // User has granted authorization to use their location at any time
        case authorizedWhenInUse // User has granted authorization to use their location only when the app is visible to them
        
        init(coreLocationAuthorization: CLAuthorizationStatus) {
            switch coreLocationAuthorization {
            case .notDetermined:        self = .notDetermined
            case .restricted:           self = .restricted
            case .denied:               self = .denied
            case .authorizedAlways:     self = .authorizedAlways
            case .authorizedWhenInUse:  self = .authorizedWhenInUse
            }
        }
    }
    
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private let geoCoder = CLGeocoder()
    
    private var allRegions: [CLRegion] {
        return [Settings.homeLocation, Settings.workLocation]
            .compactMap { $0 }
            .compactMap { location in
                guard let lat = location.latitude, let long = location.longitude else { return nil }
                return CLCircularRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), radius: 500, identifier: location.id, notifyOnEntry: true, notifyOnExit: false)
        }
    }
    
    private let authorizationSubject = PublishSubject<LocationAuthorization>()
    
    var currentAuthorizationStatus: LocationAuthorization {
        return LocationAuthorization(coreLocationAuthorization: CLLocationManager.authorizationStatus())
    }
    
    override init() {
        super.init()
        
        locationManager.delegate = self
    }
    
    func startMonitoring() {
        guard CLLocationManager.authorizationStatus() == .authorizedAlways else { return }
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }
        allRegions.forEach { locationManager.startMonitoring(for: $0) }
    }
    
    func stopMonitoring() {
        locationManager.monitoredRegions.forEach { locationManager.stopMonitoring(for: $0) }
    }
    
    func requestAutorization() -> Observable<LocationAuthorization> {
        locationManager.requestAlwaysAuthorization()
        return authorizationSubject.asObservable()
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationSubject.onNext(LocationAuthorization(coreLocationAuthorization: status))
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Location - Did start monitoring \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Location - Monitoring did fail \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region.identifier == Settings.homeLocation?.id {
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "pendlergo.check-changes.home")))
        } else if region.identifier == Settings.workLocation?.id {
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "pendlergo.check-changes.work")))
        }
        print("Location - Did enter region \(region.identifier) ")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Location - Did exit region \(region.identifier) ")
    }
}
