//
//  OWCommunityQuestionViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommunityQuestionViewModelingInputs {
    var conversationFetched: PublishSubject<SPConversationReadRM> { get }
}

protocol OWCommunityQuestionViewModelingOutputs {
    var communityQuestionOutput: Observable<String?> { get }
    var shouldShowView: Observable<Bool> { get }
}

protocol OWCommunityQuestionViewModeling {
    var inputs: OWCommunityQuestionViewModelingInputs { get }
    var outputs: OWCommunityQuestionViewModelingOutputs { get }
}

class OWCommunityQuestionViewModel: OWCommunityQuestionViewModeling, OWCommunityQuestionViewModelingInputs, OWCommunityQuestionViewModelingOutputs {
    var inputs: OWCommunityQuestionViewModelingInputs { return self }
    var outputs: OWCommunityQuestionViewModelingOutputs { return self }

    var conversationFetched = PublishSubject<SPConversationReadRM>()

    var communityQuestionOutput: Observable<String?> {
        conversationFetched
            .map { $0.conversation?.communityQuestion }
    }

    var shouldShowView: Observable<Bool> {
        communityQuestionOutput
            .map { [weak self] question in
                guard let self = self else { return false }
                if let question = question, !question.isEmpty {
                    return self.style != .none
                }
                return false
            }
    }

    fileprivate let style: OWCommunityQuestionsStyle
    init(style: OWCommunityQuestionsStyle) {
        self.style = style
    }
}
