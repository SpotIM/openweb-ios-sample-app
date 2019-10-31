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

internal final class SPDefaultFailureReporter {
    
    func sendFailureReport(_ rawReport: RawReportModel) {
        guard
            let spotKey = SPClientSettings.spotKey
            else { return }
        
        let spRequest = SPFailureReportRequest.error
        let headers = HTTPHeaders.unauthorized(with: spotKey, postId: "")
        let failureReportDataModel = prepareReportDataModel(rawReport)
        
        Alamofire.request(spRequest.url,
                          method: spRequest.method,
                          parameters: failureReportDataModel.parameters(),
                          encoding: APIConstants.encoding,
                          headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let result):
                    print(result)
                    
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    private func prepareReportDataModel(_ rawReport: RawReportModel) -> FailureReportDataModel {
        var bodyString: String = rawReport.errorMessage
        if let data = rawReport.errorData, let dataString = String(data: data, encoding: .utf8) {
            bodyString = dataString
        }
        
        return FailureReportDataModel(
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
