//
//  Spot_IM_DevelopmentTests.swift
//  Spot-IM.DevelopmentTests
//
//  Created by Andriy Fedin on 16/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import XCTest
@testable import SpotImCore

class SPTestsUtils {

    func readJsonFromFile(fileName: String) -> Dictionary<String, AnyObject>? {
        
        if let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                    return jsonResult
                }
            } catch {
                // handle error
            }
        }
        return nil
    }
}
