//
//  ModelExtensions.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import Foundation
import RxSwift
import SwiftyJSON

typealias JSONDict = [String : Any]

protocol JSONAble {
    associatedtype T
    static func fromJSON(_ : JSONDict) -> Self?
}

extension Observable {
    
    func mapToObject <T : JSONAble> (_ type : T.Type) -> Observable<T> {
        return flatMap{ response -> Observable <T> in
            if let json = response as? JSONDict {
                if let result = type.fromJSON(json) {
                    return Observable<T>.just(result)
                }
            }
            return Observable<T>.empty()
        }
    }
    
    func mapToObjects <T : JSONAble> (_ type : T.Type) -> Observable<[T]> {
        return flatMap{ response -> Observable < [T]> in
            if let json = response as? [JSONDict] {
                let results = json.compactMap({ (dict) -> T? in
                        return type.fromJSON(dict)
                    })
                    return Observable<[T]>.just(results)
            }
            return Observable<[T]>.empty()
        }
    }
}
