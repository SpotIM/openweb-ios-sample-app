//
//  OWCommunityGuidelinesCellViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 21/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommunityGuidelinesCellViewModelingInputs { }

protocol OWCommunityGuidelinesCellViewModelingOutputs {
    var id: String { get }
    var communityGuidelinesViewModel: OWCommunityGuidelinesViewModeling { get }
    var communityGuidelinesSpacing: CGFloat { get }
}

protocol OWCommunityGuidelinesCellViewModeling: OWCellViewModel {
    var inputs: OWCommunityGuidelinesCellViewModelingInputs { get }
    var outputs: OWCommunityGuidelinesCellViewModelingOutputs { get }
}

class OWCommunityGuidelinesCellViewModel: OWCommunityGuidelinesCellViewModeling,
                                        OWCommunityGuidelinesCellViewModelingInputs,
                                        OWCommunityGuidelinesCellViewModelingOutputs {
    var inputs: OWCommunityGuidelinesCellViewModelingInputs { return self }
    var outputs: OWCommunityGuidelinesCellViewModelingOutputs { return self }

    lazy var communityGuidelinesViewModel: OWCommunityGuidelinesViewModeling = {
        return OWCommunityGuidelinesViewModel(style: self.style, spacing: self.spacing)
    }()

    lazy var communityGuidelinesSpacing: CGFloat = {
        return self.spacing
    }()

    fileprivate let style: OWCommunityGuidelinesStyle
    fileprivate let spacing: CGFloat

    // Unique identifier
    let id: String = UUID().uuidString

    init(style: OWCommunityGuidelinesStyle = .regular,
         spacing: OWConversationSpacing = .regular) {
        self.style = style
        self.spacing = spacing.communityGuidelines
    }
}

extension OWCommunityGuidelinesCellViewModel {
    static func stub() -> OWCommunityGuidelinesCellViewModeling {
        return OWCommunityGuidelinesCellViewModel()
    }
}
