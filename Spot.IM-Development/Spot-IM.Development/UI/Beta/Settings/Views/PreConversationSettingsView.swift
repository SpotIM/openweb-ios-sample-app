//
//  PreConversationSettingsView.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 27/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

#if NEW_API

class PreConversationSettingsView: UIView {

    fileprivate struct Metrics {
        static let identifier = "pre_conversation_settings_view_id"
        static let segmentedCustomStyleModeIdentifier = "custom_style_mode"
        static let pickerCustomStyleLinesIdentifier = "custom_style_lines"
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

    fileprivate lazy var segmentedCustomStyleMode: SegmentedControlSetting = {
        let title = viewModel.outputs.customStyleModeTitle
        let items = viewModel.outputs.customStyleModeSettings

        return SegmentedControlSetting(title: title,
                                       accessibilityPrefixId: Metrics.segmentedCustomStyleModeIdentifier,
                                       items: items)
    }()

    fileprivate lazy var pickerCustomStyleLines: PickerSetting = {
        let title = viewModel.outputs.customStyleLinesTitle
        let picker = PickerSetting(title: title,
                                   accessibilityPrefixId: Metrics.pickerCustomStyleLinesIdentifier,
                                   items: viewModel.outputs.customStyleLinesSettings)
        return picker
    }()

    fileprivate let viewModel: PreConversationSettingsViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: PreConversationSettingsViewModeling) {
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

fileprivate extension PreConversationSettingsView {
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
        stackView.addArrangedSubview(segmentedCustomStyleMode)
        stackView.addArrangedSubview(pickerCustomStyleLines)
    }

    func setupObservers() {
        viewModel.outputs.customStyleModeIndex
            .bind(to: segmentedCustomStyleMode.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)

        segmentedCustomStyleMode.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.customStyleModeSelectedIndex)
            .disposed(by: disposeBag)

        viewModel.outputs.customStyleLines
            .map { [weak self] in
                guard let self = self, let index = self.viewModel.outputs.customStyleLinesSettings.firstIndex(of: String($0))
                else { return nil }
                return (index, 0)
            }
            .unwrap()
            .bind(to: pickerCustomStyleLines.rx.setSelectedPickerIndex)
            .disposed(by: disposeBag)

        pickerCustomStyleLines.rx.selectedPickerIndex
            .map { [weak self] in
                guard let self = self else { return nil }
                return Int(self.viewModel.outputs.customStyleLinesSettings[$0.row])
            }
            .unwrap()
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.customStyleModeSelectedLines)
            .disposed(by: disposeBag)

        viewModel.outputs.showCustomStyleLines
            .map { !$0 }
            .bind(to: pickerCustomStyleLines.rx.isHidden)
            .disposed(by: disposeBag)
    }
}

#endif
