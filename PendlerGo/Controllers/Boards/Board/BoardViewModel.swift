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
        
    }
    
    func update() {
        
        if let locationId = self.locationId {
            PendlerGoAPI.request(.board(locationId: locationId, offset: 0)).mapJSON().mapToObject(DepartureBoard.self).map({ (board) -> [Departure] in
                
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
        let offset = Int(ceil((lastDeparture.combinedDepartureDateTime as NSDate).minutesUntil())) + 1
        
        print("Count=\(departures.value.count): \(Date()) - \(lastDeparture.combinedDepartureDateTime) + \(offset) = \((Date() as NSDate).addingMinutes(offset))")
        
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
