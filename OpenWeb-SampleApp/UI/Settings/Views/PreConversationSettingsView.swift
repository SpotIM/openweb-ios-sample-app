//
//  PreConversationSettingsView.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 27/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa

class PreConversationSettingsView: UIView {

    private struct Metrics {
        static let identifier = "pre_conversation_settings_view_id"
        static let segmentedStyleModeIdentifier = "custom_style_mode"
        static let pickerCustomStyleNumberOfCommentsIdentifier = "custom_style_number_of_comments"
        static let segmentedCommunityGuidelinesStyleModeIdentifier = "community_guidelines_style_mode"
        static let segmentedCommunityQuestionsStyleModeIdentifier = "community_questions_style_mode"
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

    private lazy var pickerCustomStyleNumberOfComments: PickerSetting = {
        let title = viewModel.outputs.customStyleNumberOfCommentsTitle
        let picker = PickerSetting(title: title,
                                   accessibilityPrefixId: Metrics.pickerCustomStyleNumberOfCommentsIdentifier,
                                   items: viewModel.outputs.customStyleNumberOfCommentsSettings)
        return picker
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

    private let viewModel: PreConversationSettingsViewModeling
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: PreConversationSettingsViewModeling) {
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

private extension PreConversationSettingsView {
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
        stackView.addArrangedSubview(pickerCustomStyleNumberOfComments)
        stackView.addArrangedSubview(segmentedCommunityGuidelinesStyleMode)
        stackView.addArrangedSubview(segmentedCommunityQuestionsStyleMode)
    }

    func setupObservers() {
        viewModel.outputs.styleModeIndex
            .assign(to: \.selectedSegmentIndex, on: segmentedStyleMode.segmentedControl)
            .store(in: &cancellables)

        segmentedStyleMode.segmentedControl.selectedSegmentIndexPublisher
            .bind(to: viewModel.inputs.customStyleModeSelectedIndex)
            .store(in: &cancellables)

        viewModel.outputs.customStyleNumberOfComments
            .map { [weak self] in
                guard let self, let index = self.viewModel.outputs.customStyleNumberOfCommentsSettings.firstIndex(of: String($0))
                else { return nil }
                return (index, 0)
            }
            .unwrap()
            .assign(to: \.selectedIndexPath, on: pickerCustomStyleNumberOfComments.pickerControl.publisher)
            .store(in: &cancellables)

        pickerCustomStyleNumberOfComments.pickerControl.publisher.$selectedIndexPath
            .map { [weak self] in
                guard let self else { return nil }
                return Int(self.viewModel.outputs.customStyleNumberOfCommentsSettings[$0.row])
            }
            .unwrap()
            .removeDuplicates()
            .bind(to: viewModel.inputs.customStyleModeSelectedNumberOfComments)
            .store(in: &cancellables)

        viewModel.outputs.showCustomStyleOptions
            .map { !$0 }
            .sink { [weak self] isHidden in
                self?.pickerCustomStyleNumberOfComments.isHidden = isHidden
                self?.segmentedCommunityGuidelinesStyleMode.isHidden = isHidden
                self?.segmentedCommunityQuestionsStyleMode.isHidden = isHidden
            }
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
    }
}
