//
//  PreconversationCellViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 18/12/2024.
//

import Foundation
import RxSwift
import OpenWebSDK

protocol PreconversationCellViewModelingInput {}

protocol PreconversationCellViewModelingOutput {
    var showPreConversation: Observable<UIView?> { get }
    var adSizeChanged: Observable<Void> { get }
}

protocol PreconversationCellViewModeling {
    var inputs: PreconversationCellViewModelingInput { get }
    var outputs: PreconversationCellViewModelingOutput { get }
}

public final class PreconversationCellViewModel: PreconversationCellViewModeling,
                                                 PreconversationCellViewModelingOutput,
                                                 PreconversationCellViewModelingInput {
    var inputs: PreconversationCellViewModelingInput { self }
    var outputs: PreconversationCellViewModelingOutput { self }

    private let disposeBag = DisposeBag()

    private let _showPreConversation = BehaviorSubject<UIView?>(value: nil)
    var showPreConversation: Observable<UIView?> {
        return _showPreConversation
            .asObservable()
    }

    private let _adSizeChanged = PublishSubject<Void>()
    var adSizeChanged: Observable<Void> {
        return _adSizeChanged
            .asObservable()
    }

    init(showPreConversation: Observable<UIView?>,
         adSizeChanged: Observable<Void>) {

        showPreConversation
              .bind(to: _showPreConversation)
              .disposed(by: disposeBag)

        adSizeChanged
            .bind(to: _adSizeChanged)
            .disposed(by: disposeBag)
    }
}
