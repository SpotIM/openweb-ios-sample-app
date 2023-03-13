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
    fileprivate lazy var commentTextLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.fontSize))
//            .textColor(<#T##color: UIColor##UIColor#>) // TODO: text color
    }()
    fileprivate lazy var imageIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(spNamed: "camera_icon", supportDarkMode: true)
        return imageView
    }()
    fileprivate lazy var imagePlaceholderLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.fontSize))
            .text("Camera") // TODO: string
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

        self.addSubview(commentTextLabel)
        commentTextLabel.OWSnp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(avatarImageView.OWSnp.trailing).offset(12)
        }

        self.addSubview(imageIcon)
        imageIcon.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
            make.leading.equalTo(avatarImageView.OWSnp.trailing).offset(12)
        }
        self.addSubview(imagePlaceholderLabel)
        imagePlaceholderLabel.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.leading.equalTo(imageIcon.OWSnp.trailing)
        }
    }

    func setupObservers() {
        switch(viewModel.outputs.commentType) {
        case .text(let text):
            commentTextLabel.text = text
            commentTextLabel.numberOfLines = viewModel.outputs.numberOfLines
            imageIcon.isHidden = true
            imagePlaceholderLabel.isHidden = true
            commentTextLabel.isHidden = false
        case .media:
            imageIcon.isHidden = false
            imagePlaceholderLabel.isHidden = false
            commentTextLabel.isHidden = true
        }
//        if case .text(let text) = viewModel.outputs.commentType {
//            commentTextLabel.text = text
//            commentTextLabel.numberOfLines = viewModel.outputs.numberOfLines
//            imageIcon.isHidden = true
//            imagePlaceholderLabel.isHidden = true
//            commentTextLabel.isHidden = false
//        }

        // TODO: colors
    }
}
