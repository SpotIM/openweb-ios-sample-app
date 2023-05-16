//
//  SettingsViewsFactory.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 08/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import Foundation

#if NEW_API
class SettingsViewsFactory {
    static func factor(from settingsVM: SettingsGroupVMProtocol) -> UIView? {
        // We can be sure that in every case it is the one we are casting to, so we force unwrap safely
        // swiftlint:disable force_cast
        switch settingsVM.self {
        case is GeneralSettingsVM:
            return GeneralSettingsView(viewModel: settingsVM as! GeneralSettingsVM)
        case is PreConversationSettingsVM:
            return PreConversationSettingsView(viewModel: settingsVM as! PreConversationSettingsVM)
        case is ConversationSettingsVM:
            return ConversationSettingsView(viewModel: settingsVM as! ConversationSettingsVM)
        case is CommentCreationSettingsVM:
            return CommentCreationSettingsView(viewModel: settingsVM as! CommentCreationSettingsVM)
        case is CommentThreadSettingsVM:
            return CommentThreadSettingsView(viewModel: settingsVM as! CommentThreadSettingsVM)
        case is IAUSettingsVM:
            return IAUSettingsView(viewModel: settingsVM as! IAUSettingsVM)
        default:
            return nil
        }
        // swiftlint:enable force_cast
    }
}
#endif
