//
//  GeneralSettingsView.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 26/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

#if NEW_API

class GeneralSettingsView: UIView {

    fileprivate struct Metrics {
        static let identifier = "general_settings_view_id"
        static let switchHideArticleHeaderIdentifier = "hide_article_header"
        static let switchCommentCreationNewDesignIdentifier = "comment_creation_new_design"
        static let segmentedReadOnlyModeIdentifier = "read_only_mode"
        static let segmentedThemeModeIdentifier = "theme_mode"
        static let segmentedModalStyleIdentifier = "modal_style"
        static let segmentedInitialSortIdentifier = "initial_sort"
        static let segmentedFontGroupTypeIdentifier = "font_group_type"
        static let textFieldCustomFontNameIdentifier = "custom_font_name"
        static let textFieldArticleURLIdentifier = "article_url"
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

    fileprivate lazy var switchHideArticleHeader: SwitchSetting = {
        return SwitchSetting(title: viewModel.outputs.hideArticleHeaderTitle,
                             accessibilityPrefixId: Metrics.switchHideArticleHeaderIdentifier)
    }()

    fileprivate lazy var switchCommentCreationNewDesign: SwitchSetting = {
        return SwitchSetting(title: viewModel.outputs.commentCreationNewDesignTitle,
                             accessibilityPrefixId: Metrics.switchCommentCreationNewDesignIdentifier)
    }()

    fileprivate lazy var segmentedReadOnlyMode: SegmentedControlSetting = {
        let title = viewModel.outputs.readOnlyTitle
        let items = viewModel.outputs.readOnlySettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedReadOnlyModeIdentifier,
                                       items: items)
    }()

    fileprivate lazy var segmentedThemeMode: SegmentedControlSetting = {
        let title = viewModel.outputs.themeModeTitle
        let items = viewModel.outputs.themeModeSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedThemeModeIdentifier,
                                       items: items)
    }()

    fileprivate lazy var segmentedModalStyle: SegmentedControlSetting = {
        let title = viewModel.outputs.modalStyleTitle
        let items = viewModel.outputs.modalStyleSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedModalStyleIdentifier,
                                       items: items)
    }()

    fileprivate lazy var segmentedInitialSort: SegmentedControlSetting = {
        let title = viewModel.outputs.initialSortTitle
        let items = viewModel.outputs.initialSortSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedInitialSortIdentifier,
                                       items: items)
    }()

    fileprivate lazy var segmentedFontGroupType: SegmentedControlSetting = {
        let title = viewModel.outputs.fontGroupTypeTitle
        let items = viewModel.outputs.fontGroupTypeSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedFontGroupTypeIdentifier,
                                       items: items)
    }()

    fileprivate lazy var textFieldCustomFontName: TextFieldSetting = {
        let txtField = TextFieldSetting(title: viewModel.outputs.customFontGroupTypeNameTitle,
                                        accessibilityPrefixId: Metrics.textFieldCustomFontNameIdentifier,
                                        font: FontBook.paragraph)
        return txtField
    }()

    fileprivate lazy var textFieldArticleURL: TextFieldSetting = {
        let txtField = TextFieldSetting(title: viewModel.outputs.articleURLTitle,
                                        accessibilityPrefixId: Metrics.textFieldArticleURLIdentifier,
                                        font: FontBook.paragraph)
        return txtField
    }()

    fileprivate let viewModel: GeneralSettingsViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: GeneralSettingsViewModeling) {
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

fileprivate extension GeneralSettingsView {
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
        stackView.addArrangedSubview(switchHideArticleHeader)
        stackView.addArrangedSubview(switchCommentCreationNewDesign)
        stackView.addArrangedSubview(segmentedReadOnlyMode)
        stackView.addArrangedSubview(segmentedThemeMode)
        stackView.addArrangedSubview(segmentedModalStyle)
        stackView.addArrangedSubview(segmentedInitialSort)
        stackView.addArrangedSubview(segmentedFontGroupType)
        stackView.addArrangedSubview(textFieldCustomFontName)
        stackView.addArrangedSubview(textFieldArticleURL)
    }

    func setupObservers() {

        viewModel.outputs.shouldHideArticleHeader
            .bind(to: switchHideArticleHeader.rx.isOn)
            .disposed(by: disposeBag)

        viewModel.outputs.shouldCommentCreationNewDesign
            .bind(to: switchCommentCreationNewDesign.rx.isOn)
            .disposed(by: disposeBag)

        viewModel.outputs.readOnlyModeIndex
            .bind(to: segmentedReadOnlyMode.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        viewModel.outputs.themeModeIndex
            .bind(to: segmentedThemeMode.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        viewModel.outputs.modalStyleIndex
            .bind(to: segmentedModalStyle.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        viewModel.outputs.initialSortIndex
            .bind(to: segmentedInitialSort.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        viewModel.outputs.fontGroupTypeIndex
            .bind(to: segmentedFontGroupType.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        viewModel.outputs.customFontGroupTypeName
            .bind(to: textFieldCustomFontName.rx.textFieldText)
            .disposed(by: disposeBag)

        viewModel.outputs.articleAssociatedURL
            .bind(to: textFieldArticleURL.rx.textFieldText)
            .disposed(by: disposeBag)

        switchHideArticleHeader.rx.isOn
            .bind(to: viewModel.inputs.hideArticleHeaderToggled)
            .disposed(by: disposeBag)

        switchCommentCreationNewDesign.rx.isOn
            .bind(to: viewModel.inputs.commentCreationNewDesignToggled)
            .disposed(by: disposeBag)

        segmentedReadOnlyMode.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.readOnlyModeSelectedIndex)
            .disposed(by: disposeBag)

        segmentedThemeMode.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.themeModeSelectedIndex)
            .disposed(by: disposeBag)

        segmentedModalStyle.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.modalStyleSelectedIndex)
            .disposed(by: disposeBag)

        segmentedInitialSort.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.initialSortSelectedIndex)
            .disposed(by: disposeBag)

        segmentedFontGroupType.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.fontGroupTypeSelectedIndex)
            .disposed(by: disposeBag)

        textFieldCustomFontName.rx.textFieldText
            .unwrap()
            .bind(to: viewModel.inputs.customFontGroupSelectedName)
            .disposed(by: disposeBag)

        viewModel.outputs.showCustomFontName
            .map { !$0 }
            .bind(to: textFieldCustomFontName.rx.isHidden)
            .disposed(by: disposeBag)

        textFieldArticleURL.rx.textFieldText
            .unwrap()
            .bind(to: viewModel.inputs.articleAssociatedSelectedURL)
            .disposed(by: disposeBag)
    }
}

#endif
