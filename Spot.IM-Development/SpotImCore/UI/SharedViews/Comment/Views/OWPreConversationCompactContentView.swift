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

class OWPreConversationCompactContentView: UIView {
    fileprivate struct Metrics {
        static let avatarSize: CGFloat = 36
        static let fontSize: CGFloat = 13
    }

    fileprivate var viewModel: OWPreConversationCompactContentViewModeling!
    fileprivate lazy var avatarImageView: SPAvatarView = {
        return SPAvatarView()
            .backgroundColor(.clear)
    }()
    fileprivate lazy var textLabel: UILabel = {
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
    fileprivate lazy var skelatonView: OWSkeletonShimmeringView = {
        let view = OWSkeletonShimmeringView()

        view.addSubview(avatarSkeleton)
        avatarSkeleton.OWSnp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.size.equalTo(Metrics.avatarSize)
        }
        let firstLine = messageLinesSkeleton[0]
        view.addSubview(firstLine)
        firstLine.OWSnp.makeConstraints { make in
            make.top.trailing.equalToSuperview().offset(5)
            make.height.equalTo(8)
            make.leading.equalTo(avatarSkeleton.OWSnp.trailing).offset(12)
        }
        let secondLine = messageLinesSkeleton[1]
        view.addSubview(secondLine)
        secondLine.OWSnp.makeConstraints { make in
            make.top.equalTo(firstLine.OWSnp.bottom).offset(8)
            make.height.equalTo(8)
            make.leading.equalTo(avatarSkeleton.OWSnp.trailing).offset(12)
            make.trailing.equalToSuperview()
        }
        return view
    }()
    fileprivate lazy var avatarSkeleton: UIView = {
        let view = UIView()
            .corner(radius: Metrics.avatarSize / 2)
            .backgroundColor(OWColorPalette.shared.color(type: .skeletonColor,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))

        return view
    }()
    fileprivate lazy var messageLinesSkeleton: [UIView] = {
        let color = OWColorPalette.shared.color(type: .skeletonColor,
                                                     themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)

        let numOfLines = 2 //TODO
        let views = (0 ..< numOfLines).map { _ in
            return UIView().backgroundColor(color)
        }

        return views
    }()

    init(viewModel: OWPreConversationCompactContentViewModeling) {
        super.init(frame: .zero)
        self.viewModel = viewModel
        setupViews()
    }

//    func configure(with viewModel: OWPreConversationCompactContentViewModeling) {
//        self.viewModel = viewModel
//        avatarImageView.configure(with: viewModel.outputs.avatarVM)
//        setupObservers() // ?
//    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWPreConversationCompactContentView {
    func setupViews() {
        self.addSubview(skelatonView)
        skelatonView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        skelatonView.addSkeletonShimmering()
        
//        self.addSubview(avatarImageView)
//        avatarImageView.OWSnp.makeConstraints { make in
//            make.leading.top.bottom.equalToSuperview()
//            make.size.equalTo(Metrics.avatarSize)
//        }
//
//        self.addSubview(textLabel)
//        textLabel.OWSnp.makeConstraints { make in
//            make.top.bottom.trailing.equalToSuperview()
//            make.leading.equalTo(avatarImageView.OWSnp.trailing).offset(12)
//        }
//
//        self.addSubview(imageIcon)
//        imageIcon.OWSnp.makeConstraints { make in
//            make.centerY.equalToSuperview()
//            make.size.equalTo(24)
//            make.leading.equalTo(avatarImageView.OWSnp.trailing).offset(12)
//        }
//        self.addSubview(imagePlaceholderLabel)
//        imagePlaceholderLabel.OWSnp.makeConstraints { make in
//            make.top.bottom.equalToSuperview()
//            make.trailing.lessThanOrEqualToSuperview()
//            make.leading.equalTo(imageIcon.OWSnp.trailing)
//        }
    }

    func setupObservers() {
//        switch(viewModel.outputs.commentType) {
//        case .text(let text):
//            commentTextLabel.text = text
//            commentTextLabel.numberOfLines = viewModel.outputs.numberOfLines
//            imageIcon.isHidden = true
//            imagePlaceholderLabel.isHidden = true
//            textLabel.isHidden = false
//        case .media:
//            imageIcon.isHidden = false
//            imagePlaceholderLabel.isHidden = false
//            textLabel.isHidden = true
//        }
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
