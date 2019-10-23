//
//  FailureReportDataModel.swift
//  Spot.IM-Core
//
//  Created by Eugene on 10/4/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

protocol ParametersPresentable {
    func parameters() -> [String: Any]?
}

extension ParametersPresentable where Self: Encodable {

    func parameters() -> [String: Any]? {
        guard
            let data = try? JSONEncoder().encode(self),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
            else { return nil }
        
        return json as? [String: Any]
    }
    
}

struct FailureReportDataModel: Encodable, ParametersPresentable {
    
    let errorSource: String
    let httpPayload: FailureHttpPayload
    let isRegistered: Bool
    let platform: String
    let userId: String

}

struct FailureHttpPayload: Encodable {
    let body: String
    let outputParameters: String
    let url: String
}
