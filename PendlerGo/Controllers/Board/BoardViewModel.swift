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
    
    func update() {
        PendlerGoAPI.request(.Board).mapJSON().mapToObject(DepartureBoard).map({ (board) -> [Departure] in
            return board.departures
        }).bindTo(departures).addDisposableTo(bag)
    }
}