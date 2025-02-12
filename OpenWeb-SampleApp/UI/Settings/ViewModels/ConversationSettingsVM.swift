//
//  ConversationSettingsVM.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 27/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import OpenWebSDK

protocol ConversationSettingsViewModelingInputs {
    var styleModeSelectedIndex: BehaviorSubject<Int> { get }
    var communityGuidelinesStyleSelectedIndex: BehaviorSubject<Int> { get }
    var communityQuestionsStyleModeSelectedIndex: BehaviorSubject<Int> { get }
    var conversationSpacingSelectedIndex: BehaviorSubject<Int> { get }
    var betweenCommentsSpacingSelected: BehaviorSubject<String> { get }
    var communityGuidelinesSpacingSelected: BehaviorSubject<String> { get }
    var communityQuestionsGuidelinesSpacingSelected: BehaviorSubject<String> { get }
}

protocol ConversationSettingsViewModelingOutputs {
    var title: String { get }
    var styleModeTitle: String { get }
    var communityGuidelinesStyleModeTitle: String { get }
    var communityQuestionsStyleModeTitle: String { get }
    var conversationSpacingModeTitle: String { get }
    var betweenCommentsSpacingTitle: String { get }
    var communityGuidelinesSpacingTitle: String { get }
    var communityQuestionsGuidelinesSpacingTitle: String { get }
    var styleModeIndex: Observable<Int> { get }
    var communityGuidelinesStyleModeIndex: Observable<Int> { get }
    var communityQuestionsStyleModeIndex: Observable<Int> { get }
    var conversationSpacingModeIndex: Observable<Int> { get }
    var betweenCommentsSpacing: Observable<String> { get }
    var communityGuidelinesSpacing: Observable<String> { get }
    var communityQuestionsGuidelinesSpacing: Observable<String> { get }
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

class ConversationSettingsVM: ConversationSettingsViewModeling,
                              ConversationSettingsViewModelingInputs,
                              ConversationSettingsViewModelingOutputs {

    var inputs: ConversationSettingsViewModelingInputs { return self }
    var outputs: ConversationSettingsViewModelingOutputs { return self }

    lazy var styleModeSelectedIndex = BehaviorSubject<Int>(value: {
        let cs = userDefaultsProvider.get(key: .conversationStyle, defaultValue: OWConversationStyle.default)
        switch cs {
        case .regular:
            return OWConversationStyleIndexer.regular.index
        case .compact:
            return OWConversationStyleIndexer.compact.index
        case .custom:
            return OWConversationStyleIndexer.custom.index
        default:
            return OWConversationStyle.defaultIndex
        }
    }())

    lazy var communityGuidelinesStyleSelectedIndex = BehaviorSubject<Int>(value: {
        let cs = userDefaultsProvider.get(key: .conversationStyle, defaultValue: OWConversationStyle.default)
        if case .custom(let communityGuidelinesStyle, _, _) = cs {
            return communityGuidelinesStyle.index
        }
        return OWCommunityGuidelinesStyle.default.index
    }())

    lazy var communityQuestionsStyleModeSelectedIndex = BehaviorSubject<Int>(value: {
        let cs = userDefaultsProvider.get(key: .conversationStyle, defaultValue: OWConversationStyle.default)
        if case .custom(_, let communityQuestionsStyle, _) = cs {
            return communityQuestionsStyle.index
        }
        return OWCommunityQuestionStyle.default.index
    }())

    lazy var conversationSpacingSelectedIndex = BehaviorSubject<Int>(value: {
        let cs = userDefaultsProvider.get(key: .conversationStyle, defaultValue: OWConversationStyle.default)
        if case .custom(_, _, let spacing) = cs {
            switch spacing {
            case .regular:
                return OWConversationSpacingIndexer.regular.index
            case .compact:
                return OWConversationSpacingIndexer.compact.index
            case .custom:
                return OWConversationSpacingIndexer.custom.index
            default:
                return OWConversationSpacing.defaultIndex
            }
        }
        return OWConversationSpacing.defaultIndex
    }())

    lazy var betweenCommentsSpacingSelected = BehaviorSubject<String>(value: {
        let cs = userDefaultsProvider.get(key: .conversationStyle, defaultValue: OWConversationStyle.default)
        if case .custom(_, _, let spacing) = cs {
            if case .custom(let betweenComments, _, _) = spacing {
                return "\(betweenComments)"
            }
        }
        return "\(OWConversationSpacing.Metrics.defaultSpaceBetweenComments)"
    }())

    lazy var communityGuidelinesSpacingSelected = BehaviorSubject<String>(value: {
        let cs = userDefaultsProvider.get(key: .conversationStyle, defaultValue: OWConversationStyle.default)
        if case .custom(_, _, let spacing) = cs {
            if case .custom(_, let communityGuidelinesSpacing, _) = spacing {
                return "\(communityGuidelinesSpacing)"
            }
        }
        return "\(OWConversationSpacing.Metrics.defaultSpaceCommunityGuidelines)"
    }())

    lazy var communityQuestionsGuidelinesSpacingSelected = BehaviorSubject<String>(value: {
        let cs = userDefaultsProvider.get(key: .conversationStyle, defaultValue: OWConversationStyle.default)
        if case .custom(_, _, let spacing) = cs {
            if case .custom(_, _, let communityQuestionsSpacing) = spacing {
                return "\(communityQuestionsSpacing)"
            }
        }
        return "\(OWConversationSpacing.Metrics.defaultSpaceCommunityQuestions)"
    }())

    private var userDefaultsProvider: UserDefaultsProviderProtocol

    var styleModeIndex: Observable<Int> {
        return styleModeSelectedIndex.asObservable()
    }

    var communityGuidelinesStyleModeIndex: Observable<Int> {
        return communityGuidelinesStyleSelectedIndex.asObservable()
    }

    var communityQuestionsStyleModeIndex: Observable<Int> {
        return communityQuestionsStyleModeSelectedIndex.asObservable()
    }

    var conversationSpacingModeIndex: Observable<Int> {
        return conversationSpacingSelectedIndex.asObservable()
    }

    var betweenCommentsSpacing: Observable<String> {
        return betweenCommentsSpacingSelected.asObservable()
    }

    var communityGuidelinesSpacing: Observable<String> {
        return communityGuidelinesSpacingSelected.asObservable()
    }

    var communityQuestionsGuidelinesSpacing: Observable<String> {
        return communityQuestionsGuidelinesSpacingSelected.asObservable()
    }

    private let disposeBag = DisposeBag()

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

    lazy var communityGuidelinesSpacingTitle: String = {
        return NSLocalizedString("CommunityGuidelinesSpacingTitle", comment: "")
    }()

    lazy var communityQuestionsGuidelinesSpacingTitle: String = {
        return NSLocalizedString("CommunityQuestionsGuidelinesSpacingTitle", comment: "")
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
        let _compact = NSLocalizedString("Compact", comment: "")

        return [_none, _regular, _compact]
    }()

    lazy var conversationSpacingSettings: [String] = {
        let _regular = NSLocalizedString("Regular", comment: "")
        let _compact = NSLocalizedString("Compact", comment: "")
        let _custom = NSLocalizedString("Custom", comment: "")

        return [_regular, _compact, _custom]
    }()

    var showCustomStyleOptions: Observable<Bool> {
        return styleModeIndex
            .map { $0 == OWConversationStyleIndexer.custom.index } // Custom Style
            .asObservable()
    }

    var showSpacingOptions: Observable<Bool> {
        return conversationSpacingSelectedIndex
            .map { $0 == OWConversationStyleIndexer.custom.index } // Custom Spacing
            .asObservable()
    }

    // swiftlint:disable closure_parameter_position
    // Observer for all conversation style parameters to data
    private lazy var styleModeObservable: Observable<OWConversationStyle> = {
        return Observable.combineLatest(styleModeSelectedIndex,
                                        communityGuidelinesStyleSelectedIndex,
                                        communityQuestionsStyleModeSelectedIndex,
                                        betweenCommentsSpacingSelected,
                                        communityGuidelinesSpacingSelected,
                                        communityQuestionsGuidelinesSpacingSelected,
                                        conversationSpacingSelectedIndex) {
            styleIndex,
            communityGuidelinesStyleIndex,
            questionsStyleIndex,
            betweenCommentsSpace,
            communityGuidelinesSpace,
            communityQuestionsGuidelinesSpace,
            conversationSpacingIndex -> OWConversationStyle in

            return OWConversationStyle.conversationStyle(fromIndex: styleIndex,
                                                         communityGuidelinesStyleIndex: communityGuidelinesStyleIndex,
                                                         communityQuestionsStyleIndex: questionsStyleIndex,
                                                         spacingIndex: conversationSpacingIndex,
                                                         betweenComments: OWConversationSpacing.validateSpacing(betweenCommentsSpace),
                                                         belowCommunityGuidelines: OWConversationSpacing.validateSpacing(communityGuidelinesSpace),
                                                         belowCommunityQuestions: OWConversationSpacing.validateSpacing(communityQuestionsGuidelinesSpace))
        }
                                        .asObservable()
    }()
    // swiftlint:enable closure_parameter_position

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

private extension ConversationSettingsVM {
    func setupObservers() {
        // Conversation style mode data binder to persistence key conversationStyle
        styleModeObservable
            .skip(1)
            .bind(to: self.userDefaultsProvider.rxProtocol
            .setValues(key: UserDefaultsProvider.UDKey<OWConversationStyle>.conversationStyle))
            .disposed(by: disposeBag)
    }
}

extension ConversationSettingsVM: SettingsGroupVMProtocol {
    func resetToDefault() {
        styleModeSelectedIndex.onNext(OWConversationStyle.defaultIndex)
        communityGuidelinesStyleSelectedIndex.onNext(OWCommunityGuidelinesStyle.default.index)
        communityQuestionsStyleModeSelectedIndex.onNext(OWCommunityQuestionStyle.default.index)
        conversationSpacingSelectedIndex.onNext(OWConversationSpacing.defaultIndex)
        betweenCommentsSpacingSelected.onNext("\(OWConversationSpacing.Metrics.defaultSpaceBetweenComments)")
        communityGuidelinesSpacingSelected.onNext("\(OWConversationSpacing.Metrics.defaultSpaceCommunityGuidelines)")
        communityQuestionsGuidelinesSpacingSelected.onNext("\(OWConversationSpacing.Metrics.defaultSpaceCommunityQuestions)")
    }
}
