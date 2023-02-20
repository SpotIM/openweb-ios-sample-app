//
//  Dictionary+JSONString.swift
//  Spot.IM-Core
//
//  Created by Eugene on 10/4/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {

    func jsonString() -> String? {
        guard
            let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
            let jsonString = String(data: jsonData, encoding: .utf8)
            else { return nil }

        return jsonString
    }
}
