//
//  OWReportReasonCell.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import Foundation

#if NEW_API

class OWReportReasonCell: UITableViewCell {
    fileprivate var disposeBag: DisposeBag!

    fileprivate struct Metrics {
        static let identifier = "report_reason_cell_id"
        static let titleLabelIdentifier = "report_reason_cell_title_label_id"
        static let subtitleLabelIdentifier = "report_reason_cell_subtitle_label_id"
        static let checkboxIdentifier = "report_reason_cell_checkbox_id"
        static let titleFontSize: CGFloat = 15
        static let subtitleFontSize: CGFloat = 13
        static let checkboxTrailingPadding: CGFloat = 10
        static let checkboxLeadingPadding: CGFloat = 16
        static let verticalTextSpace: CGFloat = 2
        static let cellTrailingPadding: CGFloat = 9
    }

    fileprivate var subtitleHeightZeroConstraint: OWConstraint? = nil

    fileprivate lazy var viewForText: UIView = {
        let viewForText = UIView()
        return viewForText
    }()

    fileprivate lazy var lblTitle: UILabel = {
        let lblTitle = UILabel()
        return lblTitle
                .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .font(.openSans(style: .regular, of: Metrics.titleFontSize))
                .lineBreakMode(.byWordWrapping)
    }()

    fileprivate lazy var lblSubtitle: UILabel = {
        let lblSubtitle = UILabel()
        return lblSubtitle
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .font(.openSans(style: .regular, of: Metrics.subtitleFontSize))
                .numberOfLines(2)
                .lineBreakMode(.byTruncatingMiddle)
    }()

    fileprivate lazy var checkBox: OWRoundCheckBox = {
        return OWRoundCheckBox()
    }()

    fileprivate var viewModel: OWReportReasonCellViewModeling!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    override func prepareForReuse() {
        disposeBag = nil
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    func configure(with viewModel: OWReportReasonCellViewModeling) {
        self.viewModel = viewModel
        configureViews()
        setupObservers()
        applyAccessibility()
    }
}

fileprivate extension OWReportReasonCell {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        lblTitle.accessibilityIdentifier = Metrics.titleLabelIdentifier
        lblSubtitle.accessibilityIdentifier = Metrics.subtitleLabelIdentifier
        checkBox.accessibilityIdentifier = Metrics.checkboxIdentifier
    }

    func setupViews() {
        selectionStyle = .none
        self.backgroundColor = .clear

        contentView.addSubview(checkBox)
        checkBox.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Metrics.checkboxLeadingPadding)
            make.centerY.equalToSuperview()
        }

        contentView.addSubview(viewForText)
        viewForText.OWSnp.makeConstraints { make in
            make.leading.equalTo(checkBox.OWSnp.trailing).offset(Metrics.checkboxTrailingPadding)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(Metrics.cellTrailingPadding)
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }

        viewForText.addSubview(lblTitle)
        lblTitle.OWSnp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }

        viewForText.addSubview(lblSubtitle)
        lblSubtitle.OWSnp.makeConstraints { make in
            make.top.equalTo(lblTitle.OWSnp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
            subtitleHeightZeroConstraint = make.height.equalTo(0).constraint
        }
    }

    func configureViews() {
        lblTitle.text = viewModel.outputs.title
        lblSubtitle.text = viewModel.outputs.subtitle
        subtitleHeightZeroConstraint?.isActive = viewModel.outputs.subtitle.isEmpty
    }

    func setupObservers() {
        disposeBag = DisposeBag()

        viewModel.outputs.isSelected
            .bind(to: self.checkBox.setSelected)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.lblTitle.textColor = OWColorPalette.shared.color(type: .textColor1, themeStyle: currentStyle)
                self.lblSubtitle.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }
}

#endif
