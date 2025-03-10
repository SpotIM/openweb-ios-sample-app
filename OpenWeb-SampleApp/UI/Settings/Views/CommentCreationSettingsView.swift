//
//  CommentCreationSettingsView.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift

class CommentCreationSettingsView: UIView {

    private struct Metrics {
        static let identifier = "comment_creation_settings_view_id"
        static let segmentedStyleModeIdentifier = "custom_style_mode"
        static let switchAccessoryViewIdentifier = "accessory_view"
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

    private lazy var segmentedStyleMode: SegmentedControlSetting = {
        let title = viewModel.outputs.styleModeTitle
        let items = viewModel.outputs.styleModeSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedStyleModeIdentifier,
                                       items: items)
    }()

    private lazy var segmentedAccessoryView: SegmentedControlSetting = {
        let title = viewModel.outputs.accessoryViewTitle
        let items = viewModel.outputs.accessoryViewSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.switchAccessoryViewIdentifier,
                                       items: items)
    }()

    private let viewModel: CommentCreationSettingsViewModeling
    private let disposeBag = DisposeBag()

    init(viewModel: CommentCreationSettingsViewModeling) {
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

private extension CommentCreationSettingsView {
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
        stackView.addArrangedSubview(segmentedStyleMode)
        stackView.addArrangedSubview(segmentedAccessoryView)
    }

    func setupObservers() {
        viewModel.outputs.styleModeIndex
            .bind(to: segmentedStyleMode.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        segmentedStyleMode.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.customStyleModeSelectedIndex)
            .disposed(by: disposeBag)

        viewModel.outputs.accessoryViewIndex
            .bind(to: segmentedAccessoryView.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        segmentedAccessoryView.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.accessoryViewSelectedIndex)
            .disposed(by: disposeBag)

        viewModel.outputs.hideAccessoryViewOptions
            .bind(to: segmentedAccessoryView.rx.isHidden)
            .disposed(by: disposeBag)
    }
}
