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
import RxSwiftExt

class SettingsViewModel {
    
    let bag = DisposeBag()
    
    let locations = Variable<[Location]>([])
    let query = Variable<String?>(nil)
    
    init() {
        query
            .asObservable()
            .unwrap()
            .distinctUntilChanged()
            .flatMapLatest { query -> Observable<[Location]> in
                PendlerGoAPI.request(.location(query: query)).filterSuccessfulStatusCodes().mapJSON().mapToObject(LocationResults.self).map({ (locationResults) -> [Location] in
                    return locationResults.locations
                })
            }.bind(to: locations)
            .disposed(by: bag)
    }
}
