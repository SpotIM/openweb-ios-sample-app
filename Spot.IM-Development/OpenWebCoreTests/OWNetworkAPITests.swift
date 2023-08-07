//
//  OWNetworkAPITests.swift
//  OpenWebCoreTests
//
//  Created by Philip Kluz on 2023-08-01.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
import Quick
import Nimble

@testable import SpotImCore

final class OWNetworkAPITests: QuickSpec {
    
    override func spec() {
        var api: OWNetworkAPI!
        var session: OWSession!
        var environment: OWEnvironment!
        
        beforeEach {
            session = {
                let mockSessionConfig = URLSessionConfiguration.ephemeral
                mockSessionConfig.protocolClasses = [MockURLProtocol.self]
                let mockSession = OWSession(configuration: mockSessionConfig, interceptor: MockNetworkInterceptor())
                return mockSession
            }()
            environment = OWEnvironment(scheme: "http", domain: "localhost")
            api = OWNetworkAPI(environment: environment, session: session)
        }
        
        afterEach {
            session.deregisterAllHandlers()
            session = nil
            environment = nil
            api = nil
        }
        
        describe("OWNetworkAPI") {
            it("should perform a successful request") {
                let request = try! URLRequest(
                    url: environment.baseURL.appending(path: MockUserEndpoint.userData.path),
                    method: .get
                )
                
                let handler: MockURLProtocol.RequestHandler = { request in
                    let data = """
                        {
                            "name": "John Doe",
                            "age": 30
                        }
                        """.data(using: .utf8)!
                    
                    let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "2.0", headerFields: nil)!
                    return (response, data)
                }
                
                session.register(handler: handler, for: request)
                
                let response: OWNetworkResponse<MockUser> = api.performRequest(
                    route: api.request(for: MockUserEndpoint.userData),
                    decoder: JSONDecoder()
                )
                
                let result = try! response.response.toBlocking().first()
                expect(result).to(equal(MockUser(name: "John Doe", age: 30)))
            }
        }
    }
}
