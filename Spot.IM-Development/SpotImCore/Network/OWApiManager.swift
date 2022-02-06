//
//  ApiManager.swift
//  SpotImCore
//
//  Created by Eugene on 08.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

protocol OWResponseParser {
    
    associatedtype Representation
    
    /// Parses synchronous
    func parse(object: Any) -> OWResult<Representation>
    func parse(data: Data) -> OWResult<Representation>
    
    
}

public struct OWEmptyParser: OWResponseParser {
    
    init() {}
    
    func parse(object: Any) -> OWResult<Bool> {
        return .success(true)
    }
    
    func parse(data: Data) -> OWResult<Bool> {
        return .success(true)
    }
}

public struct OWJSONParser: OWResponseParser {
    
    struct JSONParserError: Error {}
    
    init() {}
    
    func parse(object: Any) -> OWResult<[String: Any]> {
        guard let json = object as? [String: Any] else { return .failure(JSONParserError()) }
        
        return .success(json)
    }
    
    func parse(data: Data) -> OWResult<[String: Any]> {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers])
            return parse(object: json)
        } catch let error {
            OWLogger.error(error)
            return .failure(error)
        }
        
        
    }
}


struct OWJsonWithoutEscapingSlashesEncoding: ParameterEncoding {
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        guard var urlRequest = urlRequest.urlRequest, let params = parameters else { throw Errors.emptyURLRequest }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: params), let jsonString = String(data: jsonData, encoding: .utf8) else { throw Errors.encodingProblem }
        
        let jsonWithoutEscaping = jsonString.replacingOccurrences(of: "\\/", with: "/")
        urlRequest.httpBody = jsonWithoutEscaping.data(using: .utf8)
        
        return urlRequest
    }
}

extension OWJsonWithoutEscapingSlashesEncoding {
    enum Errors: Error {
        case emptyURLRequest
        case encodingProblem
    }
}

extension OWJsonWithoutEscapingSlashesEncoding.Errors: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .emptyURLRequest: return "Empty url request"
            case .encodingProblem: return "Encoding problem"
        }
    }
}

final class OWApiManager {
    
    typealias APIResponse = (response: HTTPURLResponse?, data: Data?)
    
    var requestDidSucceed: ((SPRequest) -> Void)?
    
    let session: Alamofire.Session
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        let retryableHttpMethods: Set<HTTPMethod> = [.delete, .get, .head, .options, .put, .trace, .post] // Added POST to the default set as most of our requests are POST
        let retryPolicy = RetryPolicy(retryLimit: 3, retryableHTTPMethods: retryableHttpMethods)
        session = Session(configuration: configuration, interceptor: retryPolicy)
    }
    
    @discardableResult
    func execute<T>(request: SPRequest,
                    parameters: [String: Any]? = nil,
                    encoding: ParameterEncoding = JSONEncoding.default,
                    parser: T,
                    headers: HTTPHeaders? = nil,
                    completion: @escaping (_ result: OWResult<T.Representation>, _ response: APIResponse) -> Void) -> DataRequest where T: OWResponseParser {
        
        return session.request(request.url,
                                 method: request.method,
                                 parameters: parameters,
                                 encoding: encoding,
                                 headers: headers)
            .log(level: .medium)
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
