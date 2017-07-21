//
//  TodayViewModel.swift
//  PendlerGo
//
//  Created by Philip Engberg on 20/07/2017.
//
//

import Foundation
import RxSwift
import RxCocoa
import DateTools

class TodayViewModel {
    
    let bag = DisposeBag()
    
    let departures = Variable<[Departure]>([])
    
    
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
        case .home: Settings.homeLocationVariable.asObservable().subscribe(onNext: { (_) -> Void in self.update() }).addDisposableTo(bag)
        case .work: Settings.workLocationVariable.asObservable().subscribe(onNext: { (_) -> Void in self.update() }).addDisposableTo(bag)
        }
        
        Observable.from([Settings.includeTrainsVariable.asObservable(), Settings.includeSTrainsVariable.asObservable(), Settings.includeMetroVariable.asObservable()]).merge().subscribe(onNext: { [weak self] (_) in
            self?.update()
        }).addDisposableTo(bag)
        
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
                
                return departures
                
            }).bind(to: departures).addDisposableTo(bag)
        }
    }
}
