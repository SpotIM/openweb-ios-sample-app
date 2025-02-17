//
//  PreConversationSettingsVM.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 27/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import Combine
import OpenWebSDK

protocol PreConversationSettingsViewModelingInputs {
    var customStyleModeSelectedIndex: CurrentValueSubject<Int, Never> { get }
    var customStyleModeSelectedNumberOfComments: CurrentValueSubject<Int, Never> { get }
    var communityGuidelinesStyleSelectedIndex: CurrentValueSubject<Int, Never> { get }
    var communityQuestionsStyleModeSelectedIndex: CurrentValueSubject<Int, Never> { get }
}

protocol PreConversationSettingsViewModelingOutputs {
    var title: String { get }
    var styleModeTitle: String { get }
    var styleModeIndex: AnyPublisher<Int, Never> { get }
    var styleModeSettings: [String] { get }
    var customStyleNumberOfCommentsTitle: String { get }
    var customStyleNumberOfComments: AnyPublisher<Int, Never> { get }
    var showCustomStyleOptions: AnyPublisher<Bool, Never> { get }
    var customStyleNumberOfCommentsSettings: [String] { get }
    var communityGuidelinesStyleModeTitle: String { get }
    var communityQuestionsStyleModeTitle: String { get }
    var communityGuidelinesStyleModeIndex: AnyPublisher<Int, Never> { get }
    var communityQuestionsStyleModeIndex: AnyPublisher<Int, Never> { get }
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
    var inputs: PreConversationSettingsViewModelingInputs { return self }
    var outputs: PreConversationSettingsViewModelingOutputs { return self }

    private lazy var initialStyle: OWPreConversationStyle = userDefaultsProvider.get(
        key: UserDefaultsProvider.UDKey<OWPreConversationStyle>.preConversationStyle,
        defaultValue: OWPreConversationStyle.default
    )

    lazy var customStyleModeSelectedIndex = CurrentValueSubject<Int, Never>(initialStyle.index)
    lazy var customStyleModeSelectedNumberOfComments = CurrentValueSubject<Int, Never>(initialStyle.numberOfComments)
    lazy var communityGuidelinesStyleSelectedIndex = CurrentValueSubject<Int, Never>(initialStyle.communityGuidelinesStyleModeIndex)
    lazy var communityQuestionsStyleModeSelectedIndex = CurrentValueSubject<Int, Never>(initialStyle.communityQuestionsStyleModeIndex)

    private var userDefaultsProvider: UserDefaultsProviderProtocol

    var showCustomStyleOptions: AnyPublisher<Bool, Never> {
        return styleModeIndex
            .map { $0 == OWPreConversationStyleIndexer.custom.index } // Custom Style
            .eraseToAnyPublisher()
    }

    var styleModeIndex: AnyPublisher<Int, Never> {
        return customStyleModeSelectedIndex
            .eraseToAnyPublisher()
    }

    var customStyleNumberOfComments: AnyPublisher<Int, Never> {
        return customStyleModeSelectedNumberOfComments
            .eraseToAnyPublisher()
    }

    var communityGuidelinesStyleModeIndex: AnyPublisher<Int, Never> {
        return communityGuidelinesStyleSelectedIndex
            .eraseToAnyPublisher()
    }

    var communityQuestionsStyleModeIndex: AnyPublisher<Int, Never> {
        return communityQuestionsStyleModeSelectedIndex
            .eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()

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

    private lazy var customStyleModeObservable: AnyPublisher<OWPreConversationStyle, Never> = {
        return Publishers.CombineLatest4(
            customStyleModeSelectedIndex,
            customStyleModeSelectedNumberOfComments,
            communityGuidelinesStyleSelectedIndex,
            communityQuestionsStyleModeSelectedIndex
        )
        .map { styleIndex, numberOfComments, communityGuidelinesStyleIndex, questionStyleIndex -> OWPreConversationStyle in
            return OWPreConversationStyle.preConversationStyle(
                fromIndex: styleIndex,
                numberOfComments: numberOfComments,
                communityGuidelinesStyleIndex: communityGuidelinesStyleIndex,
                communityQuestionsStyleIndex: questionStyleIndex
            )
        }
        .eraseToAnyPublisher()
    }()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

private extension PreConversationSettingsVM {
    func setupObservers() {
        customStyleModeObservable
            .dropFirst()
            .bind(to: userDefaultsProvider.setValues(key: UserDefaultsProvider.UDKey<OWPreConversationStyle>.preConversationStyle))
            .store(in: &cancellables)
    }
}

extension PreConversationSettingsVM: SettingsGroupVMProtocol {
    func resetToDefault() {
        customStyleModeSelectedIndex.send(OWPreConversationStyle.defaultIndex)
        customStyleModeSelectedNumberOfComments.send(0)
        communityGuidelinesStyleSelectedIndex.send(OWCommunityGuidelinesStyle.default.index)
        communityQuestionsStyleModeSelectedIndex.send(OWCommunityQuestionStyle.default.index)
    }
}

extension OWPreConversationStyle {
    var index: Int {
        switch self {
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

    var numberOfComments: Int {
        switch self {
        case .custom(let numberOfComments, _, _, _):
            return numberOfComments
        default:
            return OWPreConversationStyle.Metrics.defaultRegularNumberOfComments
        }
    }

    var communityGuidelinesStyleModeIndex: Int {
        switch self {
        case .custom(_, let communityGuidelinesStyle, _, _):
            return communityGuidelinesStyle.index
        default:
            return OWCommunityGuidelinesStyle.default.index
        }
    }

    var communityQuestionsStyleModeIndex: Int {
        switch self {
        case .custom(_, _, let communityQuestionStyle, _):
            return communityQuestionStyle.index
        default:
            return OWCommunityQuestionStyle.default.index
        }
    }
}
