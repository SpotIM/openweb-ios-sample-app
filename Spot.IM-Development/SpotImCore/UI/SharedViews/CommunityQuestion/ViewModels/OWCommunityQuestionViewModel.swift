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
    var triggerCustomizeQuestionLabelUI: PublishSubject<UILabel> { get }
}

protocol OWCommunityQuestionViewModelingOutputs {
    var communityQuestion: Observable<String> { get }
    var attributedCommunityQuestion: Observable<NSAttributedString> { get }
    var shouldShowView: Observable<Bool> { get }
    var showContainer: Bool { get }
    var customizeQuestionLabelUI: Observable<UILabel> { get }
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

    struct Metrics {
        static let communityQuestionFontSize = 15.0
        static let communityQuestionFont = OWFontBook.shared.font(style: .regular, size: Metrics.communityQuestionFontSize)
    }

    // Required to work with BehaviorSubject in the RX chain as the final subscriber begin after the initial publish subjects send their first elements
    fileprivate let _triggerCustomizeQuestionLabelUI = BehaviorSubject<UILabel?>(value: nil)

    var triggerCustomizeQuestionLabelUI = PublishSubject<UILabel>()
    var conversationFetched = PublishSubject<OWConversationReadRM>()

    let _communityQuestion = BehaviorSubject<String?>(value: nil)
    var communityQuestion: Observable<String> {
        _communityQuestion
            .unwrap()
    }

    lazy var attributedCommunityQuestion: Observable<NSAttributedString> = {
        communityQuestion
            .distinctUntilChanged()
            .map { question in
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = OWLocalizationManager.shared.textAlignment

                let attributes: [NSAttributedString.Key: Any] = [
                    .paragraphStyle: paragraphStyle,
                    .font: Metrics.communityQuestionFont,
                    .foregroundColor: OWColorPalette.shared.color(type: .textColor2,
                                                                  themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
                ]

                return NSAttributedString(string: question, attributes: attributes)
            }
    }()

    var _shouldShowView = BehaviorSubject<Bool?>(value: nil)
    var shouldShowView: Observable<Bool> {
        _shouldShowView
            .unwrap()
            .asObservable()
            .share(replay: 0)
    }

    var customizeQuestionLabelUI: Observable<UILabel> {
        return _triggerCustomizeQuestionLabelUI
            .unwrap()
            .asObservable()
    }

    lazy var showContainer: Bool = {
        return style == .compact
    }()

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

        triggerCustomizeQuestionLabelUI
            .bind(to: _triggerCustomizeQuestionLabelUI)
            .disposed(by: disposeBag)

    }
}
