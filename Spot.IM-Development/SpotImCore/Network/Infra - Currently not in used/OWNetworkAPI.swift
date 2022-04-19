//
//  OWNetworkAPI.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

protocol OWNetworkAPIProtocol {
    func request(for endpoint: OWEndpoint) -> OWURLRequestConfiguration
}

struct OWResponseType<T> {
    var progress: PublishSubject<Progress>
    var response: Observable<T>
}

private let defaultMiddlewares: [OWMiddleware] = [OWRequestLogger(),
                                                  OWResponseLogger(),
                                                  OWHTTPHeaderRequestMiddleware()]

/*
 OWNetworkAPI purpose is to handle network requests.
 Accept as DI queue name to parse the returned data on and also priority.
 Support middlewares.
 */
class OWNetworkAPI: OWNetworkAPIProtocol {
    let environment: OWEnvironmentProtocol
    let requestMiddlewares: [OWRequestMiddleware]
    let responseMiddlewares: [OWResponseMiddleware]
    let queue: DispatchQueue
    let session: OWSession
    
    init(environment: OWEnvironmentProtocol,
         middlewares: [OWMiddleware] = defaultMiddlewares,
         queueName: String = "OpenWebNetworkQueue",
         queuePriority: DispatchQoS = .userInteractive,
         session: OWSession = OWSession.default) {

        self.environment = environment
        self.queue = DispatchQueue(label: queueName, qos: queuePriority)
        self.session = session
        
        self.requestMiddlewares = middlewares
            .map { $0 as? OWRequestMiddleware }
            .unwrap()

        self.responseMiddlewares = middlewares
            .map { $0 as? OWResponseMiddleware }
            .unwrap()
    }

    private func requestAfterPerformingMiddlewares(with request: URLRequest) -> URLRequest {
        var newRequest = request
        for middleware in requestMiddlewares {
            newRequest = middleware.process(request: newRequest)
        }
        return newRequest
    }

    private func responseAfterPerformingMiddlewares<T: Decodable>(with response: DataResponse<T, AFError>) -> DataResponse<T, AFError> {
        var newResponse = response
        for middleware in responseMiddlewares {
            newResponse = middleware.process(response: newResponse)
        }
        return newResponse
    }

    func request(for endpoint: OWEndpoint) -> OWURLRequestConfiguration {
        return OWURLRequestConfigure(environment: environment,
                                   endpoint: endpoint)
    }

    @discardableResult
    func performRequest<T: Decodable>(route: OWURLRequestConfiguration, decoder: JSONDecoder = JSONDecoder()) -> OWResponseType<T> {
        let progress = PublishSubject<Progress>()

        let request = requestAfterPerformingMiddlewares(with: route.urlRequest!)

        let response = Observable<T>.create { observer in
            let task = self.session.afSession.request(request)
                .downloadProgress(closure: { prog in
                    progress.onNext(prog)
                })
                .responseDecodable(of: T.self, queue: self.queue, dataPreprocessor: DecodableResponseSerializer<T>.defaultDataPreprocessor, decoder: decoder, emptyResponseCodes: DecodableResponseSerializer<T>.defaultEmptyResponseCodes, emptyRequestMethods: DecodableResponseSerializer<T>.defaultEmptyRequestMethods, completionHandler: { [weak self] (response: DataResponse<T, AFError>) in
                    
                    guard let `self` = self else { return }
                    
                    let newResponse = self.responseAfterPerformingMiddlewares(with: response)
                    
                    switch newResponse.result {
                    case .success(let value):
                        observer.onNext(value)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
            return Disposables.create {
                task.cancel()
            }
        }

        return OWResponseType<T>(progress: progress, response: response)
    }
}
