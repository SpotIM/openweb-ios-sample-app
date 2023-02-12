//
//  SettingsVC.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 18/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

class SettingsVC: UIViewController {

    fileprivate struct Metrics {
        static let identifier = "settings_vc_id"
        static let switchHideArticleHeaderIdentifier = "hide_article_header"
        static let switchCommentCreationNewDesignIdentifier = "comment_creation_new_design"
        static let segmentedReadOnlyModeIdentifier = "read_only_mode"
        static let segmentedThemeModeIdentifier = "theme_mode"
        static let segmentedModalStyleIdentifier = "modal_style"
        static let textFieldArticleURLIdentifier = "article_url"
        static let verticalOffset: CGFloat = 50
        static let horizontalOffset: CGFloat = 10
    }

    fileprivate lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    fileprivate lazy var switchHideArticleHeader: SwitchSetting = {
        return SwitchSetting(title: viewModel.outputs.hideArticleHeaderTitle, accessibilityPrefixId: Metrics.switchHideArticleHeaderIdentifier)
    }()

    fileprivate lazy var switchCommentCreationNewDesign: SwitchSetting = {
        return SwitchSetting(title: viewModel.outputs.commentCreationNewDesignTitle,
                             accessibilityPrefixId: Metrics.switchCommentCreationNewDesignIdentifier)
    }()

    fileprivate lazy var segmentedReadOnlyMode: SegmentedControlSetting = {
        let title = viewModel.outputs.readOnlyTitle
        let items = viewModel.outputs.readOnlySettings

        return SegmentedControlSetting(title: title, accessibilityPrefixId: Metrics.segmentedReadOnlyModeIdentifier, items: items)
    }()

    fileprivate lazy var segmentedThemeMode: SegmentedControlSetting = {
        let title = viewModel.outputs.themeModeTitle
        let items = viewModel.outputs.themeModeSettings

        return SegmentedControlSetting(title: title, accessibilityPrefixId: Metrics.segmentedThemeModeIdentifier, items: items)
    }()

    fileprivate lazy var segmentedModalStyle: SegmentedControlSetting = {
        let title = viewModel.outputs.modalStyleTitle
        let items = viewModel.outputs.modalStyleSettings

        return SegmentedControlSetting(title: title, accessibilityPrefixId: Metrics.segmentedModalStyleIdentifier, items: items)
    }()

    fileprivate lazy var textFieldArticleURL: TextFieldSetting = {
        let txtField = TextFieldSetting(title: viewModel.outputs.articleURLTitle,
                                        accessibilityPrefixId: Metrics.textFieldArticleURLIdentifier,
                                        font: FontBook.paragraph)
        return txtField
    }()

    fileprivate let viewModel: SettingsViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: SettingsViewModeling) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        setupViews()
        applyAccessibility()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
    }
}

fileprivate extension SettingsVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)

        title = viewModel.outputs.title

        // Adding scroll view
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        scrollView.addSubview(switchHideArticleHeader)
        switchHideArticleHeader.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Metrics.horizontalOffset)
            make.top.equalTo(scrollView.contentLayoutGuide).offset(Metrics.verticalOffset)
        }

        scrollView.addSubview(switchCommentCreationNewDesign)
        switchCommentCreationNewDesign.snp.makeConstraints { make in
            make.top.equalTo(switchHideArticleHeader.snp.bottom).offset(Metrics.verticalOffset)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Metrics.horizontalOffset)
        }

        scrollView.addSubview(segmentedReadOnlyMode)
        segmentedReadOnlyMode.snp.makeConstraints { make in
            make.top.equalTo(switchCommentCreationNewDesign.snp.bottom).offset(Metrics.verticalOffset)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Metrics.horizontalOffset)
        }

        scrollView.addSubview(segmentedThemeMode)
        segmentedThemeMode.snp.makeConstraints { make in
            make.top.equalTo(segmentedReadOnlyMode.snp.bottom).offset(Metrics.verticalOffset)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Metrics.horizontalOffset)
        }

        scrollView.addSubview(segmentedModalStyle)
        segmentedModalStyle.snp.makeConstraints { make in
            make.top.equalTo(segmentedThemeMode.snp.bottom).offset(Metrics.verticalOffset)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Metrics.horizontalOffset)
        }

        scrollView.addSubview(textFieldArticleURL)
        textFieldArticleURL.snp.makeConstraints { make in
            make.top.equalTo(segmentedModalStyle.snp.bottom).offset(Metrics.verticalOffset)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Metrics.horizontalOffset)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalOffset)
        }
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

        textFieldArticleURL.rx.textFieldText
            .bind(to: viewModel.inputs.articleAssociatedSelectedURL)
            .disposed(by: disposeBag)
    }
}
