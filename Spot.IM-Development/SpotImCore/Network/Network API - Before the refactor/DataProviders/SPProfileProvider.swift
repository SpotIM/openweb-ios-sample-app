//
//  SPProfileProvider.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 09/06/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

internal final class SPProfileProvider: NetworkDataProvider {

    func getSingleUseToken() -> Observable<String?> {
        return Observable.create { [weak self] observer in
            guard let self = self, let spotKey = SPClientSettings.main.spotKey else {
                let message = LocalizationManager.localizedString(key: "Please provide Spot Key")
                observer.onError(SPNetworkError.custom(message))
                return Disposables.create()
            }

            let spRequest = SPProfileRequest.createSingleUseToken
            let headers = OWNetworkHTTPHeaders.basic(with: spotKey)
            var requestParams: [String: Any] = ["access_token": SPUserSessionHolder.session.token?.replacingOccurrences(of: "Bearer ", with: "")]
            if let openwebToken = SPUserSessionHolder.session.openwebToken {
                requestParams["open_web_token"] = openwebToken
            }

            let task = self.manager.execute(
                request: spRequest,
                parameters: requestParams,
                parser: OWDecodableParser<[String: String]>(),
                headers: headers
            ) { result, response in
                switch result {
                case .success(let dictionary):
                    observer.onNext(dictionary["single_use_token"])
                    observer.onCompleted()
                case .failure(let error):
                    let rawReport = RawReportModel(
                        url: spRequest.method.rawValue + " " + spRequest.url.absoluteString,
                        parameters: requestParams,
                        errorData: response.data,
                        errorMessage: error.localizedDescription
                    )
                    SPDefaultFailureReporter.shared.report(error: .networkError(rawReport: rawReport))
                    observer.onError(SpotImError.internalError(error.localizedDescription))
                }
            }

            return Disposables.create {
                task.cancel()
            }
        }
    }
}
