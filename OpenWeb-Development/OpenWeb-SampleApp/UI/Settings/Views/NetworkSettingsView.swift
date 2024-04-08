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

    fileprivate struct Metrics {
        static let identifier = "network_settings_view_id"
        static let segmentedNetworkEnvironmentIdentifier = "network_environment"
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

    fileprivate lazy var segmentedNetworkEnvironment: SegmentedControlSetting = {
        let title = viewModel.outputs.networkEnvironmentTitle
        let items = viewModel.outputs.networkEnvironmentSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedNetworkEnvironmentIdentifier,
                                       items: items)
    }()

    fileprivate let viewModel: NetworkSettingsViewModeling
    fileprivate let disposeBag = DisposeBag()

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

fileprivate extension NetworkSettingsView {
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
        viewModel.outputs.networkEnvironmentIndex
            .bind(to: segmentedNetworkEnvironment.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        segmentedNetworkEnvironment.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.networkEnvironmentSelectedIndex)
            .disposed(by: disposeBag)
    }
}
