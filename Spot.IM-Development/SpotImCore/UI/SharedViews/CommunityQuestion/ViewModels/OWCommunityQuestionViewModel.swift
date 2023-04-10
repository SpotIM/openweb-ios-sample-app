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
    var conversationFetched: PublishSubject<OWConversationReadRM> { get }
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

    var conversationFetched = PublishSubject<OWConversationReadRM>()

    var communityQuestionOutput: Observable<String?> {
        conversationFetched
            .map { $0.conversation?.communityQuestion }
    }

    var _shouldShowView = BehaviorSubject(value: false)
    var shouldShowView: Observable<Bool> {
        _shouldShowView
            .asObserver()
    }

    fileprivate let style: OWCommunityQuestionsStyle
    fileprivate let disposeBag = DisposeBag()
    init(style: OWCommunityQuestionsStyle) {
        self.style = style
        setupObservers()
    }
}

fileprivate extension OWCommunityQuestionViewModel {
    func setupObservers() {
        communityQuestionOutput
            .subscribe(onNext: { [weak self] question in
                guard let self = self else { return }
                if let question = question, !question.isEmpty {
                    self._shouldShowView.onNext(self.style != .none)
                } else {
                    self._shouldShowView.onNext(false)
                }
            })
            .disposed(by: disposeBag)
    }
}
