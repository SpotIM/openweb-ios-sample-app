//
//  PreConversationSettingsVM.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 27/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import OpenWebSDK

protocol PreConversationSettingsViewModelingInputs {
    var customStyleModeSelectedIndex: BehaviorSubject<Int> { get }
    var customStyleModeSelectedNumberOfComments: BehaviorSubject<Int> { get }
    var communityGuidelinesStyleSelectedIndex: BehaviorSubject<Int> { get }
    var communityQuestionsStyleModeSelectedIndex: BehaviorSubject<Int> { get }
}

protocol PreConversationSettingsViewModelingOutputs {
    var title: String { get }
    var styleModeTitle: String { get }
    var styleModeIndex: Observable<Int> { get }
    var styleModeSettings: [String] { get }
    var customStyleNumberOfCommentsTitle: String { get }
    var customStyleNumberOfComments: Observable<Int> { get }
    var showCustomStyleOptions: Observable<Bool> { get }
    var customStyleNumberOfCommentsSettings: [String] { get }
    var communityGuidelinesStyleModeTitle: String { get }
    var communityQuestionsStyleModeTitle: String { get }
    var communityGuidelinesStyleModeIndex: Observable<Int> { get }
    var communityQuestionsStyleModeIndex: Observable<Int> { get }
    var communityGuidelinesModeSettings: [String] { get }
    var communityQuestionsStyleModeSettings: [String] { get }
}

protocol PreConversationSettingsViewModeling {
    var inputs: PreConversationSettingsViewModelingInputs { get }
    var outputs: PreConversationSettingsViewModelingOutputs { get }
}

class PreConversationSettingsVM: PreConversationSettingsViewModeling,
                                 PreConversationSettingsViewModelingInputs,
                                 PreConversationSettingsViewModelingOutputs {
    private struct Metrics {
        static let delayInsertDataToPersistense = 100
    }

    var inputs: PreConversationSettingsViewModelingInputs { return self }
    var outputs: PreConversationSettingsViewModelingOutputs { return self }

    var customStyleModeSelectedIndex = BehaviorSubject<Int>(value: OWPreConversationStyle.defaultIndex)
    var customStyleModeSelectedNumberOfComments = BehaviorSubject<Int>(value: 0)
    var communityGuidelinesStyleSelectedIndex = BehaviorSubject<Int>(value: OWCommunityGuidelinesStyle.default.index)
    var communityQuestionsStyleModeSelectedIndex = BehaviorSubject<Int>(value: OWCommunityQuestionStyle.default.index)

    private var userDefaultsProvider: UserDefaultsProviderProtocol

    var showCustomStyleOptions: Observable<Bool> {
        return styleModeIndex
            .map { $0 == OWPreConversationStyleIndexer.custom.index } // Custom Style
            .asObservable()
    }

    var styleModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .preConversationStyle, defaultValue: OWPreConversationStyle.default)
            .map { preConversationStyle in
                switch preConversationStyle {
                case .regular:
                    return OWPreConversationStyleIndexer.regular.index
                case .compact:
                    return OWPreConversationStyleIndexer.compact.index
                case .ctaButtonOnly:
                    return OWPreConversationStyleIndexer.ctaButtonOnly.index
                case .ctaWithSummary:
                    return OWPreConversationStyleIndexer.ctaWithSummary.index
                case .custom:
                    return OWPreConversationStyleIndexer.custom.index
                default:
                    return OWPreConversationStyleIndexer.regular.index
                }
            }
            .asObservable()
    }

    var customStyleNumberOfComments: Observable<Int> {
        return userDefaultsProvider.values(key: .preConversationStyle, defaultValue: OWPreConversationStyle.default)
            .map { preConversationStyle in
                switch preConversationStyle {
                case .custom(let numberOfComments, _, _, _):
                    return numberOfComments
                default:
                    return OWPreConversationStyle.Metrics.defaultRegularNumberOfComments
                }
            }
            .asObservable()
    }

    var communityGuidelinesStyleModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .preConversationStyle, defaultValue: OWPreConversationStyle.default)
            .map { preConversationStyle in
                switch preConversationStyle {
                case .custom(_, let communityGuidelinesStyle, _, _):
                    return communityGuidelinesStyle.index
                default:
                    return OWCommunityGuidelinesStyle.default.index
                }
            }
            .asObservable()
    }

    var communityQuestionsStyleModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .preConversationStyle, defaultValue: OWPreConversationStyle.default)
            .map { preConversationStyle in
                switch preConversationStyle {
                case .custom(_, _, let communityQuestionStyle, _):
                    return communityQuestionStyle.index
                default:
                    return OWCommunityQuestionStyle.default.index
                }
            }
            .asObservable()
    }

    private let disposeBag = DisposeBag()

    lazy var title: String = {
        return NSLocalizedString("PreConversationSettings", comment: "")
    }()

    lazy var styleModeTitle: String = {
        return NSLocalizedString("StyleModeTitle", comment: "")
    }()

    lazy var customStyleNumberOfCommentsTitle: String = {
        return NSLocalizedString("CustomStyleNumberOfCommentsTitle", comment: "")
    }()

    lazy var communityGuidelinesStyleModeTitle: String = {
        return NSLocalizedString("CommunityGuidelinesStyleModeTitle", comment: "")
    }()

    lazy var communityQuestionsStyleModeTitle: String = {
        return NSLocalizedString("QuestionsStyleModeTitle", comment: "")
    }()

    lazy var styleModeSettings: [String] = {
        let _regular = NSLocalizedString("Regular", comment: "")
        let _compact = NSLocalizedString("Compact", comment: "")
        let _ctaButtonOnly = NSLocalizedString("CTAButtonOnly", comment: "")
        let _ctaWithSummary = NSLocalizedString("CTAWithSummary", comment: "")
        let _custom = NSLocalizedString("Custom", comment: "")

        return [_regular, _compact, _ctaButtonOnly, _ctaWithSummary, _custom]
    }()

    lazy var communityGuidelinesModeSettings: [String] = {
        let _none = NSLocalizedString("None", comment: "")
        let _regular = NSLocalizedString("Regular", comment: "")
        let _compact = NSLocalizedString("Compact", comment: "")

        return [_none, _regular, _compact]
    }()

    lazy var communityQuestionsStyleModeSettings: [String] = {
        let _none = NSLocalizedString("None", comment: "")
        let _regular = NSLocalizedString("Regular", comment: "")
        let _compact = NSLocalizedString("Compact", comment: "")

        return [_none, _regular, _compact]
    }()

    private let min = OWPreConversationStyle.Metrics.minNumberOfComments
    private let max = OWPreConversationStyle.Metrics.maxNumberOfComments
    lazy var customStyleNumberOfCommentsSettings: [String] = {
        Array(min...max).map { String($0) }
    }()

    // swiftlint:disable closure_parameter_position
    private lazy var customStyleModeObservable: Observable<OWPreConversationStyle> = {
        return Observable.combineLatest(customStyleModeSelectedIndex,
                                        customStyleModeSelectedNumberOfComments,
                                        communityGuidelinesStyleSelectedIndex,
                                        communityQuestionsStyleModeSelectedIndex) {
            styleIndex,
            numberOfComments,
            communityGuidelinesStyleIndex,
            questionStyleIndex -> OWPreConversationStyle in

            return OWPreConversationStyle.preConversationStyle(fromIndex: styleIndex,
                                                               numberOfComments: numberOfComments,
                                                               communityGuidelinesStyleIndex: communityGuidelinesStyleIndex,
                                                               communityQuestionsStyleIndex: questionStyleIndex)
        }
                                        .asObservable()
    }()
    // swiftlint:enable closure_parameter_position

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

private extension PreConversationSettingsVM {
    func setupObservers() {
        customStyleModeObservable
            .skip(1)
            .throttle(.milliseconds(Metrics.delayInsertDataToPersistense), scheduler: MainScheduler.instance)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<OWPreConversationStyle>.preConversationStyle))
            .disposed(by: disposeBag)
    }
}

extension PreConversationSettingsVM: SettingsGroupVMProtocol {
    func resetToDefault() {
        customStyleModeSelectedIndex.onNext(OWPreConversationStyle.defaultIndex)
        customStyleModeSelectedNumberOfComments.onNext(0)
        communityGuidelinesStyleSelectedIndex.onNext(OWCommunityGuidelinesStyle.default.index)
        communityQuestionsStyleModeSelectedIndex.onNext(OWCommunityQuestionStyle.default.index)
    }
}
