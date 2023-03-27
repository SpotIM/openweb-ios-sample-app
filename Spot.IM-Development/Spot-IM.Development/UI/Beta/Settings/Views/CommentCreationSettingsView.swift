//
//  CommentCreationSettingsView.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

#if NEW_API

class CommentCreationSettingsView: UIView {

    fileprivate struct Metrics {
        static let identifier = "comment_creation_settings_view_id"
        static let segmentedCustomStyleModeIdentifier = "custom_style_mode"
        static let verticalOffset: CGFloat = 40
        static let horizontalOffset: CGFloat = 10
    }

    fileprivate lazy var titleLabel: UILabel = {
        var titleLabel = UILabel()
        titleLabel.text = viewModel.outputs.title
        titleLabel.font = FontBook.secondaryHeadingBold
        return titleLabel
    }()

    fileprivate lazy var segmentedCustomStyleMode: SegmentedControlSetting = {
        let title = viewModel.outputs.customStyleModeTitle
        let items = viewModel.outputs.customStyleModeSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedCustomStyleModeIdentifier,
                                       items: items)
    }()

    fileprivate let viewModel: CommentCreationSettingsViewModeling
    fileprivate let disposeBag = DisposeBag()

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

fileprivate extension CommentCreationSettingsView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
        self.backgroundColor = ColorPalette.shared.color(type: .background)

        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Metrics.horizontalOffset)
            make.top.equalTo(self.snp.top)
        }

        self.addSubview(segmentedCustomStyleMode)
        segmentedCustomStyleMode.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Metrics.horizontalOffset)
            make.top.equalTo(titleLabel.snp.bottom).offset(Metrics.verticalOffset)
            make.bottom.equalTo(self.snp.bottom)
        }
    }

    func setupObservers() {
        viewModel.outputs.customStyleModeIndex
            .bind(to: segmentedCustomStyleMode.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        segmentedCustomStyleMode.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.customStyleModeSelectedIndex)
            .disposed(by: disposeBag)
    }
}

#endif
