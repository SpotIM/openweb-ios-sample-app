//
//  OWCommunityQuestionViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

// TODO: complete
protocol OWCommunityQuestionViewModelingInputs {
    var communityQuestionString: PublishSubject<String?> { get }
}

protocol OWCommunityQuestionViewModelingOutputs {
    var communityQuestionOutput: Observable<String?> { get }
    var shouldShowView: Bool { get }
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

    var shouldShowView: Bool {
        if case .none = self.style {
            return false
        }
        return true
    }

    fileprivate let style: OWCommunityQuestionsStyle
    init(style: OWCommunityQuestionsStyle) {
        self.style = style
    }
}
