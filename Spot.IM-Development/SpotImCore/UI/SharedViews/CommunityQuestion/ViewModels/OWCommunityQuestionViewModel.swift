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
    var communityQuestion: Observable<String> { get }
    var shouldShowView: Observable<Bool> { get }
}

protocol OWCommunityQuestionViewModeling {
    var inputs: OWCommunityQuestionViewModelingInputs { get }
    var outputs: OWCommunityQuestionViewModelingOutputs { get }
}

class OWCommunityQuestionViewModel: OWCommunityQuestionViewModeling,
                                        OWCommunityQuestionViewModelingInputs,
                                        OWCommunityQuestionViewModelingOutputs {
    var inputs: OWCommunityQuestionViewModelingInputs { return self }
    var outputs: OWCommunityQuestionViewModelingOutputs { return self }

    var conversationFetched = PublishSubject<SPConversationReadRM>()
    var heightConstraintIsActive = PublishSubject<Bool>()
    var textChanged = PublishSubject<String>()
    var _textChanged = BehaviorSubject<String?>(value: nil)

    let _communityQuestion = BehaviorSubject<String?>(value: nil)
    var communityQuestion: Observable<String> {
        _communityQuestion
            .unwrap()
    }

    var _shouldShowView = BehaviorSubject<Bool?>(value: nil)
    var shouldShowView: Observable<Bool> {
        _shouldShowView
            .unwrap()
            .asObservable()
            .share(replay: 0)
    }

    fileprivate let style: OWCommunityQuestionsStyle
    fileprivate let disposeBag = DisposeBag()

    init(style: OWCommunityQuestionsStyle) {
        self.style = style
        setupObservers()
    }

    init() {
        style = .regular
    }
}

fileprivate extension OWCommunityQuestionViewModel {
    func setupObservers() {
        communityQuestion
            .subscribe(onNext: { [weak self] question in
                guard let self = self else { return }
                let shouldShow = (!question.isEmpty) && (self.style != .none)
                self._shouldShowView.onNext(shouldShow)
            })
            .disposed(by: disposeBag)

        conversationFetched
            .map { $0.conversation?.communityQuestion }
            .subscribe(onNext: { [weak self] question in
                guard let self = self else { return }
                self._communityQuestion.onNext(question)
            })
            .disposed(by: disposeBag)

    }
}
