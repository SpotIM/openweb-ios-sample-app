//
//  ConversationPreset.swift
//  OpenWeb-Development
//
//  Created by Revital Pisman on 11/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
#if !PUBLIC_DEMO_APP
    import OpenWeb_SampleApp_Internal_Configs
#endif

struct ConversationPreset {
    let displayName: String
    let conversationDataModel: SDKConversationDataModel
    var section: String?
}

extension ConversationPreset {
    static let mockModels = Self.createMockModels()

    static func createMockModels() -> [ConversationPreset] {
    #if PUBLIC_DEMO_APP
        return publicPresets()
    #elseif ADS
        let developmentPresets = DevelopmentConversationPreset.developmentPresets().map { $0.toConversationPreset()
        }
        let adsPresets = DevelopmentConversationPreset.adsPresets().map { $0.toConversationPreset()
        }
        return publicPresets() + developmentPresets + adsPresets
    #else
        let developmentPresets = DevelopmentConversationPreset.developmentPresets().map { $0.toConversationPreset() }
        return publicPresets() + developmentPresets
    #endif
    }

    static func publicMainPreset() -> ConversationPreset {
        // TODO: Return a dedicated "main demo" preset for public Sample App preset
        return ConversationPreset(displayName: "Demo Spot - Public",
                                              conversationDataModel: SDKConversationDataModel(spotId: "sp_eCIlROSD",
                                                                                              postId: "sdk1"))
    }

    private static func publicPresets() -> [ConversationPreset] {
        // TODO: Add more presets
        return [publicMainPreset()]
    }
}
