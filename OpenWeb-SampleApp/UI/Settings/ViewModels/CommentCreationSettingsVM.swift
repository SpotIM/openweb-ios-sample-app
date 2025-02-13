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
    var accessoryViewSelectedIndex: CurrentValueSubject<Int, Never> { get }
}

protocol CommentCreationSettingsViewModelingOutputs {
    var title: String { get }
    var styleModeTitle: String { get }
    var accessoryViewTitle: String { get }
    var styleModeIndex: AnyPublisher<Int, Never> { get }
    var accessoryViewIndex: AnyPublisher<Int, Never> { get }
    var styleModeSettings: [String] { get }
    var accessoryViewSettings: [String] { get }
    var hideAccessoryViewOptions: AnyPublisher<Bool, Never> { get }
}

protocol CommentCreationSettingsViewModeling {
    var inputs: CommentCreationSettingsViewModelingInputs { get }
    var outputs: CommentCreationSettingsViewModelingOutputs { get }
}

class CommentCreationSettingsVM: CommentCreationSettingsViewModeling, CommentCreationSettingsViewModelingInputs, CommentCreationSettingsViewModelingOutputs {

    var inputs: CommentCreationSettingsViewModelingInputs { return self }
    var outputs: CommentCreationSettingsViewModelingOutputs { return self }

    lazy var customStyleModeSelectedIndex = CurrentValueSubject<Int, Never>(userDefaultsProvider.get(key: .commentCreationStyle, defaultValue: OWCommentCreationStyle.default).index)

    lazy var accessoryViewSelectedIndex = CurrentValueSubject<Int, Never>({
        let defaultStyle = userDefaultsProvider.get(key: .commentCreationStyle, defaultValue: OWCommentCreationStyle.default)
        switch defaultStyle {
        case .floatingKeyboard(let accessoryViewStrategy):
            return accessoryViewStrategy.index
        default:
            return 0
        }
    }())

    private var userDefaultsProvider: UserDefaultsProviderProtocol

    var accessoryViewIndex: AnyPublisher<Int, Never> {
        return accessoryViewSelectedIndex
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var styleModeIndex: AnyPublisher<Int, Never> {
        return customStyleModeSelectedIndex
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var hideAccessoryViewOptions: AnyPublisher<Bool, Never> {
        return customStyleModeSelectedIndex
            .map {
                if case .floatingKeyboard = OWCommentCreationStyle.commentCreationStyle(fromIndex: $0) {
                    return false
                }
                return true
            }
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

    lazy var accessoryViewTitle: String = {
        return NSLocalizedString("AccessoryView", comment: "")
    }()

    lazy var styleModeSettings: [String] = {
        let _regular = NSLocalizedString("Regular", comment: "")
        let _light = NSLocalizedString("Light", comment: "")
        let _floatingKeyboard = NSLocalizedString("FloatingKeyboard", comment: "")

        return [_regular, _light, _floatingKeyboard]
    }()

    lazy var accessoryViewSettings: [String] = {
        let _none = NSLocalizedString("None", comment: "")
        let _toolbar = NSLocalizedString("Toolbar", comment: "")

        return [_none, _toolbar]
    }()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

private extension CommentCreationSettingsVM {
    func setupObservers() {
        Publishers.CombineLatest(customStyleModeSelectedIndex, accessoryViewSelectedIndex)
            .dropFirst()
            .map { styleIndex, accessoryViewIndex -> OWCommentCreationStyle in
                var style = OWCommentCreationStyle.commentCreationStyle(fromIndex: styleIndex)
                if case .floatingKeyboard = style {
                    let accessoryViewStrategy = OWAccessoryViewStrategy(index: accessoryViewIndex)
                    style = .floatingKeyboard(accessoryViewStrategy: accessoryViewStrategy)
                }
                return style
            }
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<OWCommentCreationStyle>.commentCreationStyle))
            .store(in: &cancellables)
    }
}

extension CommentCreationSettingsVM: SettingsGroupVMProtocol {
    func resetToDefault() {
        customStyleModeSelectedIndex.send(0)
        accessoryViewSelectedIndex.send(0)
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
