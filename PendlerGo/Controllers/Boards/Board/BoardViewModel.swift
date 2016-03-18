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

struct BoardViewModel {
    
    let bag = DisposeBag()
    
    let departures = Variable<[Departure]>([])
    let details = Variable<[JourneyDetail]>([])
    
    private let locationType: Settings.LocationType
    
    private var locationId: String? {
        get {
            switch self.locationType {
            case .Home: return (Settings.sharedSettings.homeLocation ?? Settings.sharedSettings.homeLocationVariable.value)?.id
            case .Work: return (Settings.sharedSettings.workLocation ?? Settings.sharedSettings.workLocationVariable.value)?.id
            }
        }
    }
    
    init(locationType: Settings.LocationType) {
        self.locationType = locationType
        
        switch locationType {
        case .Home: Settings.sharedSettings.homeLocationVariable.asObservable().subscribeNext({ (_) -> Void in self.update() }).addDisposableTo(bag)
        case .Work: Settings.sharedSettings.workLocationVariable.asObservable().subscribeNext({ (_) -> Void in self.update() }).addDisposableTo(bag)
        }
        
    }
    
    func update() {
        
        
        if let locationId = self.locationId {
            PendlerGoAPI.request(.Board(locationId: locationId)).mapJSON().mapToObject(DepartureBoard).map({ (board) -> [Departure] in
                
                var requests: [Observable<JourneyDetail>] = []
                
                for departure in board.departures {
                    if departure.hasMessages {
                        requests.append(PendlerGoAPI.request(PendlerGoTarget.Detail(ref: departure.detailPath)).filterSuccessfulStatusCodes().mapJSON().mapToObject(JourneyDetail))
                    } else {
                        requests.append(Observable.just(JourneyDetail(messages: [Message(header: "", text: "")])))
                    }
                }
                
                requests.combineLatest({ (details) -> [JourneyDetail] in
                    return details
                }).bindTo(self.details).addDisposableTo(self.bag)
                
                return board.departures
                
            }).bindTo(departures).addDisposableTo(bag)
        }
    }
}