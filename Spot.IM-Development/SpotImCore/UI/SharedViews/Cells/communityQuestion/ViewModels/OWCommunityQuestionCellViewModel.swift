//
//  OWCommunityQuestionCellViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 21/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommunityQuestionCellViewModelingInputs {
//    var conversationFetched: PublishSubject<SPConversationReadRM> { get }
}

protocol OWCommunityQuestionCellViewModelingOutputs {
    var id: String { get }
    var communityQuestionViewModel: OWCommunityQuestionViewModeling { get }
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

    fileprivate let style: OWCommunityQuestionsStyle

    // Unique identifier
    let id: String = UUID().uuidString

    init(style: OWCommunityQuestionsStyle = .regular) {
        self.style = style
    }
}

extension OWCommunityQuestionCellViewModel {
    static func stub() -> OWCommunityQuestionCellViewModeling {
        return OWCommunityQuestionCellViewModel()
    }
}
