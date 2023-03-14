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
        let avatar = SPAvatarView().backgroundColor(.clear)
        avatar.configure(with: self.viewModel.outputs.avatarVM)
        return avatar
    }()
    fileprivate lazy var closedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(spNamed: "pendingIcon", supportDarkMode: true) // TODO: icon
        return imageView
    }()
    fileprivate lazy var emptyConversationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(spNamed: "emptyCommentsIcon", supportDarkMode: true) // TODO: icon
        return imageView
    }()
    fileprivate lazy var rightImageView: UIView = {
        return UIView()
    }()
    fileprivate lazy var textLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.fontSize))
            .numberOfLines(2)
//            .textColor(<#T##color: UIColor##UIColor#>) // TODO: text color
    }()
    fileprivate lazy var imageIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(spNamed: "camera_icon", supportDarkMode: true)
        return imageView
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

    let disposeBag = DisposeBag()
    init(viewModel: OWPreConversationCompactContentViewModeling) {
        super.init(frame: .zero)
        self.viewModel = viewModel
        
        setupViews()
        setupObservers()
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
//        avatarImageView.isHidden = true
        
        self.addSubview(rightImageView)
        rightImageView.OWSnp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.size.equalTo(Metrics.avatarSize)
        }
        rightImageView.isHidden = true

        self.addSubview(imageIcon)
        imageIcon.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
            make.leading.equalTo(rightImageView.OWSnp.trailing).offset(12)
        }
        imageIcon.isHidden = true

        self.addSubview(textLabel)
        textLabel.OWSnp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(imageIcon.OWSnp.trailing).offset(2)
        }
        textLabel.isHidden = true
    }

    func setupObservers() {
        viewModel.outputs.isSkelatonHidden
            .bind(to: skelatonView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.text
            .bind(to: textLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.isSkelatonHidden
            .map { !$0 }
            .bind(to: textLabel.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.isSkelatonHidden
            .map { !$0 }
            .bind(to: rightImageView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.showImagePlaceholder
            .map { !$0 }
            .bind(to: imageIcon.rx.isHidden)
            .disposed(by: disposeBag)

        // Show avatar/empty/close icons according to content
        viewModel.outputs.contentType
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }

                self.rightImageView.subviews.forEach { $0.removeFromSuperview() }
                var view: UIView = UIView()
                switch type {
                case .comment:
                    view = self.avatarImageView
                case .emptyConversation:
                    view = self.emptyConversationImageView
                case .closedAndEmpty:
                    view = self.closedImageView
                default:
                    break
                }
                self.rightImageView.addSubview(view)
                view.OWSnp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            })
            .disposed(by: disposeBag)

        // Set image placeholder if needed
        viewModel.outputs.showImagePlaceholder
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] showImage in
                guard let self = self else { return }
                self.imageIcon.OWSnp.updateConstraints { make in
                    make.size.equalTo(showImage ? 24 : 0)
                    make.leading.equalTo(self.rightImageView.OWSnp.trailing).offset(showImage ? 12 : 10)
                }
            })
            .disposed(by: disposeBag)

        // TODO: colors
    }
}
