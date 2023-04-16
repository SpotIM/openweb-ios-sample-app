//
//  OWReportReasonCell.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import Foundation

class OWReportReasonCell: UITableViewCell {
    fileprivate struct Metrics {
        static let identifier = "pre_conversation_footer_id"
        static let titleFontSize: CGFloat = 15
        static let subtitleFontSize: CGFloat = 13
        static let checkboxTrailingPadding: CGFloat = 10
        static let checkboxLeadingPadding: CGFloat = 16
        static let horizontalSpace: CGFloat = 2
    }

    fileprivate lazy var verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = Metrics.checkboxTrailingPadding
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        return stack
    }()

    fileprivate lazy var horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = Metrics.horizontalSpace
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    fileprivate lazy var lblTitle: UILabel = {
        let lblTitle = UILabel()
        return lblTitle
                .textColor(OWColorPalette.shared.color(type: .compactText, themeStyle: .light))
                .font(.openSans(style: .regular, of: Metrics.titleFontSize))
    }()

    fileprivate lazy var lblSubtitle: UILabel = {
        let lblSubtitle = UILabel()
        return lblSubtitle
            .textColor(OWColorPalette.shared.color(type: .foreground1Color, themeStyle: .light))
                .font(.openSans(style: .regular, of: Metrics.subtitleFontSize))
    }()

    fileprivate var viewModel: OWReportReasonCellViewModeling!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    func configure(with viewModel: OWReportReasonCellViewModeling) {
        self.viewModel = viewModel
        configureViews()
    }
}

fileprivate extension OWReportReasonCell {
    func setupViews() {
        selectionStyle = .none
        self.backgroundColor = .clear

        contentView.addSubview(verticalStack)
        verticalStack.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.checkboxLeadingPadding)
            make.top.bottom.trailing.equalToSuperview()
        }

        verticalStack.addArrangedSubview(horizontalStack)

        horizontalStack.addArrangedSubview(lblTitle)
        horizontalStack.addArrangedSubview(lblSubtitle)
    }

    func configureViews() {
        lblTitle.text = viewModel.outputs.title
        lblSubtitle.text = viewModel.outputs.subtitle
    }
}
