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
    var communityQuestionString: PublishSubject<String?> { get }
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

    var communityQuestionString = PublishSubject<String?>()
    var communityQuestionOutput: Observable<String?> {
        communityQuestionString.asObservable()
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
