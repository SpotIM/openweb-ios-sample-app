//
//  OWCommunityQuestionCellViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 21/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommunityQuestionCellViewModelingInputs { }

protocol OWCommunityQuestionCellViewModelingOutputs {
    var id: String { get }
    var communityQuestionViewModel: OWCommunityQuestionViewModeling { get }
    var communityQuestionSpacing: CGFloat { get }
}

protocol OWCommunityQuestionCellViewModeling: OWCellViewModel {
    var inputs: OWCommunityQuestionCellViewModelingInputs { get }
    var outputs: OWCommunityQuestionCellViewModelingOutputs { get }
}

class OWCommunityQuestionCellViewModel: OWCommunityQuestionCellViewModeling,
                                        OWCommunityQuestionCellViewModelingInputs,
                                        OWCommunityQuestionCellViewModelingOutputs {
    var inputs: OWCommunityQuestionCellViewModelingInputs { return self }
    var outputs: OWCommunityQuestionCellViewModelingOutputs { return self }

    lazy var communityQuestionViewModel: OWCommunityQuestionViewModeling = {
        return OWCommunityQuestionViewModel(style: self.style)
    }()

    lazy var communityQuestionSpacing: CGFloat = {
        return self.spacing
    }()

    fileprivate let style: OWCommunityQuestionStyle
    fileprivate let spacing: CGFloat

    // Unique identifier
    let id: String = UUID().uuidString

    init(style: OWCommunityQuestionStyle = .regular,
         spacing: OWConversationSpacing = .regular) {
        self.style = style
        self.spacing = spacing.communityQuestions
    }
}

extension OWCommunityQuestionCellViewModel {
    static func stub() -> OWCommunityQuestionCellViewModeling {
        return OWCommunityQuestionCellViewModel()
    }
}
