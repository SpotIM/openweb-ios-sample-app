//
//  ApiManager.swift
//  SpotImCore
//
//  Created by Eugene on 08.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

protocol ResponseParser {
    
    associatedtype Representation
    
    /// Parses synchronous
    func parse(object: Any) -> Result<Representation>
    func parse(data: Data) -> Result<Representation>
    
    
}

public struct EmptyParser: ResponseParser {
    
    init() {}
    
    func parse(object: Any) -> Result<Bool> {
        return .success(true)
    }
    
    func parse(data: Data) -> Result<Bool> {
        return .success(true)
    }
}

public struct JSONParser: ResponseParser {
    
    struct JSONParserError: Error {}
    
    init() {}
    
    func parse(object: Any) -> Result<[String: Any]> {
        guard let json = object as? [String: Any] else { return .failure(JSONParserError()) }
        
        return .success(json)
    }
    
    func parse(data: Data) -> Result<[String: Any]> {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers])
            return parse(object: json)
        } catch let error {
            Logger.error(error)
            return .failure(error)
        }
        
        
    }
}

final class ApiManager {
    
    typealias APIResponse = (response: HTTPURLResponse?, data: Data?)
    
    var requestDidSucceed: ((SPRequest) -> Void)?
    
    @discardableResult
    func execute<T>(request: SPRequest,
                    parameters: [String: Any]? = nil,
                    encoding: ParameterEncoding = JSONEncoding.default,
                    parser: T,
                    headers: [String: String]? = nil,
                    completion: @escaping (_ result: Result<T.Representation>, _ response: APIResponse) -> Void) -> DataRequest where T: ResponseParser {
        
        return Alamofire.request(request.url,
                                 method: request.method,
                                 parameters: parameters,
                                 encoding: encoding,
                                 headers: headers)
            .validate()
            .responseData { [weak self] response in
                
                guard response.error == nil else {
                    completion(.failure(response.error!), (response.response, response.data))
                    return
                }
                
                guard let responseData = response.data else {
                    completion(.failure(SPNetworkError.emptyResponse), (response.response, response.data))
                    return
                }
               
                self?.requestDidSucceed?(request)
                completion(parser.parse(data: responseData), (response.response, response.data))
            }
    }
    
}
