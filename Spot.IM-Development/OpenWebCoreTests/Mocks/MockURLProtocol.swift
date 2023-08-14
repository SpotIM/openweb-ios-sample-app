//
//  MockURLProtocol.swift
//  OpenWebCoreTests
//
//  Created by Philip Kluz on 2023-08-01.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import XCTest
import RxSwift
@testable import SpotImCore

class MockURLProtocol: URLProtocol {

    struct RequestKey: Hashable {
        var url: URL
        var method: String

        init(request: URLRequest) {
            self.url = request.url!
            self.method = request.httpMethod!
        }
    }

    typealias RequestHandler = (URLRequest) throws -> (HTTPURLResponse, Data)

    fileprivate static var requestHandlers: [RequestKey: RequestHandler] = [:]

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandlers[RequestKey(request: request)] else { return }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // NOOP
    }
}

extension OWSession {

    func register(handler: @escaping MockURLProtocol.RequestHandler, for request: URLRequest) {
        MockURLProtocol.requestHandlers[MockURLProtocol.RequestKey(request: request)] = handler
    }

    func deregisterHandler(for request: URLRequest) {
        MockURLProtocol.requestHandlers[MockURLProtocol.RequestKey(request: request)] = nil
    }

    func deregisterAllHandlers() {
        MockURLProtocol.requestHandlers = [:]
    }
}
