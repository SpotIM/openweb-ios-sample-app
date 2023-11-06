//
//  OWAppealCell.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 06/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import Foundation

class OWAppealCell: UITableViewCell {
    fileprivate var disposeBag: DisposeBag!

    fileprivate struct Metrics {
        static let identifier = "commenter_appeal_cell_id"
        static let titleLabelIdentifier = "commenter_appeal_cell_title_label_id"
        static let checkboxIdentifier = "commenter_appeal_cell_checkbox_id"
        static let checkboxTrailingPadding: CGFloat = 10
        static let horizontalPadding: CGFloat = 16
        static let cellMinHeight: CGFloat = 60
    }

    fileprivate lazy var viewForText: UIView = {
        let viewForText = UIView()
        return viewForText
    }()

    fileprivate lazy var lblTitle: UILabel = {
        return UILabel()
            .textColor(OWColorPalette.shared.color(type: .textColor4, themeStyle: .light))
            .font(OWFontBook.shared.font(typography: .bodyText))
            .lineBreakMode(.byWordWrapping)
    }()

    fileprivate lazy var checkBox: OWRoundCheckBox = {
        return OWRoundCheckBox()
    }()

    fileprivate var viewModel: OWAppealCellViewModeling!

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

    func configure(with viewModel: OWAppealCellViewModeling) {
        self.viewModel = viewModel
        configureViews()
        setupObservers()
        applyAccessibility()
    }
}

fileprivate extension OWAppealCell {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        lblTitle.accessibilityIdentifier = Metrics.titleLabelIdentifier
        checkBox.accessibilityIdentifier = Metrics.checkboxIdentifier
    }

    func setupViews() {
        selectionStyle = .none
        self.backgroundColor = .clear

        contentView.OWSnp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(Metrics.cellMinHeight)
            make.edges.equalToSuperview()
        }

        contentView.addSubview(checkBox)
        checkBox.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Metrics.horizontalPadding)
            make.centerY.equalToSuperview()
        }

        contentView.addSubview(lblTitle)
        lblTitle.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(checkBox.OWSnp.trailing).offset(Metrics.checkboxTrailingPadding)
            make.trailing.equalToSuperview().inset(Metrics.horizontalPadding)
        }
    }

    func configureViews() {
        lblTitle.text = viewModel.outputs.title
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
                self.lblTitle.textColor = OWColorPalette.shared.color(type: .textColor4, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.lblTitle.font = OWFontBook.shared.font(typography: .bodyText)
            })
            .disposed(by: disposeBag)
    }
}

