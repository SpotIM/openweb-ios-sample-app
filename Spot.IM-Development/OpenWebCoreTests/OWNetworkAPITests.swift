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
@testable import SpotImCore

class OWNetworkAPITests: XCTestCase {
    
    enum MockUserEndpoint: OWEndpoints {
        case userData
        
        var method: OWNetworkHTTPMethod {
            switch self {
            case .userData:
                return .get
            }
        }

        var path: String {
            switch self {
            case .userData:
                return "/user/data"
            }
        }

        var parameters: OWNetworkParameters? {
            switch self {
            case .userData:
                return nil
            }
        }
    }
    
    struct MockUser: Codable, Equatable {
        var name: String
        var age : Int
    }
    
    var api: OWNetworkAPI!
    var session: OWSession!
    var environment: OWEnvironment!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        session = {
            let mockSessionConfig = URLSessionConfiguration.ephemeral
            mockSessionConfig.protocolClasses = [MockURLProtocol.self]
            let mockSession = OWSession(configuration: mockSessionConfig, interceptor: MockNetworkInterceptor())
            return mockSession
        }()
        environment = OWEnvironment(scheme: "http", domain: "localhost")
        api = OWNetworkAPI(environment: environment, session: session)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        session.deregisterAllHandlers()
        session = nil
        environment = nil
        api = nil
        disposeBag = nil
        super.tearDown()
    }
    
    private func GETRequest(for endpoint: OWEndpoints, with environment: OWEnvironment) -> URLRequest {
        return try! URLRequest(url: environment.baseURL.appending(path: endpoint.path), method: .get)
    }
    
    func testPerformRequestSuccess() {
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
        
        session.register(handler: handler, for: GETRequest(for: MockUserEndpoint.userData, with: environment))
        
        let response: OWNetworkResponse<MockUser> = api.performRequest(
            route: api.request(for: MockUserEndpoint.userData),
            decoder: JSONDecoder()
        )
        
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(MockUser.self)
        
        response.response
            .asObservable()
            .bind(to: observer)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(observer.events, [
            .next(0, MockUser(name: "John Doe", age: 30)),
            .completed(0)
        ])
    }
}
