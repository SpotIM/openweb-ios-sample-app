//
//  CommentCreationSettingsVM.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import OpenWebSDK

protocol CommentCreationSettingsViewModelingInputs {
    var customStyleModeSelectedIndex: BehaviorSubject<Int> { get }
    var accessoryViewSelectedIndex: BehaviorSubject<Int> { get }
}

protocol CommentCreationSettingsViewModelingOutputs {
    var title: String { get }
    var styleModeTitle: String { get }
    var accessoryViewTitle: String { get }
    var styleModeIndex: Observable<Int> { get }
    var accessoryViewIndex: Observable<Int> { get }
    var styleModeSettings: [String] { get }
    var accessoryViewSettings: [String] { get }
    var hideAccessoryViewOptions: Observable<Bool> { get }
}

protocol CommentCreationSettingsViewModeling {
    var inputs: CommentCreationSettingsViewModelingInputs { get }
    var outputs: CommentCreationSettingsViewModelingOutputs { get }
}

class CommentCreationSettingsVM: CommentCreationSettingsViewModeling, CommentCreationSettingsViewModelingInputs, CommentCreationSettingsViewModelingOutputs {

    var inputs: CommentCreationSettingsViewModelingInputs { return self }
    var outputs: CommentCreationSettingsViewModelingOutputs { return self }

    var customStyleModeSelectedIndex = BehaviorSubject<Int>(value: 0)
    var accessoryViewSelectedIndex = BehaviorSubject<Int>(value: 0)

    private var userDefaultsProvider: UserDefaultsProviderProtocol

    var accessoryViewIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .commentCreationStyle, defaultValue: OWCommentCreationStyle.default)
            .map { commentCreationStyle in
                switch commentCreationStyle {
                case .floatingKeyboard(let accessoryViewStrategy):
                    return accessoryViewStrategy.index
                default:
                    return 0
                }
            }
            .asObservable()
    }

    var styleModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .commentCreationStyle, defaultValue: OWCommentCreationStyle.default)
            .map { commentCreationStyle in
                switch commentCreationStyle {
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
            .asObservable()
    }

    var hideAccessoryViewOptions: Observable<Bool> {
        return customStyleModeSelectedIndex
            .map {
                if case .floatingKeyboard = OWCommentCreationStyle.commentCreationStyle(fromIndex: $0) {
                    return false
                }
                return true
            }
            .asObservable()
    }

    private let disposeBag = DisposeBag()

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

    private lazy var styleModeObservable: Observable<OWCommentCreationStyle> = {
        return Observable.combineLatest(customStyleModeSelectedIndex,
                                        accessoryViewSelectedIndex)
            .map { customStyleModeIndex, accessoryViewIndex -> OWCommentCreationStyle in
                var style = OWCommentCreationStyle.commentCreationStyle(fromIndex: customStyleModeIndex)
                if case .floatingKeyboard = style {
                    let accessoryViewStrategy = OWAccessoryViewStrategy(index: accessoryViewIndex)
                    style = .floatingKeyboard(accessoryViewStrategy: accessoryViewStrategy)
                }
                return style
            }
            .asObservable()
    }()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

private extension CommentCreationSettingsVM {
    func setupObservers() {
        styleModeObservable
            .takeLast(1)
            .bind(to: self.userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<OWCommentCreationStyle>.commentCreationStyle))
            .disposed(by: disposeBag)
    }
}

extension CommentCreationSettingsVM: SettingsGroupVMProtocol {
    func resetToDefault() {
        customStyleModeSelectedIndex.onNext(0)
        accessoryViewSelectedIndex.onNext(0)
    }
}
