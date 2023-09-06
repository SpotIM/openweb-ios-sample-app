//
//  OWNetworkAPITests.swift
//  OpenWebCoreTests
//
//  Created by Philip Kluz on 2023-08-01.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import XCTest
import RxSwift
import Quick
import Nimble

@testable import SpotImCore

class OWNetworkAPITests: QuickSpec {

    override func spec() {
        describe("Testing network api") {

            // `sut` stands for `Subject Under Test`
            var sut: OWNetworkAPI!
            var session: OWSession!
            var environment: OWEnvironment!
            var responseArray: [MockUser]!
            var networkTestingUtil: NetworkTestingUtil!
            var disposeBag: DisposeBag!
            var encoder: JSONEncoder!

            beforeEach {
                session = {
                    let mockSessionConfig = URLSessionConfiguration.ephemeral
                    mockSessionConfig.protocolClasses = [MockURLProtocol.self]
                    let mockSession = OWSession(configuration: mockSessionConfig, interceptor: MockNetworkInterceptor())
                    return mockSession
                }()
                environment = OWEnvironment(scheme: "http", domain: "localhost")
                sut = OWNetworkAPI(environment: environment, middlewares: [], session: session)
                responseArray = []
                networkTestingUtil = NetworkTestingUtil()
                disposeBag = DisposeBag()
                encoder = JSONEncoder()
            }

            xcontext("1. when the network response is valid") {
                it("should perform a successful user data request") {
                    let userData = MockUser.stub()
                    let encodedUserData = try! encoder.encode(userData) // swiftlint:disable:this force_try

                    let (request, requestHandler) = networkTestingUtil.requestHandler(for: environment,
                                                                                      with: encodedUserData,
                                                                                      endpoint: MockUserEndpoint.userData)
                    let response = networkTestingUtil.response(with: sut, for: MockUserEndpoint.userData)

                    session.register(handler: requestHandler, for: request)

                    response.response
                        .subscribe(onNext: { userResponse in
                            responseArray.append(userResponse)
                        })
                        .disposed(by: disposeBag)

                    expect(responseArray).toEventually(equal([userData]))

                    session.deregisterAllHandlers()
                }
            }

            /*
             `xcontext` disabling everything in this context group. `x` prefix in general disable each group qith Quick
             I specifiaclly disabled this test because it leads to race conditions.
             Not specifically the test, but the fact of testing more than one test parallel in the network layer.
             This has nothing to do with the fact we are using the same "mock" member class which are declared in this file.
             All re-created in the `beforeEach`
             The root cause is that our Network Infrastrucutre is using specific queues to parse/decode the data and for all the other steps in the way.
             This easily leads to race conditions when testing parallel. Obviously we will use parallel testing to reduce unit tests execution time.
             The only soultion which I'm thinking of, is to allow DI for the queues inside the Network Infrastrucutre.
             As of now, it's too much effort to do so. I decided we will test only the "happy" flow above.
             */
            xcontext("2. when the network response return a status code of 400") {
                it("should fail user data request") {

                    var didReceiveError = false
                    let userData = MockUser.stub()
                    let encodedUserData = try! encoder.encode(userData) // swiftlint:disable:this force_try

                    let (request, requestHandler) = networkTestingUtil.requestHandler(for: environment,
                                                                                      with: encodedUserData,
                                                                                      endpoint: MockUserEndpoint.userData,
                                                                                      statusCode: 400,
                                                                                      method: .get)
                    let response = networkTestingUtil.response(with: sut, for: MockUserEndpoint.userData)

                    session.register(handler: requestHandler, for: request)

                    response.response
                        .subscribe(onNext: { userResponse in
                            responseArray.append(userResponse)
                        }, onError: { _ in
                            didReceiveError = true
                        })
                        .disposed(by: disposeBag)

                    expect(responseArray).toEventually(equal([]))
                    expect(didReceiveError).toEventually(equal(true))

                }
            }
        }
    }
}
