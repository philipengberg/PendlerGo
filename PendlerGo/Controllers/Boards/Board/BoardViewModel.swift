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
import DateTools

class BoardViewModel {
    
    let bag = DisposeBag()
    
    let departures = Variable<[Departure]>([])
    let details = Variable<[JourneyDetail]>([])
    
    
    private let locationType: Settings.LocationType
    
    private var locationId: String? {
        get {
            switch self.locationType {
            case .Home: return (Settings.homeLocation ?? Settings.homeLocationVariable.value)?.id
            case .Work: return (Settings.workLocation ?? Settings.workLocationVariable.value)?.id
            }
        }
    }
    
    init(locationType: Settings.LocationType) {
        self.locationType = locationType
        
        switch locationType {
        case .Home: Settings.homeLocationVariable.asObservable().subscribeNext({ (_) -> Void in self.update() }).addDisposableTo(bag)
        case .Work: Settings.workLocationVariable.asObservable().subscribeNext({ (_) -> Void in self.update() }).addDisposableTo(bag)
        }
        
        [Settings.includeTrainsVariable.asObservable(), Settings.includeSTrainsVariable.asObservable(), Settings.includeMetroVariable.asObservable()].toObservable().merge().subscribeNext { [weak self] (_) in
            self?.update()
        }.addDisposableTo(bag)
        
        self.departures.asObservable().subscribeNext { (departures) in
//            guard let lastDeparture = departures.last else { return }
//            if lastDeparture.combinedDepartureDateTime.hoursUntil() < 1 {
//                self.loadMore()
//            }
        }.addDisposableTo(bag)
        
    }
    
    func update() {
        
        if let locationId = self.locationId {
            PendlerGoAPI.request(.Board(locationId: locationId, offset: 0)).mapJSON().mapToObject(DepartureBoard).map({ (board) -> [Departure] in
                
                let departures = board.departures.filter({ (departure) -> Bool in
                    switch departure.transportationType {
                    case .Train:
                        return Settings.includeTrainsVariable.value
                    case .STrain:
                        return Settings.includeSTrainsVariable.value
                    case .Metro:
                        return Settings.includeMetroVariable.value
                    default:
                        return false
                    }
                })
                
                var requests: [Observable<JourneyDetail>] = []
                for departure in departures {
                    if departure.hasMessages {
                        requests.append(PendlerGoAPI.request(PendlerGoTarget.Detail(ref: departure.detailPath)).filterSuccessfulStatusCodes().mapJSON().mapToObject(JourneyDetail))
                    } else {
                        requests.append(Observable.just(JourneyDetail(messages: [Message(header: "", text: "")])))
                    }
                }
                
                requests.combineLatest({ (details) -> [JourneyDetail] in
                    return details
                }).bindTo(self.details).addDisposableTo(self.bag)
                
                return departures
                
            }).bindTo(departures).addDisposableTo(bag)
        }
    }
    
    func loadMore() {
        
        guard let lastDeparture = departures.value.last else { return }
        let offset = Int(ceil(lastDeparture.combinedDepartureDateTime.minutesUntil())) + 1
        
        print("Count=\(departures.value.count): \(NSDate()) - \(lastDeparture.combinedDepartureDateTime) + \(offset) = \(NSDate().dateByAddingMinutes(offset))")
        
        if let locationId = self.locationId {
            PendlerGoAPI.request(.Board(locationId: locationId, offset: offset)).mapJSON().mapToObject(DepartureBoard).map({ (board) -> [Departure] in
                
                let departures = board.departures.filter({ (departure) -> Bool in
                    switch departure.transportationType {
                    case .Train:
                        return Settings.includeTrainsVariable.value
                    case .STrain:
                        return Settings.includeSTrainsVariable.value
                    case .Metro:
                        return Settings.includeMetroVariable.value
                    default:
                        return false
                    }
                })
                
                var requests: [Observable<JourneyDetail>] = []
                for departure in departures {
                    if departure.hasMessages {
                        requests.append(PendlerGoAPI.request(PendlerGoTarget.Detail(ref: departure.detailPath)).filterSuccessfulStatusCodes().mapJSON().mapToObject(JourneyDetail))
                    } else {
                        requests.append(Observable.just(JourneyDetail(messages: [Message(header: "", text: "")])))
                    }
                }
                
                requests.combineLatest({ (details) -> [JourneyDetail] in
                    return details
                }).subscribeNext({ (details) in
                    self.details.value.appendContentsOf(details)
                }).addDisposableTo(self.bag)
                
                return departures
                
            }).subscribeNext({ (departures) in
                self.departures.value.appendContentsOf(departures)
            }).addDisposableTo(bag)
        }
    }
}