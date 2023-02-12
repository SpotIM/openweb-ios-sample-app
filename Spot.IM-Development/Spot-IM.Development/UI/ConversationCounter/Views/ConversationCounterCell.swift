//
//  ConversationCounterCell.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 23/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

class ConversationCounterCell: UITableViewCell {
    fileprivate struct Metrics {
        static let horizontalMargin: CGFloat = 20
        static let verticalMargin: CGFloat = 15
        static let cornerRadius: CGFloat = 12
        static let mainAreaHeight: CGFloat = 120
    }

    fileprivate lazy var mainArea: UIView = {
        let view = UIView()
            .corner(radius: Metrics.cornerRadius)
            .backgroundColor(ColorPalette.shared.color(type: .basicGrey))
        view.apply(shadow: .medium)
        return view
    }()

    fileprivate lazy var lblPostId: UILabel = {
        let txt = NSLocalizedString("PostId", comment: "") + ": "
        return txt
            .label
            .font(FontBook.secondaryHeading)
            .textColor(ColorPalette.shared.color(type: .blackish))
    }()

    fileprivate lazy var lblComments: UILabel = {
        let txt = NSLocalizedString("Comments", comment: "") + ": "
        return txt
            .label
            .font(FontBook.secondaryHeading)
            .textColor(ColorPalette.shared.color(type: .blue))
    }()

    fileprivate lazy var lblReplies: UILabel = {
        let txt = NSLocalizedString("Replies", comment: "") + ": "
        return txt
            .label
            .font(FontBook.secondaryHeading)
            .textColor(ColorPalette.shared.color(type: .blue))
    }()

    fileprivate var viewModel: ConversationCounterCellViewModeling!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    func configure(with viewModel: ConversationCounterCellViewModeling) {
        self.viewModel = viewModel
        configureViews()
    }
}
fileprivate extension ConversationCounterCell {
    func setupViews() {
        selectionStyle = .none
        self.backgroundColor = .clear

        contentView.addSubview(mainArea)
        mainArea.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalMargin)
            make.top.bottom.equalToSuperview().inset(Metrics.verticalMargin)
            make.height.equalTo(Metrics.mainAreaHeight)
        }

        mainArea.addSubview(lblPostId)
        lblPostId.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.horizontalMargin)
            make.top.equalToSuperview().offset(Metrics.verticalMargin)
        }

        mainArea.addSubview(lblComments)
        lblComments.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.horizontalMargin)
            make.top.equalTo(lblPostId.snp.bottom).offset(Metrics.verticalMargin/2)
        }

        mainArea.addSubview(lblReplies)
        lblReplies.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.horizontalMargin)
            make.top.equalTo(lblComments.snp.bottom).offset(Metrics.verticalMargin/2)
        }
    }

    func configureViews() {
        lblPostId.text = "\(NSLocalizedString("PostId", comment: "")): \(viewModel.outputs.postId)"
        lblComments.text = "\(NSLocalizedString("Comments", comment: "")): \(viewModel.outputs.comments)"
        lblReplies.text = "\(NSLocalizedString("Replies", comment: "")): \(viewModel.outputs.replies)"
    }
}
