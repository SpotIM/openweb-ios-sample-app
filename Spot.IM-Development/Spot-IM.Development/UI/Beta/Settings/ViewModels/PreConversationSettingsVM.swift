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
    var customStyleModeSelectedLines: BehaviorSubject<Int> { get }
}

protocol PreConversationSettingsViewModelingOutputs {
    var title: String { get }
    var customStyleModeTitle: String { get }
    var customStyleLinesTitle: String { get }
    var customStyleModeIndex: Observable<Int> { get }
    var customStyleLines: Observable<Int> { get }
    var customStyleModeSettings: [String] { get }
    var showCustomStyleLines: Observable<Bool> { get }
    var customStyleLinesSettings: [String] { get }
}

protocol PreConversationSettingsViewModeling {
    var inputs: PreConversationSettingsViewModelingInputs { get }
    var outputs: PreConversationSettingsViewModelingOutputs { get }
}

class PreConversationSettingsVM: PreConversationSettingsViewModeling, PreConversationSettingsViewModelingInputs, PreConversationSettingsViewModelingOutputs {
    var inputs: PreConversationSettingsViewModelingInputs { return self }
    var outputs: PreConversationSettingsViewModelingOutputs { return self }

    var customStyleModeSelectedIndex = BehaviorSubject<Int>(value: 0)
    var customStyleModeSelectedLines = BehaviorSubject<Int>(value: 0)

    fileprivate lazy var customStyleModeObservable =
    Observable.combineLatest(customStyleModeSelectedIndex, customStyleModeSelectedLines) { index, numberOfComments -> Data in
        return OWPreConversationStyle.preConversationStyle(fromIndex: index, numberOfComments: numberOfComments).data
    }
    .skip(2)
    .asObservable()

    fileprivate var userDefaultsProvider: UserDefaultsProviderProtocol

    var showCustomStyleLines: Observable<Bool> {
        return customStyleModeIndex
            .map { $0 == 0 }
            .asObservable()
    }

    var customStyleModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .preConversationCustomStyle, defaultValue: Data())
            .map {
                let preConversationStyle = OWPreConversationStyle.preConversationStyle(fromData: $0)
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

    var customStyleLines: Observable<Int> {
        return userDefaultsProvider.values(key: .preConversationCustomStyle, defaultValue: Data())
            .map {
                let customStyle = OWPreConversationStyle.preConversationStyle(fromData: $0)
                switch customStyle {
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

    lazy var customStyleModeTitle: String = {
        return NSLocalizedString("CustomStyleModeTitle", comment: "")
    }()

    lazy var customStyleLinesTitle: String = {
        return NSLocalizedString("CustomStyleLinesTitle", comment: "")
    }()

    lazy var customStyleModeSettings: [String] = {
        let _regular = NSLocalizedString("Regular", comment: "")
        let _compact = NSLocalizedString("Compact", comment: "")
        let _ctaButtonOnly = NSLocalizedString("CTAButtonOnly", comment: "")
        let _ctaWithSummary = NSLocalizedString("CTAWithSummary", comment: "")

        return [_regular, _compact, _ctaButtonOnly, _ctaWithSummary]
    }()

    fileprivate let min = OWPreConversationStyle.Metrics.minNumberOfComments
    fileprivate let max = OWPreConversationStyle.Metrics.maxNumberOfComments
    lazy var customStyleLinesSettings: [String] = {
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
            .setValues(key: UserDefaultsProvider.UDKey<Data>.preConversationCustomStyle))
            .disposed(by: disposeBag)
    }
}

extension PreConversationSettingsVM: SettingsGroupVMProtocol {

}
#endif
