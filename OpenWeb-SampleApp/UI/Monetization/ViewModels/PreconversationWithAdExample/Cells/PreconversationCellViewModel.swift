//
//  PreconversationCellViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 18/12/2024.
//

import UIKit
import Combine
import OpenWebSDK

protocol PreconversationCellViewModelingInput {}

protocol PreconversationCellViewModelingOutput {
    var showPreConversation: AnyPublisher<UIView?, Never> { get }
    var adSizeChanged: AnyPublisher<Void, Never> { get }
}

protocol PreconversationCellViewModeling {
    var inputs: PreconversationCellViewModelingInput { get }
    var outputs: PreconversationCellViewModelingOutput { get }
}

class PreconversationCellViewModel: PreconversationCellViewModeling,
                                                 PreconversationCellViewModelingOutput,
                                                 PreconversationCellViewModelingInput {
    var inputs: PreconversationCellViewModelingInput { self }
    var outputs: PreconversationCellViewModelingOutput { self }

    private var cancellables = Set<AnyCancellable>()

    private let _showPreConversation = CurrentValueSubject<UIView?, Never>(value: nil)
    var showPreConversation: AnyPublisher<UIView?, Never> {
        return _showPreConversation
            .eraseToAnyPublisher()
    }

    private let _adSizeChanged = PassthroughSubject<Void, Never>()
    var adSizeChanged: AnyPublisher<Void, Never> {
        return _adSizeChanged
            .eraseToAnyPublisher()
    }

    init(showPreConversation: AnyPublisher<UIView?, Never>,
         adSizeChanged: AnyPublisher<Void, Never>) {

        showPreConversation
              .bind(to: _showPreConversation)
              .store(in: &cancellables)

        adSizeChanged
            .bind(to: _adSizeChanged)
            .store(in: &cancellables)
    }
}
