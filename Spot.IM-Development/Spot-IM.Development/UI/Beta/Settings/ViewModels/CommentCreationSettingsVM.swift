//
//  CommentCreationSettingsVM.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

#if NEW_API

protocol CommentCreationSettingsViewModelingInputs {
    var customStyleModeSelectedIndex: PublishSubject<Int> { get }
}

protocol CommentCreationSettingsViewModelingOutputs {
    var title: String { get }
    var customStyleModeTitle: String { get }
    var customStyleModeIndex: Observable<Int> { get }
    var customStyleModeSettings: [String] { get }
}

protocol CommentCreationSettingsViewModeling {
    var inputs: CommentCreationSettingsViewModelingInputs { get }
    var outputs: CommentCreationSettingsViewModelingOutputs { get }
}

class CommentCreationSettingsVM: CommentCreationSettingsViewModeling, CommentCreationSettingsViewModelingInputs, CommentCreationSettingsViewModelingOutputs {
    var inputs: CommentCreationSettingsViewModelingInputs { return self }
    var outputs: CommentCreationSettingsViewModelingOutputs { return self }

    var customStyleModeSelectedIndex = PublishSubject<Int>()

    fileprivate var userDefaultsProvider: UserDefaultsProviderProtocol

    var customStyleModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .commentCreationCustomStyleIndex, defaultValue: 0)
    }

    fileprivate let disposeBag = DisposeBag()

    lazy var title: String = {
        return NSLocalizedString("CommentCreationSettings", comment: "")
    }()

    lazy var customStyleModeTitle: String = {
        return NSLocalizedString("CustomStyleModeTitle", comment: "")
    }()

    lazy var customStyleModeSettings: [String] = {
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

extension CommentCreationSettingsVM {
    func setupObservers() {
        customStyleModeSelectedIndex
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<Int>.commentCreationCustomStyleIndex))
            .disposed(by: disposeBag)
    }
}

extension CommentCreationSettingsVM: SettingsGroupVMProtocol {

}
#endif
