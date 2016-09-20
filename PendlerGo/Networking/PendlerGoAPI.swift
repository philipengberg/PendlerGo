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
    plugins: [Logger(), NetworkActivityPlugin(networkActivityClosure: { (change) -> () in
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

private class Logger : PluginType {
    
    private func willSendRequest(request: RequestType, target: TargetType) {
        
    }
    
    private func didReceiveResponse(result: Result<Moya.Response, Moya.Error>, target: TargetType) {
        switch result {
            
        case .Success(let response):
            if let params = target.parameters {
//                print("\(response.statusCode): \(target.method) - \(target.path) (\(params))")
            } else {
//                print("\(response.statusCode): \(target.method) - \(target.path)")
            }
        default: break
        }
    }
}

enum PendlerGoTarget {
    case Board(locationId: String, offset: Int)
    case Location(query: String)
    case Detail(ref: String)
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
        case .Detail(_):
            return "/journeyDetail"
        }
        
    }
    
    var parameters : [String: AnyObject]? {
        switch self {
        case .Board(let locationId, let offset):
            return ["id":locationId, "format":"json", "useBus":false, "offsetTime": offset]
        case .Location(let query):
            return ["input":query, "format":"json"]
        case .Detail(let ref):
            return ["ref": ref]
//        default:
//            return nil
        }
    }
    
    var multipartBody: [MultipartFormData]? {
        return nil
    }
    
    var sampleData : NSData {
        switch self {
        case .Board:
            let path = NSBundle.mainBundle().pathForResource("KBH", ofType: "json")
            return NSData(contentsOfFile: path!)!
        case .Detail(_):
            let path = NSBundle.mainBundle().pathForResource("Detail", ofType: "json")
            return NSData(contentsOfFile: path!)!
        default:
            return NSData()
        }
    }
}

