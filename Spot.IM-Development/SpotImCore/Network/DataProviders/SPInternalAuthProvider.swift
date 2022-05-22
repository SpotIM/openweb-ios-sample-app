//
//  SPInternalAuthProvider.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 25/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import RxSwift

protocol SPInternalAuthProvider {
    func login() -> Observable<String>
    func logout() -> Observable<Void>
    func user(enableRetry: Bool) -> Observable<SPUser>
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
            
            var headers = HTTPHeaders.basic(with: spotKey)
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
            
            var headers = HTTPHeaders.basic(with: spotKey)
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
    func user(enableRetry: Bool = true) -> Observable<SPUser> {
        return Observable<(Retry<SPUser>)>.create { [weak self] observer in
            guard let self = self, let spotKey = SPClientSettings.main.spotKey else {
                let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
                observer.onError(SPNetworkError.custom(message))
                return Disposables.create()
            }
            
            let spRequest = SPInternalAuthRequests.user
            let headers = HTTPHeaders.basic(with: spotKey)
            
            let task = self.manager.execute(
                request: spRequest,
                parser: OWDecodableParser<SPUser>(),
                headers: headers
            ) { [weak self] result, response in
                switch result {
                case .success(let user):
                    SPUserSessionHolder.updateSession(with: response.response)
                    SPUserSessionHolder.updateSessionUser(user: user)
                    observer.onNext(Retry<SPUser>.value(user))
                    observer.onCompleted()
                case .failure(let error):
                    if let self = self,
                        enableRetry,
                        let afError = error .asAFError,
                        let code = afError.responseCode,
                        code == APIErrorCodes.authorizationErrorCode {
                        self.servicesProvider.logger().log(level: .error, "Network request to '/user/data' got error code: \(code), might be an expired token. Trying to recover with a new request")
                        SPUserSessionHolder.resetUserSession()
                        observer.onNext(Retry<SPUser>.retry)
                        observer.onCompleted()
                    } else {
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
            }
            
            return Disposables.create {
                task.cancel()
            }
        }
        .flatMapLatest { [weak self] retryValue -> Observable<SPUser> in
            guard let self = self else { return .empty() }
            switch retryValue {
            case .value(let user):
                return .just(user)
            case .retry:
                return self.user(enableRetry: false) // Trying only one more time in case we failed auth
                    .do { _ in
                        // We received a new guest user, however we should signal publishers to renew SSO authentication
                    }
            }
        }
    }
}
