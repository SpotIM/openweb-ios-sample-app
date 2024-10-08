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

    fileprivate struct Metrics {
        static let identifier = "sample_app_settings_view_id"
        static let deeplinkIdentifier = "deeplink_selection_id"
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

    fileprivate lazy var segmentedDeeplink: SegmentedControlSetting = {
        let title = viewModel.outputs.appDeeplinkTitle
        let items = viewModel.outputs.appDeeplinkSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.deeplinkIdentifier,
                                       items: items)
    }()

    fileprivate let viewModel: SampleAppSettingsViewModeling
    fileprivate let disposeBag = DisposeBag()

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

fileprivate extension SampleAppSettingsView {
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
        stackView.addArrangedSubview(segmentedDeeplink)
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
    }
}
