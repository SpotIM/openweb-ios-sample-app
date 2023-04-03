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
    var styleModeSelectedIndex: BehaviorSubject<Int> { get }
    var communityGuidelinesStyleSelectedIndex: BehaviorSubject<Int> { get }
    var communityQuestionsStyleModeSelectedIndex: BehaviorSubject<Int> { get }
    var conversationSpacingSelectedIndex: BehaviorSubject<Int> { get }
    var betweenCommentsSpacingSelected: BehaviorSubject<String> { get }
    var belowHeaderSpacingSelected: BehaviorSubject<String> { get }
    var belowCommunityGuidelinesSpacingSelected: BehaviorSubject<String> { get }
    var belowCommunityQuestionsGuidelinesSpacingSelected: BehaviorSubject<String> { get }
}

protocol ConversationSettingsViewModelingOutputs {
    var title: String { get }
    var styleModeTitle: String { get }
    var communityGuidelinesStyleModeTitle: String { get }
    var communityQuestionsStyleModeTitle: String { get }
    var conversationSpacingModeTitle: String { get }
    var betweenCommentsSpacingTitle: String { get }
    var belowHeaderSpacingTitle: String { get }
    var belowCommunityGuidelinesSpacingTitle: String { get }
    var belowCommunityQuestionsGuidelinesSpacingTitle: String { get }
    var styleModeIndex: Observable<Int> { get }
    var communityGuidelinesStyleModeIndex: Observable<Int> { get }
    var communityQuestionsStyleModeIndex: Observable<Int> { get }
    var conversationSpacingModeIndex: Observable<Int> { get }
    var betweenCommentsSpacing: Observable<String> { get }
    var belowHeaderSpacing: Observable<String> { get }
    var belowCommunityGuidelinesSpacing: Observable<String> { get }
    var belowCommunityQuestionsGuidelinesSpacing: Observable<String> { get }
    var styleModeSettings: [String] { get }
    var communityGuidelinesModeSettings: [String] { get }
    var communityQuestionsStyleModeSettings: [String] { get }
    var conversationSpacingSettings: [String] { get }
    var showCustomStyleOptions: Observable<Bool> { get }
    var showSpacingOptions: Observable<Bool> { get }
}

protocol ConversationSettingsViewModeling {
    var inputs: ConversationSettingsViewModelingInputs { get }
    var outputs: ConversationSettingsViewModelingOutputs { get }
}

class ConversationSettingsVM: ConversationSettingsViewModeling, ConversationSettingsViewModelingInputs, ConversationSettingsViewModelingOutputs {
    var inputs: ConversationSettingsViewModelingInputs { return self }
    var outputs: ConversationSettingsViewModelingOutputs { return self }

    var styleModeSelectedIndex = BehaviorSubject<Int>(value: OWConversationStyle.defaultIndex)
    var communityGuidelinesStyleSelectedIndex = BehaviorSubject<Int>(value: OWCommunityGuidelinesStyle.defaultIndex)
    var communityQuestionsStyleModeSelectedIndex = BehaviorSubject<Int>(value: OWCommunityQuestionsStyle.defaultIndex)
    var conversationSpacingSelectedIndex = BehaviorSubject<Int>(value: OWConversationSpacing.defaultIndex)
    var betweenCommentsSpacingSelected = BehaviorSubject<String>(value: "\(OWConversationSpacing.Metrics.defaultSpaceBetweenComments)")
    var belowHeaderSpacingSelected = BehaviorSubject<String>(value: "\(OWConversationSpacing.Metrics.defaultSpaceBelowHeader)")
    var belowCommunityGuidelinesSpacingSelected = BehaviorSubject<String>(value: "\(OWConversationSpacing.Metrics.defaultSpaceBelowCommunityGuidelines)")
    var belowCommunityQuestionsGuidelinesSpacingSelected = BehaviorSubject<String>(value: "\(OWConversationSpacing.Metrics.defaultSpaceBelowCommunityQuestions)")

    fileprivate var userDefaultsProvider: UserDefaultsProviderProtocol

    var styleModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .conversationStyle, defaultValue: OWConversationStyle.default)
            .map { conversationStyle in
                switch conversationStyle {
                case .regular:
                    return 0
                case .compact:
                    return 1
                case .custom(communityGuidelinesStyle: _, communityQuestionsStyle: _, spacing: _):
                    return 2
                default:
                    return OWConversationStyle.defaultIndex
                }
            }
            .asObservable()
    }

    var communityGuidelinesStyleModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .conversationStyle, defaultValue: OWConversationStyle.default)
            .map { conversationStyle in
                switch conversationStyle {
                case .custom(communityGuidelinesStyle: let communityGuidelines, communityQuestionsStyle: _, spacing: _):
                    switch communityGuidelines {
                    case .none:
                        return 0
                    case .regular:
                        return 1
                    case .compact:
                        return 2
                    default:
                        return OWCommunityGuidelinesStyle.defaultIndex
                    }
                default:
                    return OWCommunityGuidelinesStyle.defaultIndex
                }
            }
            .asObservable()
    }

    var communityQuestionsStyleModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .conversationStyle, defaultValue: OWConversationStyle.default)
            .map { conversationStyle in
                switch conversationStyle {
                case .custom(communityGuidelinesStyle: _, communityQuestionsStyle: let communityQuestions, spacing: _):
                    switch communityQuestions {
                    case .none:
                        return 0
                    case .regular:
                        return 1
                    default:
                        return OWCommunityQuestionsStyle.defaultIndex
                    }
                default:
                    return OWCommunityQuestionsStyle.defaultIndex
                }
            }
            .asObservable()
    }

    var conversationSpacingModeIndex: Observable<Int> {
        return userDefaultsProvider.values(key: .conversationStyle, defaultValue: OWConversationStyle.default)
            .map { conversationStyle in
                switch conversationStyle {
                case .custom(communityGuidelinesStyle: _, communityQuestionsStyle: _, spacing: let spacingMode):
                    switch spacingMode {
                    case .regular:
                        return 0
                    case .compact:
                        return 1
                    case .custom(betweenComments: _, belowHeader: _, belowCommunityGuidelines: _, belowCommunityQuestions: _):
                        return 2
                    default:
                        return OWConversationSpacing.defaultIndex
                    }
                default:
                    return OWConversationSpacing.defaultIndex
                }
            }
            .asObservable()
    }

    var betweenCommentsSpacing: Observable<String> {
        return userDefaultsProvider.values(key: .conversationStyle, defaultValue: OWConversationStyle.default)
            .map { conversationStyle in
                switch conversationStyle {
                case .custom(communityGuidelinesStyle: _, communityQuestionsStyle: _, spacing: let spacingMode):
                    switch spacingMode {
                    case .custom(betweenComments: let betweenComments, belowHeader: _, belowCommunityGuidelines: _, belowCommunityQuestions: _):
                        return "\(betweenComments)"
                    default:
                        return "\(OWConversationSpacing.Metrics.defaultSpaceBelowHeader)"
                    }
                default:
                    return "\(OWConversationSpacing.Metrics.defaultSpaceBelowHeader)"
                }
            }
            .asObservable()
    }

    var belowHeaderSpacing: Observable<String> {
        return userDefaultsProvider.values(key: .conversationStyle, defaultValue: OWConversationStyle.default)
            .map { conversationStyle in
                switch conversationStyle {
                case .custom(communityGuidelinesStyle: _, communityQuestionsStyle: _, spacing: let spacingMode):
                    switch spacingMode {
                    case .custom(betweenComments: _, belowHeader: let belowHeader, belowCommunityGuidelines: _, belowCommunityQuestions: _):
                        return "\(belowHeader)"
                    default:
                        return "\(OWConversationSpacing.Metrics.defaultSpaceBelowHeader)"
                    }
                default:
                    return "\(OWConversationSpacing.Metrics.defaultSpaceBelowHeader)"
                }
            }
            .asObservable()
    }

    var belowCommunityGuidelinesSpacing: Observable<String> {
        return userDefaultsProvider.values(key: .conversationStyle, defaultValue: OWConversationStyle.default)
            .map { conversationStyle in
                switch conversationStyle {
                case .custom(communityGuidelinesStyle: _, communityQuestionsStyle: _, spacing: let spacingMode):
                    switch spacingMode {
                    case .custom(betweenComments: _, belowHeader: _, belowCommunityGuidelines: let belowCommunityGuidelines, belowCommunityQuestions: _):
                        return "\(belowCommunityGuidelines)"
                    default:
                        return "\(OWConversationSpacing.Metrics.defaultSpaceBelowHeader)"
                    }
                default:
                    return "\(OWConversationSpacing.Metrics.defaultSpaceBelowHeader)"
                }
            }
            .asObservable()
    }

    var belowCommunityQuestionsGuidelinesSpacing: Observable<String> {
        return userDefaultsProvider.values(key: .conversationStyle, defaultValue: OWConversationStyle.default)
            .map { conversationStyle in
                switch conversationStyle {
                case .custom(communityGuidelinesStyle: _, communityQuestionsStyle: _, spacing: let spacingMode):
                    switch spacingMode {
                    case .custom(betweenComments: _, belowHeader: _, belowCommunityGuidelines: _, belowCommunityQuestions: let belowCommunityQuestions):
                        return "\(belowCommunityQuestions)"
                    default:
                        return "\(OWConversationSpacing.Metrics.defaultSpaceBelowHeader)"
                    }
                default:
                    return "\(OWConversationSpacing.Metrics.defaultSpaceBelowHeader)"
                }
            }
            .asObservable()
    }

    fileprivate let disposeBag = DisposeBag()

    lazy var title: String = {
        return NSLocalizedString("ConversationSettings", comment: "")
    }()

    lazy var styleModeTitle: String = {
        return NSLocalizedString("StyleModeTitle", comment: "")
    }()

    lazy var communityGuidelinesStyleModeTitle: String = {
        return NSLocalizedString("CommunityGuidelinesStyleModeTitle", comment: "")
    }()

    lazy var communityQuestionsStyleModeTitle: String = {
        return NSLocalizedString("QuestionsStyleModeTitle", comment: "")
    }()

    lazy var conversationSpacingModeTitle: String = {
        return NSLocalizedString("ConversationSpacingModeTitle", comment: "")
    }()

    lazy var betweenCommentsSpacingTitle: String = {
        return NSLocalizedString("BetweenCommentsSpacingTitle", comment: "")
    }()

    lazy var belowHeaderSpacingTitle: String = {
        return NSLocalizedString("BelowHeaderSpacingTitle", comment: "")
    }()

    lazy var belowCommunityGuidelinesSpacingTitle: String = {
        return NSLocalizedString("BelowCommunityGuidelinesSpacingTitle", comment: "")
    }()

    lazy var belowCommunityQuestionsGuidelinesSpacingTitle: String = {
        return NSLocalizedString("BelowCommunityQuestionsGuidelinesSpacingTitle", comment: "")
    }()

    lazy var styleModeSettings: [String] = {
        let _regular = NSLocalizedString("Regular", comment: "")
        let _compact = NSLocalizedString("Compact", comment: "")
        let _custom = NSLocalizedString("Custom", comment: "")

        return [_regular, _compact, _custom]
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

        return [_none, _regular]
    }()

    lazy var conversationSpacingSettings: [String] = {
        let _regular = NSLocalizedString("Regular", comment: "")
        let _compact = NSLocalizedString("Compact", comment: "")
        let _custom = NSLocalizedString("Custom", comment: "")

        return [_regular, _compact, _custom]
    }()

    var showCustomStyleOptions: Observable<Bool> {
        return styleModeIndex
            .map { $0 == OWConversationStyle.customIndex } // Custom Style
            .asObservable()
    }

    var showSpacingOptions: Observable<Bool> {
        return conversationSpacingSelectedIndex
            .map { $0 == OWConversationStyle.customIndex } // Custom Spacing
            .asObservable()
    }

    // swiftlint:disable closure_parameter_position
    // Observer for all conversation style parameters to data
    fileprivate lazy var styleModeObservable =
    Observable.combineLatest(styleModeSelectedIndex,
                             communityGuidelinesStyleSelectedIndex,
                             communityQuestionsStyleModeSelectedIndex,
                             conversationSpacingSelectedIndex,
                             betweenCommentsSpacingSelected,
                             belowHeaderSpacingSelected,
                             belowCommunityGuidelinesSpacingSelected,
                             belowCommunityQuestionsGuidelinesSpacingSelected) {
        styleIndex,
        communityGuidelinesStyleIndex,
        questionsStyleIndex,
        conversationSpacingIndex,
        betweenCommentsSpace,
        belowHeaderSpace,
        belowCommunityGuidelinesSpace,
        belowCommunityQuestionsGuidelinesSpace -> OWConversationStyle in

        return OWConversationStyle.conversationStyle(fromIndex: styleIndex,
                                                     communityGuidelinesStyleIndex: communityGuidelinesStyleIndex,
                                                     communityQuestionsStyleIndex: questionsStyleIndex,
                                                     spacingIndex: conversationSpacingIndex,
                                                     betweenComments: OWConversationSpacing.validateSpacing(betweenCommentsSpace),
                                                     belowHeader: OWConversationSpacing.validateSpacing(belowHeaderSpace),
                                                     belowCommunityGuidelines: OWConversationSpacing.validateSpacing(belowCommunityGuidelinesSpace),
                                                     belowCommunityQuestions: OWConversationSpacing.validateSpacing(belowCommunityQuestionsGuidelinesSpace))
    }
    .skip(8)
    .asObservable()
    // swiftlint:enable closure_parameter_position

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

extension ConversationSettingsVM {
    func setupObservers() {
        // Conversation style mode data binder to persistence key conversationStyle
        styleModeObservable
            .skip(1)
            .bind(to: userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<OWConversationStyle>.conversationStyle))
            .disposed(by: disposeBag)
    }
}

extension ConversationSettingsVM: SettingsGroupVMProtocol {

}
#endif
