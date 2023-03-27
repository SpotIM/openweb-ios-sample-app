//
//  ConversationSettingsVM.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 27/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

#if NEW_API

protocol ConversationSettingsViewModelingInputs {
    var customStyleModeSelectedIndex: PublishSubject<Int> { get }
}

protocol ConversationSettingsViewModelingOutputs {
    var title: String { get }
    var customStyleModeTitle: String { get }
    var customStyleModeIndex: Observable<Int> { get }
    var customStyleModeSettings: [String] { get }
}

protocol ConversationSettingsViewModeling {
    var inputs: ConversationSettingsViewModelingInputs { get }
    var outputs: ConversationSettingsViewModelingOutputs { get }
}

class ConversationSettingsVM: ConversationSettingsViewModeling, ConversationSettingsViewModelingInputs, ConversationSettingsViewModelingOutputs {
    var inputs: ConversationSettingsViewModelingInputs { return self }
    var outputs: ConversationSettingsViewModelingOutputs { return self }

    var customStyleModeSelectedIndex = PublishSubject<Int>()

    fileprivate var userDefaultsProvider: UserDefaultsProviderProtocol

    var customStyleModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .conversationCustomStyleIndex, defaultValue: OWConversationStyle.defaultIndex)
    }

    fileprivate let disposeBag = DisposeBag()

    lazy var title: String = {
        return NSLocalizedString("ConversationSettings", comment: "")
    }()

    lazy var customStyleModeTitle: String = {
        return NSLocalizedString("CustomStyleModeTitle", comment: "")
    }()

    lazy var customStyleModeSettings: [String] = {
        let _regular = NSLocalizedString("Regular", comment: "")
        let _compact = NSLocalizedString("Compact", comment: "")

        return [_regular, _compact]
    }()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

extension ConversationSettingsVM {
    func setupObservers() {
        customStyleModeSelectedIndex
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<Int>.conversationCustomStyleIndex))
            .disposed(by: disposeBag)
    }
}

extension ConversationSettingsVM: SettingsGroupVMProtocol {

}
#endif
