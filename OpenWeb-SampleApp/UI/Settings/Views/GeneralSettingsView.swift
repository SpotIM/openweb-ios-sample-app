//
//  GeneralSettingsView.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 26/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa
import CombineExt
import OpenWebSDK

class GeneralSettingsView: UIView {

    private struct Metrics {
        static let identifier = "general_settings_view_id"
        static let segmentedReadOnlyModeIdentifier = "read_only_mode"
        static let segmentedArticleHeaderStyleIdentifier = "article_header_style"
        static let segmentedArticleInformationStrategiIdentifier = "article_information_strategy"
        static let segmentedElementsCustomizationStyleIdentifier = "elements_customization_style"
        static let segmentedColorsCustomizationStyleIdentifier = "colors_customization_style"
        static let segmentedThemeModeIdentifier = "theme_mode"
        static let segmentedStatusBarStyleIdentifier = "status_bar_style"
        static let segmentedNavigationBarStyleIdentifier = "navigation_bar_style"
        static let segmentedModalStyleIdentifier = "modal_style"
        static let segmentedInitialSortIdentifier = "initial_sort"
        static let textFieldCustomSortTitleIdentifier: [OWSortOption: String] = [
            .best: "sort_title_best",
            .newest: "sort_title_newest",
            .oldest: "sort_title_oldest"
        ]
        static let segmentedFontGroupTypeIdentifier = "font_group_type"
        static let textFieldCustomFontNameIdentifier = "custom_font_name"
        static let textFieldArticleURLIdentifier = "article_url"
        static let textFieldArticleSectionIdentifier = "article_section"
        static let segmentedLanguageStrategyIdentifier = "language_strategy"
        static let segmentedLocaleStrategyIdentifier = "locale_strategy"
        static let segmentedCommentActionsColorIdentifier = "comment_actions_color"
        static let segmentedCommentActionsFontStyleIdentifier = "comment_actions_font_style"
        static let pickerLanguageCodeIdentifier = "language_code"
        static let loginPromptSwitchIdentifier = "login_prompt"
        static let verticalOffset: CGFloat = 40
        static let horizontalOffset: CGFloat = 10
        static let btnPadding: CGFloat = 12
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

    private lazy var segmentedArticleHeaderStyle: SegmentedControlSetting = {
        let title = viewModel.outputs.articleHeaderStyleTitle
        let items = viewModel.outputs.articleHeaderStyleSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedArticleHeaderStyleIdentifier,
                                       items: items)
    }()

    private lazy var segmentedArticleInformationStrategy: SegmentedControlSetting = {
        let title = viewModel.outputs.articleInformationStrategyTitle
        let items = viewModel.outputs.articleInformationStrategySettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedArticleInformationStrategiIdentifier,
                                       items: items)
    }()

    private lazy var segmentedElementsCustomizationStyle: SegmentedControlSetting = {
        let title = viewModel.outputs.elementsCustomizationStyleTitle
        let items = viewModel.outputs.elementsCustomizationStyleSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedElementsCustomizationStyleIdentifier,
                                       items: items)
    }()

    private lazy var segmentedColorsCustomizationStyle: SegmentedControlSetting = {
        let title = viewModel.outputs.colorsCustomizationStyleTitle
        let items = viewModel.outputs.colorsCustomizationStyleSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedColorsCustomizationStyleIdentifier,
                                       items: items)
    }()

    private lazy var openCustomColorsBtn: UIButton = {
        return "Custom Colors"
            .blueRoundedButton
            .withPadding(Metrics.btnPadding)
    }()

    private lazy var segmentedReadOnlyMode: SegmentedControlSetting = {
        let title = viewModel.outputs.readOnlyTitle
        let items = viewModel.outputs.readOnlySettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedReadOnlyModeIdentifier,
                                       items: items)
    }()

    private lazy var segmentedThemeMode: SegmentedControlSetting = {
        let title = viewModel.outputs.themeModeTitle
        let items = viewModel.outputs.themeModeSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedThemeModeIdentifier,
                                       items: items)
    }()

    private lazy var segmentedStatusBarStyle: SegmentedControlSetting = {
        let title = viewModel.outputs.statusBarStyleTitle
        let items = viewModel.outputs.statusBarStyleSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedStatusBarStyleIdentifier,
                                       items: items)
    }()

    private lazy var segmentedNavigationBarStyle: SegmentedControlSetting = {
        let title = viewModel.outputs.navigationBarStyleTitle
        let items = viewModel.outputs.navigationBarStyleSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedNavigationBarStyleIdentifier,
                                       items: items)
    }()

    private lazy var segmentedModalStyle: SegmentedControlSetting = {
        let title = viewModel.outputs.modalStyleTitle
        let items = viewModel.outputs.modalStyleSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedModalStyleIdentifier,
                                       items: items)
    }()

    private lazy var segmentedInitialSort: SegmentedControlSetting = {
        let title = viewModel.outputs.initialSortTitle
        let items = viewModel.outputs.initialSortSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedInitialSortIdentifier,
                                       items: items)
    }()

    private lazy var customSortTitles: [OWSortOption: TextFieldSetting] = {
        return OWSortOption.allCases.reduce(into: [:]) { result, option in
            let title = viewModel.outputs.initialSortSettings[option.titleIndex]
            let txtField = TextFieldSetting(
                title: "\(title) sort title",
                placeholder: title,
                accessibilityPrefixId: Metrics.textFieldCustomSortTitleIdentifier[option] ?? "",
                text: "",
                font: FontBook.paragraph
            )
            result[option] = txtField
        }
    }()

    private lazy var segmentedFontGroupType: SegmentedControlSetting = {
        let title = viewModel.outputs.fontGroupTypeTitle
        let items = viewModel.outputs.fontGroupTypeSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedFontGroupTypeIdentifier,
                                       items: items)
    }()

    private lazy var textFieldCustomFontName: TextFieldSetting = {
        let txtField = TextFieldSetting(title: viewModel.outputs.customFontGroupTypeNameTitle,
                                        accessibilityPrefixId: Metrics.textFieldCustomFontNameIdentifier,
                                        font: FontBook.paragraph)
        return txtField
    }()

    private lazy var textFieldArticleURL: TextFieldSetting = {
        let txtField = TextFieldSetting(title: viewModel.outputs.articleURLTitle,
                                        accessibilityPrefixId: Metrics.textFieldArticleURLIdentifier,
                                        font: FontBook.paragraph)
        return txtField
    }()

    private lazy var textFieldArticleSection: TextFieldSetting = {
        let txtField = TextFieldSetting(title: viewModel.outputs.articleSectionTitle,
                                        accessibilityPrefixId: Metrics.textFieldArticleSectionIdentifier,
                                        font: FontBook.paragraph)
        return txtField
    }()

    private lazy var segmentedLanguageStrategy: SegmentedControlSetting = {
        let title = viewModel.outputs.languageStrategyTitle
        let items = viewModel.outputs.languageStrategySettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedLanguageStrategyIdentifier,
                                       items: items)
    }()

    private lazy var segmentedLocaleStrategy: SegmentedControlSetting = {
        let title = viewModel.outputs.localeStrategyTitle
        let items = viewModel.outputs.localeStrategySettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedLocaleStrategyIdentifier,
                                       items: items)
    }()

    private lazy var pickerLanguageCode: PickerSetting = {
        let title = viewModel.outputs.supportedLanguageTitle
        let items = viewModel.outputs.supportedLanguageItems
        let picker = PickerSetting(title: title,
                                   accessibilityPrefixId: Metrics.pickerLanguageCodeIdentifier,
                                   items: items)
        return picker
    }()

    private lazy var showLoginPromptSwitch: SwitchSetting = {
        return SwitchSetting(
            title: viewModel.outputs.showLoginPromptTitle,
            accessibilityPrefixId: Metrics.loginPromptSwitchIdentifier)
    }()

    private lazy var segmentedOrientationEnforcement: SegmentedControlSetting = {
        let title = viewModel.outputs.orientationEnforcementTitle
        let items = viewModel.outputs.orientationEnforcementSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedLocaleStrategyIdentifier,
                                       items: items)
    }()

    private let viewModel: GeneralSettingsViewModeling
    private var cancellables = Set<AnyCancellable>()

    private lazy var segmentedCommentActionsColor: SegmentedControlSetting = {
        let title = viewModel.outputs.commentActionsColorTitle
        let items = viewModel.outputs.commentActionsColorSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedCommentActionsColorIdentifier,
                                       items: items)
    }()

    private lazy var segmentedCommentActionsFontStyle: SegmentedControlSetting = {
        let title = viewModel.outputs.commentActionsFontStyleTitle
        let items = viewModel.outputs.commentActionsFontStyleSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedCommentActionsFontStyleIdentifier,
                                       items: items)
    }()

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

private extension GeneralSettingsView {
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
        stackView.addArrangedSubview(segmentedArticleHeaderStyle)
        stackView.addArrangedSubview(segmentedArticleInformationStrategy)
        stackView.addArrangedSubview(textFieldArticleURL)
        stackView.addArrangedSubview(textFieldArticleSection)
        stackView.addArrangedSubview(segmentedElementsCustomizationStyle)
        stackView.addArrangedSubview(segmentedColorsCustomizationStyle)
        stackView.addArrangedSubview(openCustomColorsBtn)
        stackView.addArrangedSubview(segmentedReadOnlyMode)
        stackView.addArrangedSubview(segmentedThemeMode)
        stackView.addArrangedSubview(segmentedStatusBarStyle)
        stackView.addArrangedSubview(segmentedNavigationBarStyle)
        stackView.addArrangedSubview(segmentedModalStyle)
        stackView.addArrangedSubview(segmentedInitialSort)
        for customSortTitleSetting in OWSortOption.allCases.compactMap({ customSortTitles[$0] }) {
            stackView.addArrangedSubview(customSortTitleSetting)
        }
        stackView.addArrangedSubview(segmentedFontGroupType)
        stackView.addArrangedSubview(textFieldCustomFontName)
        stackView.addArrangedSubview(segmentedLanguageStrategy)
        stackView.addArrangedSubview(pickerLanguageCode)
        stackView.addArrangedSubview(segmentedLocaleStrategy)
        stackView.addArrangedSubview(showLoginPromptSwitch)
        stackView.addArrangedSubview(segmentedOrientationEnforcement)
        stackView.addArrangedSubview(segmentedCommentActionsColor)
        stackView.addArrangedSubview(segmentedCommentActionsFontStyle)
    }

    // swiftlint:disable function_body_length
    func setupObservers() {
        viewModel.outputs.articleHeaderStyle
            .map { $0.index }
            .assign(to: \.selectedSegmentIndex, on: segmentedArticleHeaderStyle.segmentedControl)
            .store(in: &cancellables)

        viewModel.outputs.articleInformationStrategy
            .map { $0.index }
            .assign(to: \.selectedSegmentIndex, on: segmentedArticleInformationStrategy.segmentedControl)
            .store(in: &cancellables)

        viewModel.outputs.orientationEnforcement
            .map { $0.index }
            .assign(to: \.selectedSegmentIndex, on: segmentedOrientationEnforcement.segmentedControl)
            .store(in: &cancellables)

        viewModel.outputs.commentActionsColor
            .map { $0.rawValue }
            .assign(to: \.selectedSegmentIndex, on: segmentedCommentActionsColor.segmentedControl)
            .store(in: &cancellables)

        viewModel.outputs.commentActionsFontStyle
            .map { $0.rawValue }
            .assign(to: \.selectedSegmentIndex, on: segmentedCommentActionsFontStyle.segmentedControl)
            .store(in: &cancellables)

        viewModel.outputs.elementsCustomizationStyleIndex
            .assign(to: \.selectedSegmentIndex, on: segmentedElementsCustomizationStyle.segmentedControl)
            .store(in: &cancellables)

        viewModel.outputs.colorsCustomizationStyleIndex
            .assign(to: \.selectedSegmentIndex, on: segmentedColorsCustomizationStyle.segmentedControl)
            .store(in: &cancellables)

        viewModel.outputs.readOnlyModeIndex
            .assign(to: \.selectedSegmentIndex, on: segmentedReadOnlyMode.segmentedControl)
            .store(in: &cancellables)

        viewModel.outputs.themeModeIndex
            .assign(to: \.selectedSegmentIndex, on: segmentedThemeMode.segmentedControl)
            .store(in: &cancellables)

        viewModel.outputs.statusBarStyleIndex
            .assign(to: \.selectedSegmentIndex, on: segmentedStatusBarStyle.segmentedControl)
            .store(in: &cancellables)

        viewModel.outputs.navigationBarStyleIndex
            .assign(to: \.selectedSegmentIndex, on: segmentedNavigationBarStyle.segmentedControl)
            .store(in: &cancellables)

        viewModel.outputs.modalStyleIndex
            .assign(to: \.selectedSegmentIndex, on: segmentedModalStyle.segmentedControl)
            .store(in: &cancellables)

        viewModel.outputs.initialSortIndex
            .assign(to: \.selectedSegmentIndex, on: segmentedInitialSort.segmentedControl)
            .store(in: &cancellables)

        viewModel.outputs.customSortTitles
            .sink(receiveValue: { [weak self] customSortTitles in
                for option in OWSortOption.allCases {
                    self?.customSortTitles[option]?.textFieldControl.text = customSortTitles[option]
                }
            })
            .store(in: &cancellables)

        viewModel.outputs.customSortTitles
            .sink(receiveValue: { [weak self] customSortTitles in
                for option in OWSortOption.allCases {
                    self?.customSortTitles[option]?.textFieldControl.text = customSortTitles[option] ?? ""
                }
            })
            .store(in: &cancellables)

        viewModel.outputs.fontGroupTypeIndex
            .assign(to: \.selectedSegmentIndex, on: segmentedFontGroupType.segmentedControl)
            .store(in: &cancellables)

        viewModel.outputs.customFontGroupTypeName
            .map { $0 as String? }
            .assign(to: \.text, on: textFieldCustomFontName.textFieldControl)
            .store(in: &cancellables)

        viewModel.outputs.articleAssociatedURL
            .map { $0 as String? }
            .assign(to: \.text, on: textFieldArticleURL.textFieldControl)
            .store(in: &cancellables)

        viewModel.outputs.articleSection
            .map { $0 as String? }
            .assign(to: \.text, on: textFieldArticleSection.textFieldControl)
            .store(in: &cancellables)

        segmentedArticleHeaderStyle.segmentedControl.selectedSegmentIndexPublisher
            .map { OWArticleHeaderStyle.articleHeaderStyle(fromIndex: $0) }
            .bind(to: viewModel.inputs.articleHeaderSelectedStyle)
            .store(in: &cancellables)

        segmentedArticleInformationStrategy.segmentedControl.selectedSegmentIndexPublisher
            .map { OWArticleInformationStrategy.articleInformationStrategy(fromIndex: $0) }
            .bind(to: viewModel.inputs.articleInformationSelectedStrategy)
            .store(in: &cancellables)

        segmentedOrientationEnforcement.segmentedControl.selectedSegmentIndexPublisher
            .map { OWOrientationEnforcement.orientationEnforcement(fromIndex: $0) }
            .bind(to: viewModel.inputs.orientationSelectedEnforcement)
            .store(in: &cancellables)

        segmentedCommentActionsColor.segmentedControl.selectedSegmentIndexPublisher
            .map { OWCommentActionsColor(rawValue: $0) }
            .unwrap()
            .bind(to: viewModel.inputs.commentActionsColorSelected)
            .store(in: &cancellables)

        segmentedCommentActionsFontStyle.segmentedControl.selectedSegmentIndexPublisher
            .map { OWCommentActionsFontStyle(rawValue: $0) }
            .unwrap()
            .bind(to: viewModel.inputs.commentActionsFontStyleSelected)
            .store(in: &cancellables)

        segmentedElementsCustomizationStyle.segmentedControl.selectedSegmentIndexPublisher
            .bind(to: viewModel.inputs.elementsCustomizationStyleSelectedIndex)
            .store(in: &cancellables)

        segmentedColorsCustomizationStyle.segmentedControl.selectedSegmentIndexPublisher
            .bind(to: viewModel.inputs.colorsCustomizationStyleSelectedIndex)
            .store(in: &cancellables)

        segmentedReadOnlyMode.segmentedControl.selectedSegmentIndexPublisher
            .bind(to: viewModel.inputs.readOnlyModeSelectedIndex)
            .store(in: &cancellables)

        segmentedThemeMode.segmentedControl.selectedSegmentIndexPublisher
            .bind(to: viewModel.inputs.themeModeSelectedIndex)
            .store(in: &cancellables)

        segmentedStatusBarStyle.segmentedControl.selectedSegmentIndexPublisher
            .bind(to: viewModel.inputs.statusBarStyleSelectedIndex)
            .store(in: &cancellables)

        segmentedNavigationBarStyle.segmentedControl.selectedSegmentIndexPublisher
            .bind(to: viewModel.inputs.navigationBarStyleSelectedIndex)
            .store(in: &cancellables)

        segmentedModalStyle.segmentedControl.selectedSegmentIndexPublisher
            .bind(to: viewModel.inputs.modalStyleSelectedIndex)
            .store(in: &cancellables)

        segmentedInitialSort.segmentedControl.selectedSegmentIndexPublisher
            .bind(to: viewModel.inputs.initialSortSelectedIndex)
            .store(in: &cancellables)

        let sortedCustomSortTitlesSettings = OWSortOption.allCases.compactMap { customSortTitles[$0] }
        sortedCustomSortTitlesSettings.map { $0.textFieldControl.textPublisher }
            .combineLatest()
            .map { textValues in
                return zip(OWSortOption.allCases, textValues)
                    .reduce(into: [OWSortOption: String]()) { result, optionTextTuple in
                        result[optionTextTuple.0] = optionTextTuple.1
                    }
            }
            .bind(to: viewModel.inputs.customSortTitlesChanged)
            .store(in: &cancellables)

        segmentedFontGroupType.segmentedControl.selectedSegmentIndexPublisher
            .bind(to: viewModel.inputs.fontGroupTypeSelectedIndex)
            .store(in: &cancellables)

        textFieldCustomFontName.textFieldControl.textPublisher
            .unwrap()
            .bind(to: viewModel.inputs.customFontGroupSelectedName)
            .store(in: &cancellables)

        viewModel.outputs.showCustomFontName
            .map { !$0 }
            .assign(to: \.isHidden, on: textFieldCustomFontName)
            .store(in: &cancellables)

        textFieldArticleURL.textFieldControl.textPublisher
            .unwrap()
            .bind(to: viewModel.inputs.articleAssociatedSelectedURL)
            .store(in: &cancellables)

        textFieldArticleSection.textFieldControl.textPublisher
            .unwrap()
            .bind(to: viewModel.inputs.articleSelectedSection)
            .store(in: &cancellables)

        viewModel.outputs.languageStrategyIndex
            .assign(to: \.selectedSegmentIndex, on: segmentedLanguageStrategy.segmentedControl)
            .store(in: &cancellables)

        segmentedLanguageStrategy.segmentedControl.selectedSegmentIndexPublisher
            .bind(to: viewModel.inputs.languageStrategySelectedIndex)
            .store(in: &cancellables)

        viewModel.outputs.localeStrategyIndex
            .assign(to: \.selectedSegmentIndex, on: segmentedLocaleStrategy.segmentedControl)
            .store(in: &cancellables)

        segmentedLocaleStrategy.segmentedControl.selectedSegmentIndexPublisher
            .bind(to: viewModel.inputs.localeStrategySelectedIndex)
            .store(in: &cancellables)

        viewModel.outputs.showLoginPrompt
            .assign(to: \.isOn, on: showLoginPromptSwitch.switchControl)
            .store(in: &cancellables)

        showLoginPromptSwitch.switchControl.isOnPublisher
            .bind(to: viewModel.inputs.showLoginPromptSelected)
            .store(in: &cancellables)

        viewModel.outputs.languageName
            .map { [weak self] in
                guard let self, let index = self.viewModel.outputs.supportedLanguageItems.firstIndex(of: $0)
                else { return nil }
                return (index, 0)
            }
            .unwrap()
            .assign(to: \.selectedIndexPath, on: pickerLanguageCode.pickerControl.publisher)
            .store(in: &cancellables)

        pickerLanguageCode.pickerControl.publisher.$selectedIndexPath
            .map { [weak self] in
                guard let self else { return nil }
                return self.viewModel.outputs.supportedLanguageItems[$0.row]
            }
            .unwrap()
            .removeDuplicates()
            .bind(to: viewModel.inputs.languageSelectedName)
            .store(in: &cancellables)

        viewModel.outputs.shouldShowSetLanguage
            .map { !$0 }
            .assign(to: \.isHidden, on: pickerLanguageCode)
            .store(in: &cancellables)

        viewModel.outputs.shouldShowArticleURL
            .map { !$0 }
            .assign(to: \.isHidden, on: textFieldArticleURL)
            .store(in: &cancellables)

        viewModel.outputs.shouldShowColorSettingButton
            .map { !$0 }
            .assign(to: \.isHidden, on: openCustomColorsBtn)
            .store(in: &cancellables)

        openCustomColorsBtn.tapPublisher
            .bind(to: viewModel.inputs.openColorsCustomizationClicked)
            .store(in: &cancellables)
    }
}
