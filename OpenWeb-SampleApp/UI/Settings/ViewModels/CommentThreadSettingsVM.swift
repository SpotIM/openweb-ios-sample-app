//
//  CommentThreadSettingsVM.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 09/05/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import Combine
import OpenWebSDK

protocol CommentThreadSettingsViewModelingInputs {
    var openCommentIdSelected: CurrentValueSubject<String, Never> { get }
}

protocol CommentThreadSettingsViewModelingOutputs {
    var title: String { get }
    var openCommentIdTitle: String { get }
    var openCommentId: AnyPublisher<String, Never> { get }
}

protocol CommentThreadSettingsViewModeling {
    var inputs: CommentThreadSettingsViewModelingInputs { get }
    var outputs: CommentThreadSettingsViewModelingOutputs { get }
}

class CommentThreadSettingsVM: CommentThreadSettingsViewModeling, CommentThreadSettingsViewModelingInputs, CommentThreadSettingsViewModelingOutputs {
    var inputs: CommentThreadSettingsViewModelingInputs { return self }
    var outputs: CommentThreadSettingsViewModelingOutputs { return self }

    lazy var openCommentIdSelected = CurrentValueSubject<String, Never>(userDefaultsProvider.get(key: .openCommentId, defaultValue: OWCommentThreadSettings.defaultCommentId))

    var openCommentId: AnyPublisher<String, Never> {
        return openCommentIdSelected
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    lazy var openCommentIdTitle: String = {
        return NSLocalizedString("OpenCommentId", comment: "")
    }()

    private var userDefaultsProvider: UserDefaultsProviderProtocol
    private var cancellables = Set<AnyCancellable>()

    lazy var title: String = {
        return NSLocalizedString("CommentThreadSettings", comment: "")
    }()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

private extension CommentThreadSettingsVM {
    func setupObservers() {
        openCommentIdSelected
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<String>.openCommentId))
            .store(in: &cancellables)
    }
}

extension CommentThreadSettingsVM: SettingsGroupVMProtocol {
    func resetToDefault() {
        openCommentIdSelected.send(OWCommentThreadSettings.defaultCommentId)
    }
}
