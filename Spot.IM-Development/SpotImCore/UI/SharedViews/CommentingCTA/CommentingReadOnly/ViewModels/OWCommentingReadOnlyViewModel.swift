//
//  OWCommentingReadOnlyViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 24/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentingReadOnlyViewModelingInputs {
    var triggerCustomizeIconImageViewUI: PublishSubject<UIImageView> { get }
    var triggerCustomizeTitleLabelUI: PublishSubject<UILabel> { get }
}

protocol OWCommentingReadOnlyViewModelingOutputs {
    var customizeIconImageViewUI: Observable<UIImageView> { get }
    var customizeTitleLabelUI: Observable<UILabel> { get }
}

protocol OWCommentingReadOnlyViewModeling {
    var inputs: OWCommentingReadOnlyViewModelingInputs { get }
    var outputs: OWCommentingReadOnlyViewModelingOutputs { get }
}

class OWCommentingReadOnlyViewModel: OWCommentingReadOnlyViewModeling,
                                     OWCommentingReadOnlyViewModelingInputs,
                                     OWCommentingReadOnlyViewModelingOutputs {

    var inputs: OWCommentingReadOnlyViewModelingInputs { return self }
    var outputs: OWCommentingReadOnlyViewModelingOutputs { return self }

    // Required to work with BehaviorSubject in the RX chain as the final subscriber begin after the initial publish subjects send their first elements
    fileprivate let _triggerCustomizeIconImageViewUI = BehaviorSubject<UIImageView?>(value: nil)
    fileprivate let _triggerCustomizeTitleLabelUI = BehaviorSubject<UILabel?>(value: nil)

    var triggerCustomizeIconImageViewUI = PublishSubject<UIImageView>()
    var triggerCustomizeTitleLabelUI = PublishSubject<UILabel>()

    var customizeIconImageViewUI: Observable<UIImageView> {
        return _triggerCustomizeIconImageViewUI
            .unwrap()
            .asObservable()
    }

    var customizeTitleLabelUI: Observable<UILabel> {
        return _triggerCustomizeTitleLabelUI
            .unwrap()
            .asObservable()
    }

    fileprivate let disposeBag = DisposeBag()

    init() {
        setupObservers()
    }
}

fileprivate extension OWCommentingReadOnlyViewModel {
    func setupObservers() {
        triggerCustomizeTitleLabelUI
            .bind(to: _triggerCustomizeTitleLabelUI)
            .disposed(by: disposeBag)
    }
}
