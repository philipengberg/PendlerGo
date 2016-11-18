//
//  SettingsViewModel.swift
//  PendlerGo
//
//  Created by Philip Engberg on 19/02/16.
//
//

import Foundation
import RxSwift
import RxCocoa

class SettingsViewModel {
    
    let bag = DisposeBag()
    
    let locations = Variable<[Location]>([])
    let query = Variable<String>("")
    
    init() {
        query.asObservable().subscribe(onNext: { (query) in
            self.update()
        }).addDisposableTo(bag)
    }
    
    func update() {
        PendlerGoAPI.request(.location(query: query.value)).mapJSON().mapToObject(LocationResults.self).map({ (locationResults) -> [Location] in
            return locationResults.locations
        }).bindTo(locations).addDisposableTo(bag)
    }
    
}
