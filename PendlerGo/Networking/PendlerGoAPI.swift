//
//  PendlerGoAPI.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import Foundation
import Moya
import Result


//MARK: Main API

typealias API = RxMoyaProvider<PendlerGoTarget>

let PendlerGoAPI = API (
    endpointClosure : { (target: PendlerGoTarget) -> Endpoint<PendlerGoTarget> in
        var endpoint = MoyaProvider.DefaultEndpointMapping(target)
        return endpoint
    },
    plugins: [NetworkActivityPlugin(networkActivityClosure: { (change) -> () in
        switch change {
        case .Began: UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        case .Ended: UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    })]
)

let PendlerGoDebugAPI = API(stubClosure: { target -> StubBehavior in
    return StubBehavior.Delayed(seconds: 0.5)
    }
)

enum PendlerGoTarget {
    case Board(locationId: String)
    case Location(query: String)
}

extension PendlerGoTarget: TargetType {
    var baseURL : NSURL {
        switch self {
            
        default:
            return NSURL(string: "http://xmlopen.rejseplanen.dk/bin/rest.exe")!
        }
    }
    
    var method : Moya.Method {
        switch self {
        default:
            return .GET
        }
    }
    
    var path : String {
        switch self {
        case .Board:
            return "/departureBoard"
        case .Location(_):
            return "/location"
        }
        
    }
    
    var parameters : [String: AnyObject]? {
        switch self {
        case .Board(let locationId):
            return ["id":locationId, "format":"json", "useBus":false]
        case .Location(let query):
            return ["input":query, "format":"json"]
        }
    }
    
    var sampleData : NSData {
        switch self {
        case .Board:
            let path = NSBundle.mainBundle().pathForResource("KBH", ofType: "json")
            return NSData(contentsOfFile: path!)!
        default:
            return NSData()
        }
    }
}

