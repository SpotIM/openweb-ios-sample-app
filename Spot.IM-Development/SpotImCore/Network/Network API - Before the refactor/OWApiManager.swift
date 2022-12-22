//
//  ApiManager.swift
//  SpotImCore
//
//  Created by Eugene on 08.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

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
    
    fileprivate let servicesProvider: OWSharedServicesProviding
    
    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }
    
    func parse(object: Any) -> OWResult<[String: Any]> {
        guard let json = object as? [String: Any] else { return .failure(JSONParserError()) }
        
        return .success(json)
    }
    
    func parse(data: Data) -> OWResult<[String: Any]> {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers])
            return parse(object: json)
        } catch let error {
            servicesProvider.logger().log(level: .error, error.localizedDescription)
            return .failure(error)
        }
        
        
    }
}


struct OWJsonWithoutEscapingSlashesEncoding: OWNetworkParameterEncoding {
    func encode(_ urlRequest: OWNetworkURLRequestConvertible, with parameters: OWNetworkParameters?) throws -> URLRequest {
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
    
    let session: OWNetworkSession
    fileprivate let networkInterceptor: OWNetworkInterceptorLayer
    
    init(networkInterceptor: OWNetworkInterceptorLayer = OWNetworkInterceptorLayer()) {
        self.networkInterceptor = networkInterceptor
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        session = OWNetworkSession(configuration: configuration, interceptor: networkInterceptor)
    }
    
    @discardableResult
    func execute<T>(request: SPRequest,
                    parameters: [String: Any]? = nil,
                    encoding: OWNetworkParameterEncoding = OWNetworkJSONEncoding.default,
                    parser: T,
                    headers: OWNetworkHTTPHeaders? = nil,
                    completion: @escaping (_ result: OWResult<T.Representation>, _ response: APIResponse) -> Void) -> OWNetworkDataRequest where T: OWResponseParser {
        
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
                
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(SPNetworkError.missingStatusCode), (response.response, response.data))
                    return
                }
                
                let isEmptyResponseStatusCode = OWNetworkStatusCode.emptyResponseSucceededStatusCodes.contains(statusCode)
                let isResponseDataExist = response.data != nil
                
                guard isEmptyResponseStatusCode || isResponseDataExist else {
                    completion(.failure(SPNetworkError.emptyResponse), (response.response, response.data))
                    return
                }
                
                self?.requestDidSucceed?(request)
                completion(parser.parse(data: response.data ?? Data()), (response.response, response.data))
            }
    }
}
