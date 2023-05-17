//
//  SettingsGroupType.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 26/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API
enum SettingsGroupType {
    case general
    case preConversation
    case conversation
    case commentCreation
    case commentThread
    case iau // Independent Ad Unit

    static var all: [SettingsGroupType] {
        return [.general, .preConversation, .conversation, .commentCreation, .commentThread, .iau]
    }
}

extension SettingsGroupType {
    func createAppropriateVM(userDefaultsProvider: UserDefaultsProviderProtocol, manager: OWManagerProtocol) -> SettingsGroupVMProtocol {
        switch self {
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
        case .iau:
            return IAUSettingsVM(userDefaultsProvider: userDefaultsProvider)
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
        case .independentAdUnit:
            self = .iau
        }
    }
}

#endif
