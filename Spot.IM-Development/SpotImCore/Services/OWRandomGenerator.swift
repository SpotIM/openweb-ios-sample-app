//
//  OWRandomGenerator.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

protocol OWRandomGeneratorProtocol {
    // Generate UUID which is "random" by the "milliards" mark
    func generateSuperiorUUID(epochSuffixLength: Int) -> String
}

extension OWRandomGeneratorProtocol {
    func generateSuperiorUUID(epochSuffixLength: Int = OWRandomGenerator.Metrics.defaultEpochSuffixLength) -> String {
        generateSuperiorUUID(epochSuffixLength: epochSuffixLength)
    }
}

class OWRandomGenerator {
    fileprivate struct Metrics {
        static let defaultEpochSuffixLength: Int = 8
        static let minEpochSuffixLength: Int = 1
        static let maxEpochSuffixLength: Int = 10
    }

    /*
     An example for such "superior UUID", for `epochSuffixLength = 8`,
     given Epoch time 1692547890, will be as followed:
     BE13E09E-7099-4A3C-A408-2FDEC171DAAC-92547890
     */
    func generateSuperiorUUID(epochSuffixLength: Int) -> String {
        let finalIdentifier: String
        let randomUUID = UUID().uuidString
        let epoch = Date().timeIntervalSince1970
        let stringEpoch = String(format: "%.0f", epoch)
        let lengthFromEpoch = (min(max(Metrics.minEpochSuffixLength, epochSuffixLength),
                                   Metrics.maxEpochSuffixLength))
        let epochSuffix = stringEpoch.suffix(epochSuffixLength)
        finalIdentifier = "\(randomUUID)-\(epochSuffix)"
        return finalIdentifier
    }
}
