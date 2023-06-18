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
    var customStyleModeSelectedIndex: BehaviorSubject<Int> { get }
}

protocol CommentCreationSettingsViewModelingOutputs {
    var title: String { get }
    var styleModeTitle: String { get }
    var styleModeIndex: Observable<Int> { get }
    var styleModeSettings: [String] { get }
}

protocol CommentCreationSettingsViewModeling {
    var inputs: CommentCreationSettingsViewModelingInputs { get }
    var outputs: CommentCreationSettingsViewModelingOutputs { get }
}

class CommentCreationSettingsVM: CommentCreationSettingsViewModeling, CommentCreationSettingsViewModelingInputs, CommentCreationSettingsViewModelingOutputs {
    fileprivate struct Metrics {
        static let delayInsertDataToPersistense = 100
    }
    
    var inputs: CommentCreationSettingsViewModelingInputs { return self }
    var outputs: CommentCreationSettingsViewModelingOutputs { return self }

    var customStyleModeSelectedIndex = BehaviorSubject<Int>(value: 0)

    fileprivate var userDefaultsProvider: UserDefaultsProviderProtocol

    var styleModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .commentCreationStyle, defaultValue: OWCommentCreationStyle.regular)
            .map { commentCreationStyle in
                switch commentCreationStyle {
                case .regular:
                    return 0
                case .light:
                    return 1
                case .floatingKeyboard:
                    return 2
                @unknown default:
                    return 0
                }
            }
            .asObservable()
    }

    fileprivate let disposeBag = DisposeBag()

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

    fileprivate lazy var styleModeObservable: Observable<OWCommentCreationStyle> = {
        return customStyleModeSelectedIndex
            .map { customStyleModeIndex -> OWCommentCreationStyle in
                return OWCommentCreationStyle.commentCreationStyle(fromIndex: customStyleModeIndex)
            }
            .asObservable()
    }()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

extension CommentCreationSettingsVM {
    func setupObservers() {
        styleModeObservable
            .throttle(.milliseconds(Metrics.delayInsertDataToPersistense), scheduler: MainScheduler.instance)
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<OWCommentCreationStyle>.commentCreationStyle))
            .disposed(by: disposeBag)
    }
}

extension CommentCreationSettingsVM: SettingsGroupVMProtocol {

}
#endif
