//
//  BoardViewModel.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import Foundation
import RxSwift
import RxCocoa
import DateToolsSwift
import UserNotifications

class BoardViewModel {
    
    let bag = DisposeBag()
    
    let departures = Variable<[Departure]>([])
    let details = Variable<[JourneyDetail]>([])
    
    
    let locationType: Settings.LocationType
    
    fileprivate var locationId: String? {
        get {
            switch self.locationType {
            case .home: return (Settings.homeLocation ?? Settings.homeLocationVariable.value)?.id
            case .work: return (Settings.workLocation ?? Settings.workLocationVariable.value)?.id
            }
        }
    }
    
    init(locationType: Settings.LocationType) {
        self.locationType = locationType
        
        switch locationType {
        case .home: Settings.homeLocationVariable.asObservable().subscribe(onNext: { (_) -> Void in self.update() }).disposed(by: bag)
        case .work: Settings.workLocationVariable.asObservable().subscribe(onNext: { (_) -> Void in self.update() }).disposed(by: bag)
        }
        
        Observable.from([Settings.includeTrainsVariable.asObservable(), Settings.includeSTrainsVariable.asObservable(), Settings.includeMetroVariable.asObservable()]).merge().subscribe(onNext: { [weak self] (_) in
            self?.update()
        }).disposed(by: bag)
        
        self.departures.asObservable().subscribe(onNext: { (departures) in
//            guard let lastDeparture = departures.last else { return }
//            if lastDeparture.combinedDepartureDateTime.hoursUntil() < 1 {
//                self.loadMore()
//            }
        }).disposed(by: bag)
        
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: "pendlergo.check-changes.work")).subscribe(onNext: { [weak self] _ in
            guard self?.locationType == .work else { return }
            guard let departure = self?.departures.value.first(where: { $0.type == .IC && ($0.departureTime.minute == 39 || $0.departureTime.minute == 30) }) else { return }
            
            let content = UNMutableNotificationContent()
            
            if departure.cancelled {
                content.title = "AFLYST"
                content.body = "\(departure.name) 👉 \(departure.finalStop) kl. \(departure.time) er desværre AFLYST. Tryk her for at se andre afgange."
            } else if let realDepartureTime = departure.realDepartureTime, departure.isDelayed  {
                content.title = "Forsinket"
                content.body = "\(departure.name) 👉 \(departure.finalStop) kl. \(departure.time) er forsinket ca. \(abs(realDepartureTime.minutes(from: departure.departureTime))) minutter. Forventet afgang kl. \(departure.realTime) fra Spor \(departure.realTrack ?? departure.track). Tryk her for at se andre afgange."
            } else {
                content.title = "\(departure.name) 👉 \(departure.finalStop) kl. \(departure.time)"
                content.body = "Kører fra Spor \(departure.realTrack ?? departure.track) om ca. \(abs(departure.departureTime.minutes(from: Date()))) minutter"
            }
            
            content.sound = UNNotificationSound.default
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
        }).disposed(by: bag)
        
    }
    
    func update() {
        
        if let locationId = self.locationId {
            PendlerGoDebugAPI.request(.board(locationId: locationId, offset: 0)).mapJSON().mapToObject(DepartureBoard.self).map({ (board) -> [Departure] in
                
                let departures = board.departures.filter({ (departure) -> Bool in
                    switch departure.transportationType {
                    case .train:
                        return Settings.includeTrainsVariable.value
                    case .sTrain:
                        return Settings.includeSTrainsVariable.value
                    case .metro:
                        return Settings.includeMetroVariable.value
                    default:
                        return false
                    }
                })
                
                var requests: [Observable<JourneyDetail>] = []
                for departure in departures {
                    if departure.hasMessages {
                        requests.append(PendlerGoAPI.request(PendlerGoTarget.detail(ref: departure.detailPath)).filterSuccessfulStatusCodes().mapJSON().mapToObject(JourneyDetail.self))
                    } else {
                        requests.append(Observable.just(JourneyDetail(messages: [Message(header: "", text: "")])))
                    }
                }
                
                Observable.combineLatest(requests, { (details) -> [JourneyDetail] in
                    return details
                }).bind(to: self.details).disposed(by: self.bag)
                
                return departures
                
            }).bind(to: departures).disposed(by: bag)
        }
    }
    
    func loadMore() {
        
        guard let lastDeparture = departures.value.last else { return }
        let offset = lastDeparture.combinedDepartureDateTime.minutesUntil + 2
        
        print("Count=\(departures.value.count): \(Date()) - \(lastDeparture.combinedDepartureDateTime) + \(offset) = \(Date().add(TimeChunk(minutes: offset)))")
        
        if let locationId = self.locationId {
            PendlerGoAPI.request(.board(locationId: locationId, offset: offset)).mapJSON().mapToObject(DepartureBoard.self).map({ (board) -> [Departure] in
                
                let departures = board.departures.filter({ (departure) -> Bool in
                    switch departure.transportationType {
                    case .train:
                        return Settings.includeTrainsVariable.value
                    case .sTrain:
                        return Settings.includeSTrainsVariable.value
                    case .metro:
                        return Settings.includeMetroVariable.value
                    default:
                        return false
                    }
                })
                
                var requests: [Observable<JourneyDetail>] = []
                for departure in departures {
                    if departure.hasMessages {
                        requests.append(PendlerGoAPI.request(PendlerGoTarget.detail(ref: departure.detailPath)).filterSuccessfulStatusCodes().mapJSON().mapToObject(JourneyDetail.self))
                    } else {
                        requests.append(Observable.just(JourneyDetail(messages: [Message(header: "", text: "")])))
                    }
                }
                
                Observable.combineLatest(requests, { (details) -> [JourneyDetail] in
                    return details
                }).subscribe(onNext: { (details) in
                    self.details.value.append(contentsOf: details)
                }).disposed(by: self.bag)
                
                return departures
                
            }).subscribe(onNext: { (departures) in
                self.departures.value.append(contentsOf: departures)
            }).disposed(by: bag)
        }
    }
}
