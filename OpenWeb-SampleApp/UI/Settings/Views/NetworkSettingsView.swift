//
//  NetworkSettingsView.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 21/02/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift

class NetworkSettingsView: UIView {

    private struct Metrics {
        static let identifier = "network_settings_view_id"
        static let segmentedNetworkEnvironmentIdentifier = "network_environment"
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

    private lazy var customURLTextField: TextFieldSetting = {
        var customURLTextField = TextFieldSetting(title: viewModel.outputs.networkEnvironmentCustomTitle,
                                                  placeholder: "Example: ntfs",
                                                  accessibilityPrefixId: Metrics.identifier,
                                                  font: FontBook.helperLight)
        return customURLTextField
    }()

    private let viewModel: NetworkSettingsViewModeling
    private let disposeBag = DisposeBag()

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
        stackView.addArrangedSubview(segmentedNetworkEnvironment)
    }

    func setupObservers() {
        viewModel.outputs.networkEnvironment
            .map { $0.index }
            .bind(to: segmentedNetworkEnvironment.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        viewModel.outputs.networkEnvironment
            .map {
                switch $0 {
                case .custom(let path):
                    return path
                default:
                    return nil
                }
            }
            .unwrap()
            .bind(to: customURLTextField.rx.textFieldText)
            .disposed(by: disposeBag)

        // Custom network environment
        Observable.combineLatest(segmentedNetworkEnvironment.rx.selectedSegmentIndex, customURLTextField.rx.textFieldText.unwrap())
            .filter { $0.0 == OWNetworkEnvironment.custom(path: nil).index }
            .map { OWNetworkEnvironment(from: $0.0, path: $0.1) }
            .bind(to: viewModel.inputs.networkEnvironmentSelected)
            .disposed(by: disposeBag)

        // Non custom network environment
        segmentedNetworkEnvironment.rx.selectedSegmentIndex
            .filter { $0 != OWNetworkEnvironment.custom(path: nil).index }
            .map { OWNetworkEnvironment(from: $0) }
            .bind(to: viewModel.inputs.networkEnvironmentSelected)
            .disposed(by: disposeBag)

        segmentedNetworkEnvironment.rx.selectedSegmentIndex
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                guard let self else { return }
                if index == OWNetworkEnvironment.custom(path: nil).index {
                    stackView.addArrangedSubview(customURLTextField)
                } else {
                    stackView.removeArrangedSubview(customURLTextField)
                }
            })
            .disposed(by: disposeBag)
    }
}
