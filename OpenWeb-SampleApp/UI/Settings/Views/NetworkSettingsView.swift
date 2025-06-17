//
//  NetworkSettingsView.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 21/02/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa

class NetworkSettingsView: UIView {

    private struct Metrics {
        static let identifier = "network_settings_view_id"
        static let segmentedNetworkEnvironmentIdentifier = "network_environment"
        static let customUrlTextFieldIdentifier = "custom_url_text_field"
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

    private lazy var segmentedNetworkEnvironment: SegmentedControlSetting = {
        let title = viewModel.outputs.networkEnvironmentTitle
        let items = viewModel.outputs.networkEnvironmentSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedNetworkEnvironmentIdentifier,
                                       items: items)
    }()

    private lazy var stagingNamespaceTextField: TextFieldSetting = {
        return TextFieldSetting(title: viewModel.outputs.networkEnvironmentCustomTitle,
                                placeholder: "staging-v2",
                                accessibilityPrefixId: Metrics.identifier,
                                font: FontBook.helperLight)
    }()

    private lazy var customUrlTextField: TextFieldSetting = {
        return TextFieldSetting(title: "Custom URL",
                                placeholder: "https://example.com",
                                accessibilityPrefixId: Metrics.customUrlTextFieldIdentifier,
                                font: FontBook.helperLight)
    }()

    private let viewModel: NetworkSettingsViewModeling
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: NetworkSettingsViewModeling) {
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

private extension NetworkSettingsView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        self.segmentedNetworkEnvironment.accessibilityIdentifier = Metrics.segmentedNetworkEnvironmentIdentifier
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
        stackView.addArrangedSubview(segmentedNetworkEnvironment)
        stackView.addArrangedSubview(stagingNamespaceTextField)
        stackView.addArrangedSubview(customUrlTextField)
    }

    func setupObservers() {
        viewModel.outputs.networkEnvironment
            .map { $0.index }
            .assign(to: \.selectedSegmentIndex, on: segmentedNetworkEnvironment.segmentedControl)
            .store(in: &cancellables)

        viewModel.outputs.networkEnvironment
            .map {
                switch $0 {
                case .staging(let namespace):
                    return namespace
                default:
                    return nil
                }
            }
            .unwrap()
            .assign(to: \.text, on: stagingNamespaceTextField.textFieldControl)
            .store(in: &cancellables)

        viewModel.outputs.networkEnvironment
            .map {
                switch $0 {
                case .custom(let url):
                    return url
                default:
                    return nil
                }
            }
            .unwrap()
            .assign(to: \.text, on: customUrlTextField.textFieldControl)
            .store(in: &cancellables)

        let selectedSegmentPublisher = segmentedNetworkEnvironment.segmentedControl.selectedSegmentIndexPublisher.share()

        // Non custom network environment (neither staging nor custom URL)
        selectedSegmentPublisher
            .filter { $0 != OWNetworkEnvironment.staging(namespace: nil).index && $0 != OWNetworkEnvironment.custom(url: nil).index }
            .map { OWNetworkEnvironment(from: $0) }
            .bind(to: viewModel.inputs.networkEnvironmentSelected)
            .store(in: &cancellables)

        // Staging network environment
        Publishers.CombineLatest(selectedSegmentPublisher, stagingNamespaceTextField.textFieldControl.textPublisher.unwrap())
            .filter { $0.0 == OWNetworkEnvironment.staging(namespace: nil).index }
            .map { OWNetworkEnvironment(from: $0.0, namespace: $0.1) }
            .bind(to: viewModel.inputs.networkEnvironmentSelected)
            .store(in: &cancellables)

        // Custom URL network environment
        Publishers.CombineLatest(selectedSegmentPublisher, customUrlTextField.textFieldControl.textPublisher.unwrap())
            .filter { $0.0 == OWNetworkEnvironment.custom(url: nil).index }
            .map { OWNetworkEnvironment(from: $0.0, url: $0.1) }
            .bind(to: viewModel.inputs.networkEnvironmentSelected)
            .store(in: &cancellables)

        setupTextFieldVisibility(textField: stagingNamespaceTextField, visibleForIndex: OWNetworkEnvironment.staging(namespace: nil).index)
        setupTextFieldVisibility(textField: customUrlTextField, visibleForIndex: OWNetworkEnvironment.custom(url: nil).index)
    }

    /// Setup a text field's visibility and focus based on the segmentedNetworkEnvironment selected segment
    func setupTextFieldVisibility(textField: TextFieldSetting, visibleForIndex: Int) {
        segmentedNetworkEnvironment.segmentedControl.selectedSegmentIndexPublisher
            .map { $0 != visibleForIndex }
            .removeDuplicates()
            .handleEvents(receiveOutput: { [weak self] isHidden in
                guard let self else { return }
                if isHidden {
                    textField.textFieldControl.resignFirstResponder()
                } else if segmentedNetworkEnvironment.isVisible {
                    textField.textFieldControl.becomeFirstResponder()
                }
            })
            .assign(to: \.isHidden, on: textField)
            .store(in: &cancellables)
    }
}
