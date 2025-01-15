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
    var preConversationHorizontalMargin: CGFloat { get }
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

    private struct Metrics {
        static let preConversationCompactHorizontalMargin: CGFloat = 16.0
    }

    private let disposeBag = DisposeBag()
    private let userDefaultsProvider: UserDefaultsProviderProtocol

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

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         showPreConversation: Observable<UIView?>,
         adSizeChanged: Observable<Void>) {
        self.userDefaultsProvider = userDefaultsProvider

        showPreConversation
              .bind(to: _showPreConversation)
              .disposed(by: disposeBag)

        adSizeChanged
            .bind(to: _adSizeChanged)
            .disposed(by: disposeBag)
    }

    var preConversationHorizontalMargin: CGFloat {
        let preConversationStyle = userDefaultsProvider.get(key: .preConversationStyle, defaultValue: OWPreConversationStyle.default)
        let margin = preConversationStyle == OWPreConversationStyle.compact ? Metrics.preConversationCompactHorizontalMargin : 0.0
        return margin
    }
}
