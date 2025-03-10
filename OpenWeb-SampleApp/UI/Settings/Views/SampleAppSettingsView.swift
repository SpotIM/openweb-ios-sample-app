//
//  SampleAppSettings.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 12/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift

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
    private let disposeBag = DisposeBag()

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
            .bind(to: segmentedDeeplink.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        segmentedDeeplink.rx.selectedSegmentIndex
            .map { SampleAppDeeplink.deeplink(fromIndex: $0) }
            .bind(to: viewModel.inputs.deeplinkOptionSelected)
            .disposed(by: disposeBag)

        viewModel.outputs.callingMethodOption
            .map { $0.rawValue }
            .bind(to: segmentedCallingMethod.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        segmentedCallingMethod.rx.selectedSegmentIndex
            .compactMap { SampleAppCallingMethod(rawValue: $0) }
            .bind(to: viewModel.inputs.callingMethodOptionSelected)
            .disposed(by: disposeBag)

        viewModel.outputs.flowsLoggerEnabled
            .bind(to: switchFlowsLogger.rx.isOn)
            .disposed(by: disposeBag)

        switchFlowsLogger.rx.isOn
            .bind(to: viewModel.inputs.flowsLoggerEnable)
            .disposed(by: disposeBag)
    }
}
