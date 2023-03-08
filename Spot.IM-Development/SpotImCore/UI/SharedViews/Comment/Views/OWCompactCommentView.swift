//
//  OWCompactCommentView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 08/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCompactCommentView: UIView {
    fileprivate struct Metrics {
        static let avatarSize: CGFloat = 36
        static let fontSize: CGFloat = 13
    }

    fileprivate var viewModel: OWCompactCommentViewModeling!
    fileprivate lazy var avatarImageView: SPAvatarView = {
        return SPAvatarView()
            .backgroundColor(.clear)
    }()
    fileprivate lazy var commentLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.fontSize))
//            .textColor(<#T##color: UIColor##UIColor#>) // TODO: text color
    }()

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    func configure(with viewModel: OWCompactCommentViewModeling) {
        self.viewModel = viewModel
        avatarImageView.configure(with: viewModel.outputs.avatarVM)
        setupObservers() // ?
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCompactCommentView {
    func setupViews() {
        self.addSubview(avatarImageView)
        avatarImageView.OWSnp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.size.equalTo(Metrics.avatarSize)
        }

        self.addSubview(commentLabel)
        commentLabel.OWSnp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(avatarImageView.OWSnp.trailing).offset(12)
        }
    }

    func setupObservers() {
        if case .text(let text) = viewModel.outputs.commentType {
            commentLabel.text = text
            commentLabel.numberOfLines = viewModel.outputs.numberOfLines
        }

        // TODO: colors
    }
}
