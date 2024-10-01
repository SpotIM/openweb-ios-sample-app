//
//  OWCommunityQuestionCellViewModel.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 21/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommunityQuestionCellViewModelingInputs { }

protocol OWCommunityQuestionCellViewModelingOutputs {
    var id: String { get }
    var communityQuestionViewModel: OWCommunityQuestionViewModeling { get }
    var communityQuestionSpacing: OWVerticalSpacing { get }
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
        return OWCommunityQuestionViewModel(style: self.style, spacing: self.spacing)
    }()

    lazy var communityQuestionSpacing: OWVerticalSpacing = {
        return self.spacing
    }()

    private let style: OWCommunityQuestionStyle
    private let spacing: OWVerticalSpacing

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
