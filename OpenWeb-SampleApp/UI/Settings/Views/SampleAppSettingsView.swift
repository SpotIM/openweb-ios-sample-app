//
//  SampleAppSettings.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 12/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa

class SampleAppSettingsView: UIView {

    private struct Metrics {
        static let identifier = "sample_app_settings_view_id"
        static let deeplinkIdentifier = "deeplink_selection_id"
        static let callingMethodIdentifier = "calling_method_selection_id"
        static let flowsLoggerIdentifier = "flows_logger_switch_id"
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

    private lazy var segmentedDeeplink: SegmentedControlSetting = {
        let title = viewModel.outputs.appDeeplinkTitle
        let items = viewModel.outputs.appDeeplinkSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.deeplinkIdentifier,
                                       items: items)
    }()

    private lazy var segmentedCallingMethod: SegmentedControlSetting = {
        return SegmentedControlSetting(
            title: viewModel.outputs.callingMethodTitle,
            accessibilityPrefixId: Metrics.callingMethodIdentifier,
            items: viewModel.outputs.callingMethodSettings
        )
    }()

    private lazy var switchFlowsLogger: SwitchSetting = {
        let title = viewModel.outputs.flowsLoggerSwitchTitle
        return SwitchSetting(title: title, accessibilityPrefixId: Metrics.flowsLoggerIdentifier)
    }()

    private let viewModel: SampleAppSettingsViewModeling
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: SampleAppSettingsViewModeling) {
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

private extension SampleAppSettingsView {
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
        stackView.addArrangedSubview(segmentedDeeplink)
        stackView.addArrangedSubview(segmentedCallingMethod)
        stackView.addArrangedSubview(switchFlowsLogger)
    }

    func setupObservers() {
        viewModel.outputs.deeplinkOption
            .map { $0.index }
            .assign(to: \.selectedSegmentIndex, on: segmentedDeeplink.segmentedControl)
            .store(in: &cancellables)

        segmentedDeeplink.segmentedControl.selectedSegmentIndexPublisher
            .map { SampleAppDeeplink.deeplink(fromIndex: $0) }
            .bind(to: viewModel.inputs.deeplinkOptionSelected)
            .store(in: &cancellables)

        viewModel.outputs.callingMethodOption
            .map { $0.rawValue }
            .assign(to: \.selectedSegmentIndex, on: segmentedCallingMethod.segmentedControl)
            .store(in: &cancellables)

        segmentedCallingMethod.segmentedControl.selectedSegmentIndexPublisher
            .compactMap { SampleAppCallingMethod(rawValue: $0) }
            .bind(to: viewModel.inputs.callingMethodOptionSelected)
            .store(in: &cancellables)

        viewModel.outputs.flowsLoggerEnabled
            .assign(to: \.isOn, on: switchFlowsLogger.switchControl)
            .store(in: &cancellables)

        switchFlowsLogger.switchControl.isOnPublisher
            .bind(to: viewModel.inputs.flowsLoggerEnable)
            .store(in: &cancellables)
    }
}
