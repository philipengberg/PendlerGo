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
        var endpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return endpoint
    },
    plugins: [Logger(), NetworkActivityPlugin(networkActivityClosure: { (change) -> () in
        switch change {
        case .began: UIApplication.shared.isNetworkActivityIndicatorVisible = true
        case .ended: UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    })]
)

let PendlerGoDebugAPI = API(stubClosure: { target -> StubBehavior in
    return StubBehavior.delayed(seconds: 0.5)
    }
)

private class Logger : PluginType {
    
    fileprivate func willSendRequest(_ request: RequestType, target: TargetType) {
        
    }
    
    fileprivate func didReceiveResponse(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        switch result {
            
        case .success(let response):
            if let params = target.parameters {
                print("\(response.statusCode): \(target.method) - \(target.path) (\(params))")
            } else {
                print("\(response.statusCode): \(target.method) - \(target.path)")
            }
        default: break
        }
    }
}

enum PendlerGoTarget {
    case board(locationId: String, offset: Int)
    case location(query: String)
    case detail(ref: String)
}

extension PendlerGoTarget: TargetType {
    var baseURL : URL {
        switch self {
            
        default:
            return URL(string: "http://xmlopen.rejseplanen.dk/bin/rest.exe")!
        }
    }
    
    var method : Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    var path : String {
        switch self {
        case .board:
            return "/departureBoard"
        case .location(_):
            return "/location"
        case .detail(_):
            return "/journeyDetail"
        }
        
    }
    
    var parameters : [String: Any]? {
        switch self {
        case .board(let locationId, let offset):
            return ["id":locationId, "format":"json", "useBus":false, "offsetTime": offset]
        case .location(let query):
            return ["input":query, "format":"json"]
        case .detail(let ref):
            return ["ref": ref]
//        default:
//            return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    var multipartBody: [MultipartFormData]? {
        return nil
    }
    
    var sampleData : Data {
        switch self {
        case .board:
            let path = Bundle.main.path(forResource: "KBH", ofType: "json")
            return (try! Data(contentsOf: URL(fileURLWithPath: path!)))
        case .detail(_):
            let path = Bundle.main.path(forResource: "Detail", ofType: "json")
            return (try! Data(contentsOf: URL(fileURLWithPath: path!)))
        default:
            return Data()
        }
    }
    
    var task: Task {
        switch self {
        default: return .request
        }
    }
}

