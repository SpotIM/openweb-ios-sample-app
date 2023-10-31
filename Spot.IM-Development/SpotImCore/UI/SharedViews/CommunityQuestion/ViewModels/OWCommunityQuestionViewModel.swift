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
    var triggerCustomizeQuestionTitleLabelUI: PublishSubject<UILabel> { get }
    var triggerCustomizeQuestionContainerViewUI: PublishSubject<UIView> { get }
    var triggerCustomizeQuestionTitleTextViewUI: PublishSubject<UITextView> { get }
}

protocol OWCommunityQuestionViewModelingOutputs {
    var communityQuestion: Observable<String> { get }
    var attributedCommunityQuestion: Observable<NSAttributedString> { get }
    var shouldShowView: Observable<Bool> { get }
    var showContainer: Bool { get }
    var customizeQuestionTitleLabelUI: Observable<UILabel> { get }
    var customizeQuestionContainerViewUI: Observable<UIView> { get }
    var customizeQuestionTitleTextViewUI: Observable<UITextView> { get }
    var style: OWCommunityQuestionStyle { get }
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

    // Required to work with BehaviorSubject in the RX chain as the final subscriber begin after the initial publish subjects send their first elements
    fileprivate let _triggerCustomizeQuestionTitleLabelUI = BehaviorSubject<UILabel?>(value: nil)
    fileprivate let _triggerCustomizeQuestionContainerViewUI = BehaviorSubject<UIView?>(value: nil)
    fileprivate let _triggerCustomizeQuestionTitleTextViewUI = BehaviorSubject<UITextView?>(value: nil)

    var triggerCustomizeQuestionTitleLabelUI = PublishSubject<UILabel>()
    var triggerCustomizeQuestionContainerViewUI = PublishSubject<UIView>()
    var triggerCustomizeQuestionTitleTextViewUI = PublishSubject<UITextView>()
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
                    .font: OWFontBook.shared.font(typography: .bodyText),
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
            .startWith(false)
            .distinctUntilChanged()
            .share(replay: 0)
    }

    var customizeQuestionTitleLabelUI: Observable<UILabel> {
        return _triggerCustomizeQuestionTitleLabelUI
            .unwrap()
            .asObservable()
    }

    var customizeQuestionContainerViewUI: Observable<UIView> {
        return _triggerCustomizeQuestionContainerViewUI
            .unwrap()
            .asObservable()
    }

    var customizeQuestionTitleTextViewUI: Observable<UITextView> {
        return _triggerCustomizeQuestionTitleTextViewUI
            .unwrap()
            .asObservable()
    }

    lazy var showContainer: Bool = {
        return style == .compact
    }()

    let style: OWCommunityQuestionStyle
    fileprivate let disposeBag = DisposeBag()

    init(style: OWCommunityQuestionStyle) {
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

        triggerCustomizeQuestionTitleLabelUI
            .bind(to: _triggerCustomizeQuestionTitleLabelUI)
            .disposed(by: disposeBag)

        triggerCustomizeQuestionContainerViewUI
            .bind(to: _triggerCustomizeQuestionContainerViewUI)
            .disposed(by: disposeBag)

        triggerCustomizeQuestionTitleTextViewUI
            .bind(to: _triggerCustomizeQuestionTitleTextViewUI)
            .disposed(by: disposeBag)

    }
}
