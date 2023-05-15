//
//  OWReportReasonEndpoints.swift
//  SpotImCore
//
//  Created by Refael Sommer on 08/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWReportReasonEndpoints: OWEndpoints {
    case report(commentId: String,
                reasonMain: String,
                reasonSub: String,
                userDescription: String)

    // MARK: - HTTPMethod
    var method: OWNetworkHTTPMethod {
        switch self {
        case .report: return .post
        }
    }

    // MARK: - Path
    var path: String {
        switch self {
        case .report: return "/conversation/report/message"
        }
    }

    // MARK: - Parameters
    var parameters: OWNetworkParameters? {
        switch self {
        case .report(let commentId,
                     let reasonMain,
                     let reasonSub,
                     let userDescription):
            let reasons = ["main": reasonMain, "sub": reasonSub]
            let userDescription = ["user_description": userDescription]
            return ["message_id": commentId,
                    "reasons": reasons,
                    "report_metadata": userDescription]
        }
    }
}

protocol OWReportReasonAPI {
    func report(commentId: String, reasonMain: String, reasonSub: String, userDescription: String) -> OWNetworkResponse<EmptyDecodable>
}

extension OWNetworkAPI: OWReportReasonAPI {
    // Access by .conversation for readability
    var reportReason: OWReportReasonAPI { return self }

    func report(commentId: String, reasonMain: String, reasonSub: String, userDescription: String = "") -> OWNetworkResponse<EmptyDecodable> {
        let endpoint = OWReportReasonEndpoints.report(commentId: commentId,
                                                      reasonMain: reasonMain,
                                                      reasonSub: reasonSub,
                                                      userDescription: userDescription)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}
