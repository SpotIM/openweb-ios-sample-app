//
//  SettingsGroupType.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 26/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

enum SettingsGroupType: CaseIterable {
    case sampleApp
    case general
    case preConversation
    case conversation
    case commentCreation
    case commentThread
    case clarityDetails
    case iau // Independent Ad Unit
    case network

    static var all: [SettingsGroupType] {
        var allSettings = Self.allCases
        #if !ADS
        allSettings.removeAll { $0 == .iau }
        #endif

        #if !BETA
        allSettings.removeAll { $0 == .network }
        #endif

        return allSettings
    }
}

extension SettingsGroupType {
    func createAppropriateVM(userDefaultsProvider: UserDefaultsProviderProtocol, manager: OWManagerProtocol) -> SettingsGroupVMProtocol {
        switch self {
        case .sampleApp:
            return SampleAppSettingsVM(userDefaultsProvider: userDefaultsProvider)
        case .general:
            return GeneralSettingsVM(userDefaultsProvider: userDefaultsProvider, manager: manager)
        case .preConversation:
            return PreConversationSettingsVM(userDefaultsProvider: userDefaultsProvider)
        case .conversation:
            return ConversationSettingsVM(userDefaultsProvider: userDefaultsProvider)
        case .commentCreation:
            return CommentCreationSettingsVM(userDefaultsProvider: userDefaultsProvider)
        case .commentThread:
            return CommentThreadSettingsVM(userDefaultsProvider: userDefaultsProvider)
        case .clarityDetails:
            return ClarityDetailsSettingsVM(userDefaultsProvider: userDefaultsProvider)
        case .iau:
            return IAUSettingsVM(userDefaultsProvider: userDefaultsProvider)
        case .network:
            return NetworkSettingsVM(userDefaultsProvider: userDefaultsProvider)
        }
    }

    init(independentViewType: SDKUIIndependentViewType) {
        switch independentViewType {
        case .preConversation:
            self = .preConversation
        case .conversation:
            self = .conversation
        case .commentCreation:
            self = .commentCreation
        case .commentThread:
            self = .commentThread
        case .clarityDetails:
            self = .clarityDetails
        case .independentAdUnit:
            self = .iau
        case .notifications:
            self = .general
        }
    }
}
