//
//  PreConversationSettingsView.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 27/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift

class PreConversationSettingsView: UIView {

    fileprivate struct Metrics {
        static let identifier = "pre_conversation_settings_view_id"
        static let segmentedStyleModeIdentifier = "custom_style_mode"
        static let pickerCustomStyleNumberOfCommentsIdentifier = "custom_style_number_of_comments"
        static let segmentedCommunityGuidelinesStyleModeIdentifier = "community_guidelines_style_mode"
        static let segmentedCommunityQuestionsStyleModeIdentifier = "community_questions_style_mode"
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

    fileprivate lazy var pickerCustomStyleNumberOfComments: PickerSetting = {
        let title = viewModel.outputs.customStyleNumberOfCommentsTitle
        let picker = PickerSetting(title: title,
                                   accessibilityPrefixId: Metrics.pickerCustomStyleNumberOfCommentsIdentifier,
                                   items: viewModel.outputs.customStyleNumberOfCommentsSettings)
        return picker
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

    fileprivate let viewModel: PreConversationSettingsViewModeling
    fileprivate let disposeBag = DisposeBag()

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

fileprivate extension PreConversationSettingsView {
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
            .bind(to: segmentedStyleMode.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        segmentedStyleMode.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.customStyleModeSelectedIndex)
            .disposed(by: disposeBag)

        viewModel.outputs.customStyleNumberOfComments
            .map { [weak self] in
                guard let self = self, let index = self.viewModel.outputs.customStyleNumberOfCommentsSettings.firstIndex(of: String($0))
                else { return nil }
                return (index, 0)
            }
            .unwrap()
            .bind(to: pickerCustomStyleNumberOfComments.rx.setSelectedPickerIndex)
            .disposed(by: disposeBag)

        pickerCustomStyleNumberOfComments.rx.selectedPickerIndex
            .map { [weak self] in
                guard let self = self else { return nil }
                return Int(self.viewModel.outputs.customStyleNumberOfCommentsSettings[$0.row])
            }
            .unwrap()
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.customStyleModeSelectedNumberOfComments)
            .disposed(by: disposeBag)

        viewModel.outputs.showCustomStyleOptions
            .map { !$0 }
            .bind(to: pickerCustomStyleNumberOfComments.rx.isHidden,
                  segmentedCommunityGuidelinesStyleMode.rx.isHidden,
                  segmentedCommunityQuestionsStyleMode.rx.isHidden)
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
    }
}
