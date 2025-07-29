//
//  TestAPIVC.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 31/08/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

class TestAPIVC: UIViewController {
    private struct Metrics {
        static let identifier = "test_api_vc_id"
        static let settingsBarItemIdentifier = "settings_bar_item_id"
        static let authBarItemIdentifier = "auth_bar_item_id"
        static let conversationPresetSelectionIdentifier = "conversation_preset_selection_id"
        static let presetPickerIdentifier = "preset_picker_id"
        static let toolbarPickerIdentifier = "toolbar_picker_id"
        static let btnDoneIdentifier = "btn_done_id"
        static let btnSelectPresetIdentifier = "btn_select_preset_id"
        static let envLabelIdentifier = "environment_label_id"
        static let configurationLabelIdentifier = "configuration_label_id"
        static let txtFieldSpotIdIdentifier = "spot_id"
        static let txtFieldPostIdIdentifier = "post_id"
        static let btnUIFlowsIdentifier = "btn_ui_flows_id"
        static let btnUIViewsIdentifier = "btn_ui_views_id"
        static let btnMiscellaneousIdentifier = "btn_miscellaneous_id"
        static let btnTestingPlaygroundIdentifier = "btn_testing_playground_id"
        static let btnAutomationIdentifier = "btn_automation_id"
        static let verticalMargin: CGFloat = 40
        static let shortVerticalMargin: CGFloat = 15
        static let horizontalMargin: CGFloat = 50
        static let textFieldHeight: CGFloat = 40
        static let buttonVerticalMargin: CGFloat = 20
        static let buttonPadding: CGFloat = 10
        static let buttonHeight: CGFloat = 50
        static let pickerHeight: CGFloat = 250
        static let toolbarPickerHeight: CGFloat = 50
        static let animatePickerDuration: CGFloat = 0.6
        static let animatePickerDamping: CGFloat = 0.5
        static let animatePickerVelocity: CGFloat = 0.5
        static let authBarItemMargin: CGFloat = 65
    }

    private let viewModel: TestAPIViewModeling
    private var cancellables = Set<AnyCancellable>()

    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var settingsBarItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "settingsIcon"),
                               style: .plain,
                               target: nil,
                               action: nil)
    }()

    private lazy var authBarItem: UIBarButtonItem = {
        let authBarItem = UIBarButtonItem(image: UIImage(named: "authenticationIcon"),
                                   style: .plain,
                                   target: nil,
                                   action: nil)
        authBarItem.imageInsets = UIEdgeInsets(top: 0, left: Metrics.authBarItemMargin, bottom: 0, right: 0)
        return authBarItem
    }()

    private lazy var conversationPresetSelectionView: UIView = {
        let spotPresetSelection = UIView()
        spotPresetSelection.backgroundColor = ColorPalette.shared.color(type: .background)

        spotPresetSelection.addSubview(toolbarPicker)
        toolbarPicker.snp.makeConstraints { make in
            make.height.equalTo(Metrics.toolbarPickerHeight)
            make.top.leading.trailing.equalToSuperview()
        }

        spotPresetSelection.addSubview(presetPicker)
        presetPicker.snp.makeConstraints { make in
            make.width.bottom.leading.trailing.equalToSuperview()
            make.top.equalTo(toolbarPicker.snp.bottom)
        }

        return spotPresetSelection
    }()

    private lazy var presetPicker: UIPickerView = {
        return UIPickerView()
    }()

    private lazy var toolbarPicker: UIToolbar = {
        var toolbar = UIToolbar()
        toolbar.barTintColor = ColorPalette.shared.color(type: .darkGrey)
        toolbar.tintColor = ColorPalette.shared.color(type: .blackish)

        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let title = NSLocalizedString("PresetSelection", comment: "").label
            .font(FontBook.paragraphBold)
            .barButtonItem

        toolbar.setItems([spaceButton, title, spaceButton, btnDone.barButtonItem], animated: false)
        return toolbar
    }()

    private lazy var btnDone: UIButton = {
        return NSLocalizedString("Done", comment: "")
                .blueRoundedButton
                .withPadding(Metrics.buttonPadding)
    }()

    private lazy var envLabel: UILabel = {
        return UILabel()
            .font(FontBook.paragraphBold)
            .textColor(.red)
    }()

    private lazy var configurationLabel: UILabel = {
        return UILabel()
            .font(FontBook.paragraphBold)
            .textColor(.gray)
    }()

    private lazy var btnSelectPreset: UIButton = {
        return NSLocalizedString("SelectPreset", comment: "").darkGrayRoundedButton
    }()

    private lazy var txtFieldSpotId: TextFieldSetting = {
        let txtField = TextFieldSetting(title: NSLocalizedString("SpotId", comment: "") + ":",
                                        accessibilityPrefixId: Metrics.txtFieldSpotIdIdentifier)
        return txtField
    }()

    private lazy var txtFieldPostId: TextFieldSetting = {
        let txtField = TextFieldSetting(title: NSLocalizedString("PostId", comment: "") + ":",
                                        accessibilityPrefixId: Metrics.txtFieldPostIdIdentifier)
        return txtField
    }()

    private lazy var btnUIFlows: UIButton = {
        return NSLocalizedString("UIFlows", comment: "").blueRoundedButton
    }()

    private lazy var btnUIViews: UIButton = {
        return NSLocalizedString("UIViews", comment: "").blueRoundedButton
    }()

    private lazy var btnMiscellaneous: UIButton = {
        return NSLocalizedString("Miscellaneous", comment: "").blueRoundedButton
    }()

    private lazy var btnTestingPlayground: UIButton = {
        return NSLocalizedString("TestingPlayground", comment: "").blueRoundedButton
    }()

    private lazy var btnAutomation: UIButton = {
        return NSLocalizedString("Automation", comment: "").blueRoundedButton
    }()

    init(viewModel: TestAPIViewModeling = TestAPIViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        viewModel.inputs.viewWillAppear.send()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        applyAccessibility()
        navigationItem.rightBarButtonItems = [settingsBarItem, authBarItem]
        setupObservers()
    }
}

private extension TestAPIVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        settingsBarItem.accessibilityIdentifier = Metrics.settingsBarItemIdentifier
        authBarItem.accessibilityIdentifier = Metrics.authBarItemIdentifier
        conversationPresetSelectionView.accessibilityIdentifier = Metrics.conversationPresetSelectionIdentifier
        presetPicker.accessibilityIdentifier = Metrics.presetPickerIdentifier
        toolbarPicker.accessibilityIdentifier = Metrics.toolbarPickerIdentifier
        btnDone.accessibilityIdentifier = Metrics.btnDoneIdentifier
        btnSelectPreset.accessibilityIdentifier = Metrics.btnSelectPresetIdentifier
        envLabel.accessibilityIdentifier = Metrics.envLabelIdentifier
        configurationLabel.accessibilityIdentifier = Metrics.configurationLabelIdentifier
        btnUIFlows.accessibilityIdentifier = Metrics.btnUIFlowsIdentifier
        btnUIViews.accessibilityIdentifier = Metrics.btnUIViewsIdentifier
        btnMiscellaneous.accessibilityIdentifier = Metrics.btnMiscellaneousIdentifier
        btnTestingPlayground.accessibilityIdentifier = Metrics.btnTestingPlaygroundIdentifier
        btnAutomation.accessibilityIdentifier = Metrics.btnAutomationIdentifier
    }

    @objc func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        self.navigationItem.largeTitleDisplayMode = .never

        // Adding scroll view
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        scrollView.addSubview(envLabel)
        envLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.top.equalTo(scrollView.contentLayoutGuide).offset(Metrics.shortVerticalMargin)
        }

        scrollView.addSubview(configurationLabel)
        configurationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.top.equalTo(envLabel.snp.bottom).offset(Metrics.shortVerticalMargin)
        }

        // Adding select preset button
        scrollView.addSubview(btnSelectPreset)
        btnSelectPreset.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.top.equalTo(configurationLabel.snp.bottom).offset(Metrics.verticalMargin)
        }

        scrollView.addSubview(txtFieldSpotId)
        txtFieldSpotId.snp.makeConstraints { make in
            make.top.equalTo(btnSelectPreset.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
            make.height.equalTo(Metrics.textFieldHeight)
        }

        scrollView.addSubview(txtFieldPostId)
        txtFieldPostId.snp.makeConstraints { make in
            make.top.equalTo(txtFieldSpotId.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
            make.height.equalTo(Metrics.textFieldHeight)
        }

        // Adding UIFlows button
        scrollView.addSubview(btnUIFlows)
        btnUIFlows.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(txtFieldPostId.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
        }

        // Adding UIViews button
        scrollView.addSubview(btnUIViews)
        btnUIViews.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnUIFlows.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
        }

        // Adding miscellaneous button
        scrollView.addSubview(btnMiscellaneous)
        btnMiscellaneous.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnUIViews.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            #if !(BETA || ADS)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
            #endif
        }

        var currentBottomView: UIView = btnMiscellaneous

        #if BETA
        // Adding testing playground button
        scrollView.addSubview(btnTestingPlayground)
        btnTestingPlayground.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnMiscellaneous.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            #if !(AUTOMATION)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
            #endif
        }
        currentBottomView = btnTestingPlayground
        #endif

        #if AUTOMATION
        // Adding testing playground button
        scrollView.addSubview(btnAutomation)
        btnAutomation.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(currentBottomView.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(scrollView).offset(Metrics.horizontalMargin)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalMargin)
        }
        currentBottomView = btnAutomation
        #endif

        // Setup preset picker and its container.
        view.addSubview(conversationPresetSelectionView)
        conversationPresetSelectionView.snp.makeConstraints { make in
            make.height.equalTo(Metrics.pickerHeight)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview().inset(-Metrics.pickerHeight)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        viewModel.outputs.selectedSpotId
            .map { $0 as String? }
            .assign(to: \.text, on: txtFieldSpotId.textFieldControl)
            .store(in: &cancellables)

        viewModel.outputs.selectedPostId
            .map { $0 as String? }
            .assign(to: \.text, on: txtFieldPostId.textFieldControl)
            .store(in: &cancellables)

        // Bind text fields
        txtFieldSpotId.textFieldControl.textPublisher
            .unwrap()
            .removeDuplicates()
            .bind(to: viewModel.inputs.enteredSpotId)
            .store(in: &cancellables)

        txtFieldPostId.textFieldControl.textPublisher
            .unwrap()
            .removeDuplicates()
            .bind(to: viewModel.inputs.enteredPostId)
            .store(in: &cancellables)

        // Bind buttons
        btnSelectPreset.tapPublisher
            .bind(to: viewModel.inputs.selectPresetTapped)
            .store(in: &cancellables)

        btnUIFlows.tapPublisher
            .bind(to: viewModel.inputs.uiFlowsTapped)
            .store(in: &cancellables)

        btnUIViews.tapPublisher
            .bind(to: viewModel.inputs.uiViewsTapped)
            .store(in: &cancellables)

        btnMiscellaneous.tapPublisher
            .bind(to: viewModel.inputs.miscellaneousTapped)
            .store(in: &cancellables)

        btnTestingPlayground.tapPublisher
            .bind(to: viewModel.inputs.testingPlaygroundTapped)
            .store(in: &cancellables)

        btnAutomation.tapPublisher
            .bind(to: viewModel.inputs.automationTapped)
            .store(in: &cancellables)

        settingsBarItem.tapPublisher
            .bind(to: viewModel.inputs.settingsTapped)
            .store(in: &cancellables)

        authBarItem.tapPublisher
            .bind(to: viewModel.inputs.authenticationTapped)
            .store(in: &cancellables)

        // Bind select preset
        viewModel.outputs.shouldShowSelectPreset
            .dropFirst(1)
            .sink { [weak self] in
                self?.showPresetPicker($0)
            }
            .store(in: &cancellables)

        btnDone.tapPublisher
            .map { false }
            .voidify()
            .bind(to: viewModel.inputs.doneSelectPresetTapped)
            .store(in: &cancellables)

        // Bind picker
        presetPicker.publisher.$selectedIndexPath
            .map { event in
                return event.row
            }
            .removeDuplicates()
            .bind(to: viewModel.inputs.selectedConversationPresetIndex)
            .store(in: &cancellables)

        viewModel.outputs.conversationPresets
            .map { options in
                return options.map { $0.displayName }
            }
            .assign(to: \.itemTitles, on: presetPicker.publisher)
            .store(in: &cancellables)

        viewModel.outputs.envLabelString
            .map { $0 as String? }
            .assign(to: \.text, on: envLabel)
            .store(in: &cancellables)

        viewModel.outputs.isEnvLabelVisible
            .map { !$0 }
            .assign(to: \.isHidden, on: envLabel)
            .store(in: &cancellables)

        viewModel.outputs.configurationLabelString
            .map { $0 as String? }
            .assign(to: \.text, on: configurationLabel)
            .store(in: &cancellables)

        viewModel.outputs.isConfigurationLabelVisible
            .map { !$0 }
            .assign(to: \.isHidden, on: configurationLabel)
            .store(in: &cancellables)
    }
}

private extension TestAPIVC {

    func showPresetPicker(_ shouldShow: Bool) {
        if shouldShow {
            // Dismiss keyboard
            self.view.endEditing(true)
        }
        UIView.animate(withDuration: Metrics.animatePickerDuration,
                       delay: 0.0,
                       usingSpringWithDamping: Metrics.animatePickerDamping,
                       initialSpringVelocity: Metrics.animatePickerVelocity) {
            self.conversationPresetSelectionView.snp.updateConstraints { update in
                update.bottom.equalToSuperview().inset(shouldShow ? 0 : -Metrics.pickerHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
}
