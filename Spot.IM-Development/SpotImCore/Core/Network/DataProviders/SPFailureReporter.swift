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

internal final class SPDefaultFailureReporter: NetworkDataProvider {
    
    static let shared = SPDefaultFailureReporter()
    
    private init() {
        super.init(apiManager: ApiManager())
    }
    
    func sendNetworkFailureReport(_ rawReport: RawReportModel) {
        guard
            let spotKey = SPClientSettings.main.spotKey
            else { return }
        
        let spRequest = SPFailureReportRequest.error
        let headers = HTTPHeaders.basic(with: spotKey)
        let failureReportDataModel = prepareNetworkReportDataModel(rawReport)
        
        manager.execute(
            request: spRequest,
            parameters: failureReportDataModel.parameters(),
            parser: EmptyParser(),
            headers: headers
        ) { (result, response) in
            guard case let .failure(error) = result else { return }
            
            Logger.error(error)
        }
    }
    
    func sendFaliureReport(_ failureData: ParametersPresentable, postId: String = "default") {
        guard let spotKey = SPClientSettings.main.spotKey else { return }
        
        let spRequest = SPFailureReportRequest.error
        let headers = HTTPHeaders.basic(with: spotKey, postId: postId)
        
        manager.execute(
            request: spRequest,
            parameters: failureData.parameters(),
            parser: EmptyParser(),
            headers: headers
        ) { (result, response) in
            guard case let .failure(error) = result else { return }
            
            Logger.error(error)
        }
    }
    
    private func prepareNetworkReportDataModel(_ rawReport: RawReportModel) -> NetworkFailureReportDataModel {
        var bodyString: String = rawReport.errorMessage
        if let data = rawReport.errorData, let dataString = String(data: data, encoding: .utf8) {
            bodyString = dataString
        }
        
        return NetworkFailureReportDataModel(
            errorSource: "HTTP",
            httpPayload: FailureHttpPayload(
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
