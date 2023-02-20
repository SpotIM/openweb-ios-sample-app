//
//  SPInternalAuthProvider.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 25/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol SPInternalAuthProvider {
    func login() -> Observable<String>
    func logout() -> Observable<Void>
    func user() -> Observable<SPUser>
}

final class SPDefaultInternalAuthProvider: NetworkDataProvider, SPInternalAuthProvider {

    func login() -> Observable<String> {
        return Observable<String>.create { [weak self] observer in
            guard let self = self, let spotKey = SPClientSettings.main.spotKey else {
                let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
                observer.onError(SPNetworkError.custom(message))
                return Disposables.create()
            }

            let spRequest = SPInternalAuthRequests.guest

            var headers = OWNetworkHTTPHeaders.basic(with: spotKey)
            if let token = SPUserSessionHolder.session.token {
                headers[APIHeadersConstants.authorization] = token
            }

            let task = self.manager.execute(
                request: spRequest,
                parser: OWDecodableParser<SPUser>(),
                headers: headers
            ) { result, response in
                guard let token = response.response?.allHeaderFields.authorizationHeader ?? SPUserSessionHolder.session.token else {
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: nil,
                        errorData: response.data,
                        errorMessage: "Authorization header empty"
                    )
                    SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                    observer.onError(SPNetworkError.default)
                    return
                }

                switch result {
                case .success(let user):
                    SPUserSessionHolder.updateSession(with: response.response)
                    SPUserSessionHolder.updateSessionUser(user: user)
                    observer.onNext(token)
                    observer.onCompleted()
                case .failure(let error):
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: nil,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                    observer.onError(error)
                }
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }

    func logout() -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self, let spotKey = SPClientSettings.main.spotKey else {
                let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
                observer.onError(SPNetworkError.custom(message))
                return Disposables.create()
            }

            let spRequest = SPInternalAuthRequests.logout

            var headers = OWNetworkHTTPHeaders.basic(with: spotKey)
            if let token = SPUserSessionHolder.session.token {
                headers[APIHeadersConstants.authorization] = token
            }

            let task = self.manager.execute(
                request: spRequest,
                parser: OWEmptyParser(),
                headers: headers
            ) { result, response in
                switch result {
                case .success:
                    SPUserSessionHolder.resetUserSession()
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: nil,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                    observer.onError(error)
                }
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }

    // `enableRetry` used to recover from expired token / unauthorized user to enable the publishers (SDK users) to re-login / SSO after we fallback to some defualt guest user
    func user() -> Observable<SPUser> {
        return Observable<SPUser>.create { [weak self] observer in
            guard let self = self, let spotKey = SPClientSettings.main.spotKey else {
                let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
                observer.onError(SPNetworkError.custom(message))
                return Disposables.create()
            }

            let spRequest = SPInternalAuthRequests.user
            let headers = OWNetworkHTTPHeaders.basic(with: spotKey)

            let task = self.manager.execute(
                request: spRequest,
                parser: OWDecodableParser<SPUser>(),
                headers: headers
            ) { result, response in
                switch result {
                case .success(let user):
                    SPUserSessionHolder.updateSession(with: response.response)
                    SPUserSessionHolder.updateSessionUser(user: user)
                    observer.onNext(user)
                    observer.onCompleted()
                case .failure(let error):
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: nil,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                    observer.onError(error)
                }
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }
}
