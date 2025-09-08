//
//  ConversationSettingsView.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 27/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa

class ConversationSettingsView: UIView {

    private struct Metrics {
        static let identifier = "conversation_settings_view_id"
        static let segmentedStyleModeIdentifier = "style_mode"
        static let segmentedCommunityGuidelinesStyleModeIdentifier = "community_guidelines_style_mode"
        static let segmentedCommunityQuestionsStyleModeIdentifier = "community_questions_style_mode"
        static let segmentedConversationSpacingModeIdentifier = "conversation_spacing_style_mode"
        static let textFieldBetweenCommentsSpacingIdentifier = "between_comments_spacing"
        static let textFieldBelowCommunityGuidelinesSpacingIdentifier = "below_community_guidelines_spacing"
        static let textFieldBelowCommunityQuestionsSpacingIdentifier = "below_community_questions_spacing"
        static let switchAllowSwipeToRefreshIdentifier = "allow_swipe_to_refresh"
        static let verticalOffset: CGFloat = 40
        static let horizontalOffset: CGFloat = 10
    }

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Metrics.verticalOffset
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.text = viewModel.outputs.title
        titleLabel.font = FontBook.secondaryHeadingBold
        return titleLabel
    }()

    private lazy var segmentedStyleMode: SegmentedControlSetting = {
        let title = viewModel.outputs.styleModeTitle
        let items = viewModel.outputs.styleModeSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedStyleModeIdentifier,
                                       items: items)
    }()

    private lazy var segmentedCommunityGuidelinesStyleMode: SegmentedControlSetting = {
        let title = viewModel.outputs.communityGuidelinesStyleModeTitle
        let items = viewModel.outputs.communityGuidelinesModeSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedCommunityGuidelinesStyleModeIdentifier,
                                       items: items)
    }()

    private lazy var segmentedCommunityQuestionsStyleMode: SegmentedControlSetting = {
        let title = viewModel.outputs.communityQuestionsStyleModeTitle
        let items = viewModel.outputs.communityQuestionsStyleModeSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedCommunityQuestionsStyleModeIdentifier,
                                       items: items)
    }()

    private lazy var segmentedConversationSpacingMode: SegmentedControlSetting = {
        let title = viewModel.outputs.conversationSpacingModeTitle
        let items = viewModel.outputs.conversationSpacingSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedConversationSpacingModeIdentifier,
                                       items: items)
    }()

    private lazy var textFieldBetweenCommentsSpacing: TextFieldSetting = {
        return TextFieldSetting(title: viewModel.outputs.betweenCommentsSpacingTitle,
                                accessibilityPrefixId: Metrics.textFieldBetweenCommentsSpacingIdentifier,
                                font: FontBook.paragraph)
    }()

    private lazy var textFieldCommunityGuidelinesSpacing: TextFieldSetting = {
        return TextFieldSetting(title: viewModel.outputs.communityGuidelinesSpacingTitle,
                                accessibilityPrefixId: Metrics.textFieldBelowCommunityGuidelinesSpacingIdentifier,
                                font: FontBook.paragraph)
    }()

    private lazy var textFieldCommunityQuestionsSpacing: TextFieldSetting = {
        return TextFieldSetting(title: viewModel.outputs.communityQuestionsGuidelinesSpacingTitle,
                                accessibilityPrefixId: Metrics.textFieldBelowCommunityQuestionsSpacingIdentifier,
                                font: FontBook.paragraph)
    }()

    private lazy var switchAllowSwipeToRefresh: SwitchSetting = {
        return SwitchSetting(title: viewModel.outputs.allowSwipeToRefreshTitle, accessibilityPrefixId: Metrics.switchAllowSwipeToRefreshIdentifier)
    }()

    private let viewModel: ConversationSettingsViewModeling
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: ConversationSettingsViewModeling) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        setupViews()
        applyAccessibility()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ConversationSettingsView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }

    @objc func setupViews() {
        self.backgroundColor = ColorPalette.shared.color(type: .background)

        // Add a StackView so that hidden controlls constraints will be removed
        self.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Metrics.horizontalOffset)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(segmentedStyleMode)
        stackView.addArrangedSubview(segmentedCommunityGuidelinesStyleMode)
        stackView.addArrangedSubview(segmentedCommunityQuestionsStyleMode)
        stackView.addArrangedSubview(segmentedConversationSpacingMode)
        stackView.addArrangedSubview(textFieldBetweenCommentsSpacing)
        stackView.addArrangedSubview(textFieldCommunityGuidelinesSpacing)
        stackView.addArrangedSubview(textFieldCommunityQuestionsSpacing)
        stackView.addArrangedSubview(switchAllowSwipeToRefresh)
    }

    func setupObservers() {
        viewModel.outputs.styleModeIndex
            .assign(to: \.selectedSegmentIndex, on: segmentedStyleMode.segmentedControl)
            .store(in: &cancellables)

        segmentedStyleMode.segmentedControl.selectedSegmentIndexPublisher
            .bind(to: viewModel.inputs.styleModeSelectedIndex)
            .store(in: &cancellables)

        viewModel.outputs.communityGuidelinesStyleModeIndex
            .assign(to: \.selectedSegmentIndex, on: segmentedCommunityGuidelinesStyleMode.segmentedControl)
            .store(in: &cancellables)

        segmentedCommunityGuidelinesStyleMode.segmentedControl.selectedSegmentIndexPublisher
            .bind(to: viewModel.inputs.communityGuidelinesStyleSelectedIndex)
            .store(in: &cancellables)

        viewModel.outputs.communityQuestionsStyleModeIndex
            .assign(to: \.selectedSegmentIndex, on: segmentedCommunityQuestionsStyleMode.segmentedControl)
            .store(in: &cancellables)

        segmentedCommunityQuestionsStyleMode.segmentedControl.selectedSegmentIndexPublisher
            .bind(to: viewModel.inputs.communityQuestionsStyleModeSelectedIndex)
            .store(in: &cancellables)

        viewModel.outputs.conversationSpacingModeIndex
            .assign(to: \.selectedSegmentIndex, on: segmentedConversationSpacingMode.segmentedControl)
            .store(in: &cancellables)

        segmentedConversationSpacingMode.segmentedControl.selectedSegmentIndexPublisher
            .bind(to: viewModel.inputs.conversationSpacingSelectedIndex)
            .store(in: &cancellables)

        viewModel.outputs.betweenCommentsSpacing
            .map { $0 as String? }
            .assign(to: \.text, on: textFieldBetweenCommentsSpacing.textFieldControl)
            .store(in: &cancellables)

        textFieldBetweenCommentsSpacing.textFieldControl.textPublisher
            .unwrap()
            .bind(to: viewModel.inputs.betweenCommentsSpacingSelected)
            .store(in: &cancellables)

        viewModel.outputs.communityGuidelinesSpacing
            .map { $0 as String? }
            .assign(to: \.text, on: textFieldCommunityGuidelinesSpacing.textFieldControl)
            .store(in: &cancellables)

        textFieldCommunityGuidelinesSpacing.textFieldControl.textPublisher
            .unwrap()
            .bind(to: viewModel.inputs.communityGuidelinesSpacingSelected)
            .store(in: &cancellables)

        viewModel.outputs.communityQuestionsGuidelinesSpacing
            .map { $0 as String? }
            .assign(to: \.text, on: textFieldCommunityQuestionsSpacing.textFieldControl)
            .store(in: &cancellables)

        textFieldCommunityQuestionsSpacing.textFieldControl.textPublisher
            .unwrap()
            .bind(to: viewModel.inputs.communityQuestionsGuidelinesSpacingSelected)
            .store(in: &cancellables)

        viewModel.outputs.allowSwipeToRefresh
            .assign(to: \.isOn, on: switchAllowSwipeToRefresh.switchControl)
            .store(in: &cancellables)

        switchAllowSwipeToRefresh.switchControl.isOnPublisher
            .bind(to: viewModel.inputs.allowSwipeToRefreshSelected)
            .store(in: &cancellables)

        viewModel.outputs.showCustomStyleOptions
            .map { !$0 } // Not hide custom segmented style
            .sink { [weak self] isHidden in
                self?.segmentedCommunityGuidelinesStyleMode.isHidden = isHidden
                self?.segmentedCommunityQuestionsStyleMode.isHidden = isHidden
                self?.segmentedConversationSpacingMode.isHidden = isHidden
            }
            .store(in: &cancellables)

        // Observe conversation style mode and conversation spacing mode, If both are custom then we show spacing text fields
        Publishers.CombineLatest(viewModel.outputs.showSpacingOptions, viewModel.outputs.showCustomStyleOptions)
            .map { showSpacingOptions, showCustomStyleOptions in
                return !(showCustomStyleOptions && showSpacingOptions) // Not hide text fields
            }
            .sink { [weak self] isHidden in
                self?.textFieldBetweenCommentsSpacing.isHidden = isHidden
                self?.textFieldCommunityGuidelinesSpacing.isHidden = isHidden
                self?.textFieldCommunityQuestionsSpacing.isHidden = isHidden
            }
            .store(in: &cancellables)
    }
}
