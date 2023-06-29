//
//  OWConversationTitleHeaderViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 21/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWConversationTitleHeaderViewModelingInputs {
    var triggerCustomizeTitleLabelUI: PublishSubject<UILabel> { get }
    var triggerCustomizeCloseButtonUI: PublishSubject<UIButton> { get }
    var closeTapped: PublishSubject<Void> { get }
}

protocol OWConversationTitleHeaderViewModelingOutputs {
    var customizeTitleLabelUI: Observable<UILabel> { get }
    var customizeCloseButtonUI: Observable<UIButton> { get }
    var closeConversation: Observable<Void> { get }
}

protocol OWConversationTitleHeaderViewModeling {
    var inputs: OWConversationTitleHeaderViewModelingInputs { get }
    var outputs: OWConversationTitleHeaderViewModelingOutputs { get }
}

class OWConversationTitleHeaderViewModel: OWConversationTitleHeaderViewModeling,
                                          OWConversationTitleHeaderViewModelingInputs,
                                          OWConversationTitleHeaderViewModelingOutputs {
    var inputs: OWConversationTitleHeaderViewModelingInputs { return self }
    var outputs: OWConversationTitleHeaderViewModelingOutputs { return self }

    // Required to work with BehaviorSubject in the RX chain as the final subscriber begin after the initial publish subjects send their first elements
    fileprivate let _triggerCustomizeTitleLabelUI = BehaviorSubject<UILabel?>(value: nil)
    fileprivate let _triggerCustomizeCloseButtonUI = BehaviorSubject<UIButton?>(value: nil)

    var triggerCustomizeTitleLabelUI = PublishSubject<UILabel>()
    var triggerCustomizeCloseButtonUI = PublishSubject<UIButton>()

    var closeTapped = PublishSubject<Void>()

    fileprivate var _closeConversation = PublishSubject<Void>()
    var closeConversation: Observable<Void> {
        return _closeConversation.asObservable()
    }

    var customizeTitleLabelUI: Observable<UILabel> {
        return _triggerCustomizeTitleLabelUI
            .unwrap()
            .asObservable()
    }

    var customizeCloseButtonUI: Observable<UIButton> {
        return _triggerCustomizeCloseButtonUI
            .unwrap()
            .asObservable()
    }

    fileprivate let disposeBag = DisposeBag()

    init () {
        self.setupObservers()
    }
}

fileprivate extension OWConversationTitleHeaderViewModel {
    func setupObservers() {
        closeTapped.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self._closeConversation.onNext()
        })
        .disposed(by: disposeBag)

        triggerCustomizeTitleLabelUI
            .bind(to: _triggerCustomizeTitleLabelUI)
            .disposed(by: disposeBag)

        triggerCustomizeCloseButtonUI
            .bind(to: _triggerCustomizeCloseButtonUI)
            .disposed(by: disposeBag)
    }
}
