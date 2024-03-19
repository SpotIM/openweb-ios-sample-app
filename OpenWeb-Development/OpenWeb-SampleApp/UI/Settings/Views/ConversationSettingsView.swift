//
//  ConversationSettingsView.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 27/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift

class ConversationSettingsView: UIView {

    fileprivate struct Metrics {
        static let identifier = "conversation_settings_view_id"
        static let segmentedStyleModeIdentifier = "style_mode"
        static let segmentedCommunityGuidelinesStyleModeIdentifier = "community_guidelines_style_mode"
        static let segmentedCommunityQuestionsStyleModeIdentifier = "community_questions_style_mode"
        static let segmentedConversationSpacingModeIdentifier = "conversation_spacing_style_mode"
        static let textFieldBetweenCommentsSpacingIdentifier = "between_comments_spacing"
        static let textFieldBelowHeaderSpacingIdentifier = "below_header_spacing"
        static let textFieldBelowCommunityGuidelinesSpacingIdentifier = "below_community_guidelines_spacing"
        static let textFieldBelowCommunityQuestionsSpacingIdentifier = "below_community_questions_spacing"
        static let verticalOffset: CGFloat = 40
        static let horizontalOffset: CGFloat = 10
    }

    fileprivate lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Metrics.verticalOffset
        return stackView
    }()

    fileprivate lazy var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.text = viewModel.outputs.title
        titleLabel.font = FontBook.secondaryHeadingBold
        return titleLabel
    }()

    fileprivate lazy var segmentedStyleMode: SegmentedControlSetting = {
        let title = viewModel.outputs.styleModeTitle
        let items = viewModel.outputs.styleModeSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedStyleModeIdentifier,
                                       items: items)
    }()

    fileprivate lazy var segmentedCommunityGuidelinesStyleMode: SegmentedControlSetting = {
        let title = viewModel.outputs.communityGuidelinesStyleModeTitle
        let items = viewModel.outputs.communityGuidelinesModeSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedCommunityGuidelinesStyleModeIdentifier,
                                       items: items)
    }()

    fileprivate lazy var segmentedCommunityQuestionsStyleMode: SegmentedControlSetting = {
        let title = viewModel.outputs.communityQuestionsStyleModeTitle
        let items = viewModel.outputs.communityQuestionsStyleModeSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedCommunityQuestionsStyleModeIdentifier,
                                       items: items)
    }()

    fileprivate lazy var segmentedConversationSpacingMode: SegmentedControlSetting = {
        let title = viewModel.outputs.conversationSpacingModeTitle
        let items = viewModel.outputs.conversationSpacingSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedConversationSpacingModeIdentifier,
                                       items: items)
    }()

    fileprivate lazy var textFieldBetweenCommentsSpacing: TextFieldSetting = {
        return TextFieldSetting(title: viewModel.outputs.betweenCommentsSpacingTitle,
                                accessibilityPrefixId: Metrics.textFieldBetweenCommentsSpacingIdentifier,
                                font: FontBook.paragraph)
    }()

    fileprivate lazy var textFieldCommunityGuidelinesSpacing: TextFieldSetting = {
        return TextFieldSetting(title: viewModel.outputs.communityGuidelinesSpacingTitle,
                                accessibilityPrefixId: Metrics.textFieldBelowCommunityGuidelinesSpacingIdentifier,
                                font: FontBook.paragraph)
    }()

    fileprivate lazy var textFieldCommunityQuestionsSpacing: TextFieldSetting = {
        return TextFieldSetting(title: viewModel.outputs.communityQuestionsGuidelinesSpacingTitle,
                                accessibilityPrefixId: Metrics.textFieldBelowCommunityQuestionsSpacingIdentifier,
                                font: FontBook.paragraph)
    }()

    fileprivate let viewModel: ConversationSettingsViewModeling
    fileprivate let disposeBag = DisposeBag()

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

fileprivate extension ConversationSettingsView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
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
    }

    func setupObservers() {
        viewModel.outputs.styleModeIndex
            .bind(to: segmentedStyleMode.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        segmentedStyleMode.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.styleModeSelectedIndex)
            .disposed(by: disposeBag)

        viewModel.outputs.communityGuidelinesStyleModeIndex
            .bind(to: segmentedCommunityGuidelinesStyleMode.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        segmentedCommunityGuidelinesStyleMode.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.communityGuidelinesStyleSelectedIndex)
            .disposed(by: disposeBag)

        viewModel.outputs.communityQuestionsStyleModeIndex
            .bind(to: segmentedCommunityQuestionsStyleMode.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        segmentedCommunityQuestionsStyleMode.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.communityQuestionsStyleModeSelectedIndex)
            .disposed(by: disposeBag)

        viewModel.outputs.conversationSpacingModeIndex
            .bind(to: segmentedConversationSpacingMode.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        segmentedConversationSpacingMode.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.conversationSpacingSelectedIndex)
            .disposed(by: disposeBag)

        viewModel.outputs.betweenCommentsSpacing
            .bind(to: textFieldBetweenCommentsSpacing.rx.textFieldTextAfterEnded)
            .disposed(by: disposeBag)

        textFieldBetweenCommentsSpacing.rx.textFieldTextAfterEnded
            .unwrap()
            .bind(to: viewModel.inputs.betweenCommentsSpacingSelected)
            .disposed(by: disposeBag)

        viewModel.outputs.communityGuidelinesSpacing
            .bind(to: textFieldCommunityGuidelinesSpacing.rx.textFieldTextAfterEnded)
            .disposed(by: disposeBag)

        textFieldCommunityGuidelinesSpacing.rx.textFieldTextAfterEnded
            .unwrap()
            .bind(to: viewModel.inputs.communityGuidelinesSpacingSelected)
            .disposed(by: disposeBag)

        viewModel.outputs.communityQuestionsGuidelinesSpacing
            .bind(to: textFieldCommunityQuestionsSpacing.rx.textFieldTextAfterEnded)
            .disposed(by: disposeBag)

        textFieldCommunityQuestionsSpacing.rx.textFieldTextAfterEnded
            .unwrap()
            .bind(to: viewModel.inputs.communityQuestionsGuidelinesSpacingSelected)
            .disposed(by: disposeBag)

        viewModel.outputs.showCustomStyleOptions
            .map { !$0 } // Not hide custom segmented style
            .bind(to: segmentedCommunityGuidelinesStyleMode.rx.isHidden, segmentedCommunityQuestionsStyleMode.rx.isHidden, segmentedConversationSpacingMode.rx.isHidden)
            .disposed(by: disposeBag)

        // Observe conversation style mode and conversation spacing mode, If both are custom then we show spacing text fields
        Observable.combineLatest(viewModel.outputs.showCustomStyleOptions, viewModel.outputs.showSpacingOptions) { showCustomStyleOptions, showSpacingOptions in
            return !(showCustomStyleOptions && showSpacingOptions) // Not hide text fields
        }
        .bind(to: textFieldBetweenCommentsSpacing.rx.isHidden,
              textFieldCommunityGuidelinesSpacing.rx.isHidden,
              textFieldCommunityQuestionsSpacing.rx.isHidden)
        .disposed(by: disposeBag)
    }
}
