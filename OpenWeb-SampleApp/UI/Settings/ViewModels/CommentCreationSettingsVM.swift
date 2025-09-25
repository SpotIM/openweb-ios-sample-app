//
//  CommentCreationSettingsVM.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import Combine
import OpenWebSDK

protocol CommentCreationSettingsViewModelingInputs {
    var customStyleModeSelectedIndex: CurrentValueSubject<Int, Never> { get }
}

protocol CommentCreationSettingsViewModelingOutputs {
    var title: String { get }
    var styleModeTitle: String { get }
    var styleModeIndex: AnyPublisher<Int, Never> { get }
    var styleModeSettings: [String] { get }
}

protocol CommentCreationSettingsViewModeling {
    var inputs: CommentCreationSettingsViewModelingInputs { get }
    var outputs: CommentCreationSettingsViewModelingOutputs { get }
}

class CommentCreationSettingsVM: CommentCreationSettingsViewModeling, CommentCreationSettingsViewModelingInputs, CommentCreationSettingsViewModelingOutputs {

    var inputs: CommentCreationSettingsViewModelingInputs { return self }
    var outputs: CommentCreationSettingsViewModelingOutputs { return self }

    lazy var customStyleModeSelectedIndex = CurrentValueSubject<Int, Never>(userDefaultsProvider.get(key: .commentCreationStyle, defaultValue: OWCommentCreationStyle.default).index)

    private var userDefaultsProvider: UserDefaultsProviderProtocol

    var styleModeIndex: AnyPublisher<Int, Never> {
        return customStyleModeSelectedIndex
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private var cancellables: Set<AnyCancellable> = []

    lazy var title: String = {
        return NSLocalizedString("CommentCreationSettings", comment: "")
    }()

    lazy var styleModeTitle: String = {
        return NSLocalizedString("StyleModeTitle", comment: "")
    }()

    lazy var styleModeSettings: [String] = {
        let _regular = NSLocalizedString("Regular", comment: "")
        let _light = NSLocalizedString("Light", comment: "")
        let _floatingKeyboard = NSLocalizedString("FloatingKeyboard", comment: "")

        return [_regular, _light, _floatingKeyboard]
    }()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

private extension CommentCreationSettingsVM {
    func setupObservers() {
        customStyleModeSelectedIndex
            .dropFirst()
            .map { styleIndex -> OWCommentCreationStyle in
                return OWCommentCreationStyle.commentCreationStyle(fromIndex: styleIndex)
            }
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<OWCommentCreationStyle>.commentCreationStyle))
            .store(in: &cancellables)
    }
}

extension CommentCreationSettingsVM: SettingsGroupVMProtocol {
    func resetToDefault() {
        customStyleModeSelectedIndex.send(0)
    }
}

extension OWCommentCreationStyle {
    var index: Int {
        switch self {
        case .regular:
            return OWCommentCreationStyleIndexer.regular.index
        case .light:
            return OWCommentCreationStyleIndexer.light.index
        case .floatingKeyboard:
            return OWCommentCreationStyleIndexer.floatingKeyboard.index
        default:
            return OWCommentCreationStyleIndexer.regular.index
        }
    }
}
