//
//  ConversationSettingsVM.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 27/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import Combine
import OpenWebSDK

protocol ConversationSettingsViewModelingInputs {
    var styleModeSelectedIndex: CurrentValueSubject<Int, Never> { get }
    var communityGuidelinesStyleSelectedIndex: CurrentValueSubject<Int, Never> { get }
    var communityQuestionsStyleModeSelectedIndex: CurrentValueSubject<Int, Never> { get }
    var conversationSpacingSelectedIndex: CurrentValueSubject<Int, Never> { get }
    var betweenCommentsSpacingSelected: CurrentValueSubject<String, Never> { get }
    var communityGuidelinesSpacingSelected: CurrentValueSubject<String, Never> { get }
    var communityQuestionsGuidelinesSpacingSelected: CurrentValueSubject<String, Never> { get }
    var allowPullToRefreshSelected: CurrentValueSubject<Bool, Never> { get }
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
    var allowPullToRefreshTitle: String { get }
    var styleModeIndex: AnyPublisher<Int, Never> { get }
    var communityGuidelinesStyleModeIndex: AnyPublisher<Int, Never> { get }
    var communityQuestionsStyleModeIndex: AnyPublisher<Int, Never> { get }
    var conversationSpacingModeIndex: AnyPublisher<Int, Never> { get }
    var betweenCommentsSpacing: AnyPublisher<String, Never> { get }
    var communityGuidelinesSpacing: AnyPublisher<String, Never> { get }
    var communityQuestionsGuidelinesSpacing: AnyPublisher<String, Never> { get }
    var allowPullToRefresh: AnyPublisher<Bool, Never> { get }
    var styleModeSettings: [String] { get }
    var communityGuidelinesModeSettings: [String] { get }
    var communityQuestionsStyleModeSettings: [String] { get }
    var conversationSpacingSettings: [String] { get }
    var showCustomStyleOptions: AnyPublisher<Bool, Never> { get }
    var showSpacingOptions: AnyPublisher<Bool, Never> { get }
}

protocol ConversationSettingsViewModeling {
    var inputs: ConversationSettingsViewModelingInputs { get }
    var outputs: ConversationSettingsViewModelingOutputs { get }
}

// swiftlint:disable identifier_name
class ConversationSettingsVM: ConversationSettingsViewModeling,
                              ConversationSettingsViewModelingInputs,
                              ConversationSettingsViewModelingOutputs {

    var inputs: ConversationSettingsViewModelingInputs { return self }
    var outputs: ConversationSettingsViewModelingOutputs { return self }

    lazy var styleModeSelectedIndex = CurrentValueSubject<Int, Never>({
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

    lazy var communityGuidelinesStyleSelectedIndex = CurrentValueSubject<Int, Never>({
        let cs = userDefaultsProvider.get(key: .conversationStyle, defaultValue: OWConversationStyle.default)
        if case .custom(let communityGuidelinesStyle, _, _) = cs {
            return communityGuidelinesStyle.index
        }
        return OWCommunityGuidelinesStyle.default.index
    }())

    lazy var communityQuestionsStyleModeSelectedIndex = CurrentValueSubject<Int, Never>({
        let cs = userDefaultsProvider.get(key: .conversationStyle, defaultValue: OWConversationStyle.default)
        if case .custom(_, let communityQuestionsStyle, _) = cs {
            return communityQuestionsStyle.index
        }
        return OWCommunityQuestionStyle.default.index
    }())

    lazy var conversationSpacingSelectedIndex = CurrentValueSubject<Int, Never>({
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

    lazy var betweenCommentsSpacingSelected = CurrentValueSubject<String, Never>({
        let cs = userDefaultsProvider.get(key: .conversationStyle, defaultValue: OWConversationStyle.default)
        if case .custom(_, _, let spacing) = cs {
            if case .custom(let betweenComments, _, _) = spacing {
                return "\(betweenComments)"
            }
        }
        return "\(OWConversationSpacing.Metrics.defaultSpaceBetweenComments)"
    }())

    lazy var communityGuidelinesSpacingSelected = CurrentValueSubject<String, Never>({
        let cs = userDefaultsProvider.get(key: .conversationStyle, defaultValue: OWConversationStyle.default)
        if case .custom(_, _, let spacing) = cs {
            if case .custom(_, let communityGuidelinesSpacing, _) = spacing {
                return "\(communityGuidelinesSpacing)"
            }
        }
        return "\(OWConversationSpacing.Metrics.defaultSpaceCommunityGuidelines)"
    }())

    lazy var communityQuestionsGuidelinesSpacingSelected = CurrentValueSubject<String, Never>({
        let cs = userDefaultsProvider.get(key: .conversationStyle, defaultValue: OWConversationStyle.default)
        if case .custom(_, _, let spacing) = cs {
            if case .custom(_, _, let communityQuestionsSpacing) = spacing {
                return "\(communityQuestionsSpacing)"
            }
        }
        return "\(OWConversationSpacing.Metrics.defaultSpaceCommunityQuestions)"
    }())

    lazy var allowPullToRefreshSelected = CurrentValueSubject<Bool, Never>({
        return userDefaultsProvider.get(key: .allowPullToRefresh, defaultValue: true)
    }())

    private var userDefaultsProvider: UserDefaultsProviderProtocol

    var styleModeIndex: AnyPublisher<Int, Never> {
        return styleModeSelectedIndex.eraseToAnyPublisher()
    }

    var communityGuidelinesStyleModeIndex: AnyPublisher<Int, Never> {
        return communityGuidelinesStyleSelectedIndex.eraseToAnyPublisher()
    }

    var communityQuestionsStyleModeIndex: AnyPublisher<Int, Never> {
        return communityQuestionsStyleModeSelectedIndex.eraseToAnyPublisher()
    }

    var conversationSpacingModeIndex: AnyPublisher<Int, Never> {
        return conversationSpacingSelectedIndex.eraseToAnyPublisher()
    }

    var betweenCommentsSpacing: AnyPublisher<String, Never> {
        return betweenCommentsSpacingSelected.eraseToAnyPublisher()
    }

    var communityGuidelinesSpacing: AnyPublisher<String, Never> {
        return communityGuidelinesSpacingSelected.eraseToAnyPublisher()
    }

    var communityQuestionsGuidelinesSpacing: AnyPublisher<String, Never> {
        return communityQuestionsGuidelinesSpacingSelected.eraseToAnyPublisher()
    }

    var allowPullToRefresh: AnyPublisher<Bool, Never> {
        return allowPullToRefreshSelected.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()

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

    lazy var allowPullToRefreshTitle: String = {
        return NSLocalizedString("AllowPullToRefresh", comment: "")
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

    var showCustomStyleOptions: AnyPublisher<Bool, Never> {
        return styleModeIndex
            .map { $0 == OWConversationStyleIndexer.custom.index } // Custom Style
            .eraseToAnyPublisher()
    }

    var showSpacingOptions: AnyPublisher<Bool, Never> {
        return conversationSpacingSelectedIndex
            .map { $0 == OWConversationStyleIndexer.custom.index } // Custom Spacing
            .eraseToAnyPublisher()
    }

    private lazy var styleModeObservable =
        Publishers.CombineLatest(
            Publishers.CombineLatest4(
                styleModeSelectedIndex,
                communityGuidelinesStyleSelectedIndex,
                communityQuestionsStyleModeSelectedIndex,
                conversationSpacingSelectedIndex
            ),
            Publishers.CombineLatest3(
                betweenCommentsSpacingSelected,
                communityGuidelinesSpacingSelected,
                communityQuestionsGuidelinesSpacingSelected
            )
        )
        .map { indices, spacings in
            let (styleIndex, communityGuidelinesStyleIndex, questionsStyleIndex, conversationSpacingIndex) = indices
            let (betweenCommentsSpace, communityGuidelinesSpace, communityQuestionsGuidelinesSpace) = spacings

            return OWConversationStyle.conversationStyle(fromIndex: styleIndex,
                                                         communityGuidelinesStyleIndex: communityGuidelinesStyleIndex,
                                                         communityQuestionsStyleIndex: questionsStyleIndex,
                                                         spacingIndex: conversationSpacingIndex,
                                                         betweenComments: OWConversationSpacing.validateSpacing(betweenCommentsSpace),
                                                         belowCommunityGuidelines: OWConversationSpacing.validateSpacing(communityGuidelinesSpace),
                                                         belowCommunityQuestions: OWConversationSpacing.validateSpacing(communityQuestionsGuidelinesSpace))
        }
        .eraseToAnyPublisher()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}
// swiftlint:enable identifier_name

private extension ConversationSettingsVM {
    func setupObservers() {
        styleModeObservable
            .dropFirst()
            .bind(to: self.userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<OWConversationStyle>.conversationStyle))
            .store(in: &cancellables)

        allowPullToRefreshSelected
            .dropFirst()
            .bind(to: self.userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<Bool>.allowPullToRefresh))
            .store(in: &cancellables)
    }
}

extension ConversationSettingsVM: SettingsGroupVMProtocol {
    func resetToDefault() {
        styleModeSelectedIndex.send(OWConversationStyle.defaultIndex)
        communityGuidelinesStyleSelectedIndex.send(OWCommunityGuidelinesStyle.default.index)
        communityQuestionsStyleModeSelectedIndex.send(OWCommunityQuestionStyle.default.index)
        conversationSpacingSelectedIndex.send(OWConversationSpacing.defaultIndex)
        betweenCommentsSpacingSelected.send("\(OWConversationSpacing.Metrics.defaultSpaceBetweenComments)")
        communityGuidelinesSpacingSelected.send("\(OWConversationSpacing.Metrics.defaultSpaceCommunityGuidelines)")
        communityQuestionsGuidelinesSpacingSelected.send("\(OWConversationSpacing.Metrics.defaultSpaceCommunityQuestions)")
        allowPullToRefreshSelected.send(true)
    }
}
