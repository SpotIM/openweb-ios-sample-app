//
//  SampleAppCallingMethod.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 26/12/2024.
//

import Foundation

enum SampleAppCallingMethod: Int, Codable, CaseIterable, CustomStringConvertible {
    case completionBlock
    case asyncAwait

    static let `default` = Self.completionBlock

    var description: String {
        switch self {
        case .completionBlock:
            return NSLocalizedString("CallingMethodCompletionBlock", comment: "")
        case .asyncAwait:
            return NSLocalizedString("CallingMethodAsyncAwait", comment: "")
        }
    }
}
