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

struct SettingsViewModel {
    
    let bag = DisposeBag()
    
    let locations = Variable<[Location]>([])
    let query = Variable<String>("")
    
    init() {
        query.asObservable().subscribeNext { (query) -> Void in
            self.update()
        }.addDisposableTo(bag)
    }
    
    func update() {
        PendlerGoAPI.request(.Location(query: query.value)).mapJSON().mapToObject(LocationResults).map({ (locationResults) -> [Location] in
            return locationResults.locations
        }).bindTo(locations).addDisposableTo(bag)
    }
    
}