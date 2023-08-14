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
        var responseArray: [MockUser]!
        var disposeBag: DisposeBag!

        beforeEach {
            session = {
                let mockSessionConfig = URLSessionConfiguration.ephemeral
                mockSessionConfig.protocolClasses = [MockURLProtocol.self]
                let mockSession = OWSession(configuration: mockSessionConfig, interceptor: MockNetworkInterceptor())
                return mockSession
            }()
            environment = OWEnvironment(scheme: "http", domain: "localhost")
            api = OWNetworkAPI(environment: environment, session: session)
            responseArray = []
            disposeBag = DisposeBag()
        }

        afterEach {}

        describe("network api") {
            it("should perform a successful user data request") {
                let (request, requestHandler) = Self.userDataRequest(with: environment)
                let response = Self.userDataResponse(with: api)

                session.register(handler: requestHandler, for: request)

                response.response
                    .subscribe(onNext: { userResponse in
                        responseArray.append(userResponse)
                    })
                    .disposed(by: disposeBag)

                expect(responseArray).toEventually(equal([MockUser(name: "John Doe", age: 30)]))
            }
        }
    }

    private static func userDataRequest(with environment: OWEnvironment) -> (URLRequest, MockURLProtocol.RequestHandler) {
        return (
            try! URLRequest( // swiftlint:disable:this force_try
                url: environment.baseURL.appendingPathComponent(MockUserEndpoint.userData.path),
                method: .get
            ), { request in
                let data = """
                    {
                        "name": "John Doe",
                        "age": 30
                    }
                    """.data(using: .utf8)! // swiftlint:disable:this force_try

                // swiftlint:disable:next force_try
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "2.0", headerFields: nil)!
                return (response, data)
            }
        )
    }

    private static func userDataResponse(with api: OWNetworkAPI) -> OWNetworkResponse<MockUser> {
        return api.performRequest(
            route: api.request(for: MockUserEndpoint.userData),
            decoder: JSONDecoder()
        )
    }
}
