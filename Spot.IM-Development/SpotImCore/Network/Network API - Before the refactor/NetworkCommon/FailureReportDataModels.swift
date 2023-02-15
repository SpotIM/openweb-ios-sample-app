//
//  FailureReportDataModels.swift
//  Spot.IM-Core
//
//  Created by Eugene on 10/4/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

protocol OWParametersPresentable {
    func parameters() -> [String: Any]?
}

extension OWParametersPresentable where Self: Encodable {

    func parameters() -> [String: Any]? {
        guard
            let data = try? JSONEncoder().encode(self),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            else { return nil }

        return json as? [String: Any]
    }

}

struct OWGeneralFailureReportDataModel: Encodable, OWParametersPresentable {
    let reason: String

    var commentId: String? = nil
    var parentCommentId: String? = nil
}

struct OWNetworkFailureReportDataModel: Encodable, OWParametersPresentable {
    let errorSource: String
    let httpPayload: OWFailureHttpPayload
    let isRegistered: Bool
    let platform: String
    let userId: String
}

struct OWMonetizationFailureModel: Encodable, OWParametersPresentable {
    let source: OWMonetizationSource
    let reason: String
    let bannerType: AdType
}

struct OWRealTimeFailureModel: Encodable, OWParametersPresentable {
    let reason: String
}

enum OWMonetizationSource: String, Encodable {
    case preConversation = "pre_converstaion"
    case mainConversation = "main_conversation"
}

struct OWFailureHttpPayload: Encodable {
    let body: String
    let outputParameters: String
    let url: String
}
