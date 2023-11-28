//
//  ConversationCounterNewAPICell.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 19/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

class ConversationCounterNewAPICell: UITableViewCell {
    fileprivate struct Metrics {
        static let identifier: String = "conversation_counter_id_"
        static let lblPostIdentifier: String = "counter_post_id_"
        static let lblCommentsIdentifier: String = "counter_comments_id_"
        static let lblRepliesIdentifier: String = "counter_replies_id_"
        static let horizontalMargin: CGFloat = 20
        static let verticalMargin: CGFloat = 15
        static let cornerRadius: CGFloat = 12
    }

    fileprivate lazy var mainArea: UIView = {
        let view = UIView()
            .corner(radius: Metrics.cornerRadius)
            .backgroundColor(ColorPalette.shared.color(type: .background))
            .border(width: 1, color: ColorPalette.shared.color(type: .darkGrey))
        view.apply(shadow: .low)
        return view
    }()

    fileprivate lazy var lblPostId: UILabel = {
        let txt = NSLocalizedString("PostId", comment: "") + ": "
        return txt
            .label
            .font(FontBook.paragraphBold)
            .textColor(ColorPalette.shared.color(type: .text))
    }()

    fileprivate lazy var lblComments: UILabel = {
        let txt = NSLocalizedString("Comments", comment: "") + ": "
        return txt
            .label
            .font(FontBook.paragraph)
            .textColor(ColorPalette.shared.color(type: .darkGrey))
    }()

    fileprivate lazy var lblReplies: UILabel = {
        let txt = NSLocalizedString("Replies", comment: "") + ": "
        return txt
            .label
            .font(FontBook.paragraph)
            .textColor(ColorPalette.shared.color(type: .darkGrey))
    }()

    fileprivate var viewModel: ConversationCounterNewAPICellViewModeling!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    func configure(with viewModel: ConversationCounterNewAPICellViewModeling) {
        self.viewModel = viewModel
        configureViews()
        applyAccessibility()
    }
}
fileprivate extension ConversationCounterNewAPICell {
    func setupViews() {
        selectionStyle = .none
        self.backgroundColor = .clear

        contentView.addSubview(mainArea)
        mainArea.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalMargin)
            make.top.bottom.equalToSuperview().inset(Metrics.verticalMargin)
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
            make.bottom.equalToSuperview().inset(Metrics.verticalMargin)
        }
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier + viewModel.outputs.postId
        lblPostId.accessibilityIdentifier = Metrics.lblPostIdentifier + viewModel.outputs.postId
        lblComments.accessibilityIdentifier = Metrics.lblCommentsIdentifier + viewModel.outputs.postId
        lblReplies.accessibilityIdentifier = Metrics.lblRepliesIdentifier + viewModel.outputs.postId
    }

    func configureViews() {
        lblPostId.text = "\(NSLocalizedString("PostId", comment: "")): \(viewModel.outputs.postId)"
        lblComments.text = "\(NSLocalizedString("Comments", comment: "")): \(viewModel.outputs.comments)"
        lblReplies.text = "\(NSLocalizedString("Replies", comment: "")): \(viewModel.outputs.replies)"
    }
}
