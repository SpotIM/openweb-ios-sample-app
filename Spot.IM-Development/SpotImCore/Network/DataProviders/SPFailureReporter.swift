//
//  SPFailureReporter.swift
//  Spot.IM-Core
//
//  Created by Eugene on 10/4/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

struct RawReportModel {
    let url: String
    let parameters: [String: Any]?
    let errorData: Data?
    let errorMessage: String
}

enum SPGeneralError {
    case encodingHtmlError(onCommentId: String?, parentId: String?)
    
    var description: String {
        switch self {
        case .encodingHtmlError:
            return "Error encoding html comment text"
        }
    }
}

enum SPMonetizationError {
    case bannerFailedToLoad(source: OWMonetizationSource, error: Error)
    case interstitialFailedToLoad(error: Error)
}

enum SPError {
    case generalError(_ generalError: SPGeneralError)
    case networkError(rawReport: RawReportModel)
    case monetizationError(_ monetizationError: SPMonetizationError)
    case realTimeError(_ realTimeError: RealTimeError)
}

extension SPError {
    func parameters() -> [String: Any]? {
        switch self {
        case .networkError(let rawReport):
            return prepareNetworkReportDataModel(rawReport).parameters()
        case .monetizationError(let monetizationError):
            return prepareMonetizationFailureModel(monetizationError).parameters()
        case .realTimeError(let realTimeError):
            return prepareRealTimeFailureModel(realTimeError).parameters()
        case .generalError(let generalError):
            return prepareGeneralFailureModel(generalError).parameters()
        }
    }
    
    private func prepareGeneralFailureModel(_ generalError: SPGeneralError) -> OWGeneralFailureReportDataModel {
        switch generalError {
        case .encodingHtmlError(let commentId,let parentId):
            return OWGeneralFailureReportDataModel(reason: generalError.description, commentId: commentId, parentCommentId: parentId)
        }
    }
    
    private func prepareRealTimeFailureModel(_ realTimeError: RealTimeError) -> OWRealTimeFailureModel {
        return OWRealTimeFailureModel(reason: realTimeError.description)
    }
    
    private func prepareMonetizationFailureModel(_ monetizationError: SPMonetizationError) -> OWMonetizationFailureModel {
        switch monetizationError {
        case .bannerFailedToLoad(let source, let error):
            return OWMonetizationFailureModel(source: source, reason: error.localizedDescription, bannerType: .banner)
        case .interstitialFailedToLoad(let error):
            return OWMonetizationFailureModel(source: .preConversation, reason: error.localizedDescription, bannerType: .interstitial)
        }
    }
    
    private func prepareNetworkReportDataModel(_ rawReport: RawReportModel) -> OWNetworkFailureReportDataModel {
        var bodyString: String = rawReport.errorMessage
        if let data = rawReport.errorData, let dataString = String(data: data, encoding: .utf8) {
            bodyString = dataString
        }
        
        return OWNetworkFailureReportDataModel(
            errorSource: "HTTP",
            httpPayload: OWFailureHttpPayload(
                body: bodyString,
                outputParameters: rawReport.parameters?.jsonString() ?? "",
                url: rawReport.url
            ),
            isRegistered: SPUserSessionHolder.session.user?.registered ?? false,
            platform: "IOS",
            userId: SPUserSessionHolder.session.user?.id ?? ""
        )
    }
}

internal final class SPDefaultFailureReporter: NetworkDataProvider {
    
    static let shared = SPDefaultFailureReporter()
    
    private init() {
        super.init(apiManager: OWApiManager())
    }
    
    func report(error: SPError, postId: String = "default") {
        guard let spotKey = SPClientSettings.main.spotKey else { return }
        
        let headers = HTTPHeaders.basic(with: spotKey, postId: postId)
        
        manager.execute(
            request: SPFailureReportRequest.error,
            parameters: error.parameters(),
            parser: OWEmptyParser(),
            headers: headers
        ) { [weak self] (result, response) in
            guard case let .failure(error) = result else { return }
            
            self?.servicesProvider.logger().log(level: .error, "FailureReporter: \(error.localizedDescription)", prefix: "OpenWebSDKNetworkFailureReporterLogger")
        }
    }
}
