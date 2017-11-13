//
//  ComplicationViewModel.swift
//  PendlerGo
//
//  Created by Philip Engberg on 22/07/2017.
//
//

import Foundation
import RxSwift
import RxSwiftExt
import WatchConnectivity

class ComplicationViewModel: NSObject {
    
    let bag = DisposeBag()
    
    var departures = [Departure]()
    
    var session: WCSession = WCSession.default()
    
    let locationType: Settings.LocationType
    
    var locationId: String? = nil
    
    init(locationType: Settings.LocationType) {
        self.locationType = locationType
        
        super.init()
        
        session.delegate = self
        session.activate()
        
        update()
    }
    
    func update() {
        guard let locationId = locationId else { return }
        PendlerGoAPI.request(.board(locationId: locationId, offset: 0)).mapJSON().mapToObject(DepartureBoard.self).map({ $0.departures }).subscribe(onNext: { [weak self] (departures) in
            print("Got data \(departures.count)")
            self?.departures = departures
        }).addDisposableTo(self.bag)
    }
    
    func getFirstDeparture(after date: Date) -> Departure? {
        print("Searching first out of \(departures.count)")
        return departures.first { (departure) -> Bool in
            return departure.combinedDepartureDateTime.timeIntervalSince(date) >= 0
        }
    }
    
    func getAllDepartures(after date: Date) -> [Departure] {
        guard let firstIndex = departures.index(where: { (departure) -> Bool in
            return departure.combinedDepartureDateTime.timeIntervalSince(date) >= 0
        }) else { return [] }
        
        return Array(departures[firstIndex..<departures.count])
    }
}

extension ComplicationViewModel : WCSessionDelegate {
    
    @available(watchOS 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        if let homeId = UserDefaults.standard.string(forKey: "homeId") {
            self.locationId = homeId
            self.update()
        } else {
            print("Sending message")
            session.sendMessage(["request": "homeId"], replyHandler: { (reply) in
                print("Got reply")
                if let homeId = reply["homeId"] as? String {
                    UserDefaults.standard.set(homeId, forKey: "homeId")
                    self.locationId = homeId
                    self.update()
                }
            }) { (error) in
                print("Error: \(error)")
            }
        }
    }
    
}
