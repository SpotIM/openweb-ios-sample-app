//
//  PreConversationSettingsVM.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 27/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

#if NEW_API

protocol PreConversationSettingsViewModelingInputs {
    var customStyleModeSelectedIndex: BehaviorSubject<Int> { get }
    var customStyleModeSelectedNumberOfComments: BehaviorSubject<Int> { get }
}

protocol PreConversationSettingsViewModelingOutputs {
    var title: String { get }
    var styleModeTitle: String { get }
    var customStyleNumberOfCommentsTitle: String { get }
    var styleModeIndex: Observable<Int> { get }
    var customStyleNumberOfComments: Observable<Int> { get }
    var styleModeSettings: [String] { get }
    var showCustomStyleNumberOfComments: Observable<Bool> { get }
    var customStyleNumberOfCommentsSettings: [String] { get }
}

protocol PreConversationSettingsViewModeling {
    var inputs: PreConversationSettingsViewModelingInputs { get }
    var outputs: PreConversationSettingsViewModelingOutputs { get }
}

class PreConversationSettingsVM: PreConversationSettingsViewModeling, PreConversationSettingsViewModelingInputs, PreConversationSettingsViewModelingOutputs {
    var inputs: PreConversationSettingsViewModelingInputs { return self }
    var outputs: PreConversationSettingsViewModelingOutputs { return self }

    var customStyleModeSelectedIndex = BehaviorSubject<Int>(value: 0)
    var customStyleModeSelectedNumberOfComments = BehaviorSubject<Int>(value: 0)

    fileprivate lazy var customStyleModeObservable =
    Observable.combineLatest(customStyleModeSelectedIndex, customStyleModeSelectedNumberOfComments) { index, numberOfComments -> OWPreConversationStyle in
        return OWPreConversationStyle.preConversationStyle(fromIndex: index, numberOfComments: numberOfComments)
    }
    .skip(2)
    .asObservable()

    fileprivate var userDefaultsProvider: UserDefaultsProviderProtocol

    var showCustomStyleNumberOfComments: Observable<Bool> {
        return styleModeIndex
            .map { $0 == 0 }
            .asObservable()
    }

    var styleModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .preConversationStyle, defaultValue: OWPreConversationStyle.default)
            .map { preConversationStyle in
                switch preConversationStyle {
                case .regular(numberOfComments: _):
                    return 0
                case .compact:
                    return 1
                case .ctaButtonOnly:
                    return 2
                case .ctaWithSummary:
                    return 3
                default:
                    return 0
                }
            }
            .asObservable()
    }

    var customStyleNumberOfComments: Observable<Int> {
        return userDefaultsProvider.values(key: .preConversationStyle, defaultValue: OWPreConversationStyle.default)
            .map { preConversationStyle in
                switch preConversationStyle {
                case .regular(numberOfComments: let numberOfComments):
                    return numberOfComments
                default:
                    return OWPreConversationStyle.Metrics.defaultRegularNumberOfComments
                }
            }
            .asObservable()
    }

    fileprivate let disposeBag = DisposeBag()

    lazy var title: String = {
        return NSLocalizedString("PreConversationSettings", comment: "")
    }()

    lazy var styleModeTitle: String = {
        return NSLocalizedString("StyleModeTitle", comment: "")
    }()

    lazy var customStyleNumberOfCommentsTitle: String = {
        return NSLocalizedString("CustomStyleNumberOfCommentsTitle", comment: "")
    }()

    lazy var styleModeSettings: [String] = {
        let _regular = NSLocalizedString("Regular", comment: "")
        let _compact = NSLocalizedString("Compact", comment: "")
        let _ctaButtonOnly = NSLocalizedString("CTAButtonOnly", comment: "")
        let _ctaWithSummary = NSLocalizedString("CTAWithSummary", comment: "")

        return [_regular, _compact, _ctaButtonOnly, _ctaWithSummary]
    }()

    fileprivate let min = OWPreConversationStyle.Metrics.minNumberOfComments
    fileprivate let max = OWPreConversationStyle.Metrics.maxNumberOfComments
    lazy var customStyleNumberOfCommentsSettings: [String] = {
        Array(min...max).map { String($0) }
    }()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

extension PreConversationSettingsVM {
    func setupObservers() {
        customStyleModeObservable
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<OWPreConversationStyle>.preConversationStyle))
            .disposed(by: disposeBag)
    }
}

extension PreConversationSettingsVM: SettingsGroupVMProtocol {

}
#endif
