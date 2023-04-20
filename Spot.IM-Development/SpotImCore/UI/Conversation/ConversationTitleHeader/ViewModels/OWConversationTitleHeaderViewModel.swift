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
    var closeTapped: PublishSubject<Void> { get }
}

protocol OWConversationTitleHeaderViewModelingOutputs {
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

    var closeTapped = PublishSubject<Void>()

    fileprivate var _closeConversation = PublishSubject<Void>()
    var closeConversation: Observable<Void> {
        return _closeConversation.asObservable()
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
    }
}
