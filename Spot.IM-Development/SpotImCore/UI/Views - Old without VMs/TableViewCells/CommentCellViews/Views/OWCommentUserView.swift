//
//  OWCommentUserView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 20/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class OWCommentUserView: OWBaseView {

    fileprivate struct Metrics {
        static let topOffset: CGFloat = 14.0
        static let topCollapsedOffset: CGFloat = 38.0
        static let leadingOffset: CGFloat = 16.0
        static let userViewCollapsedHeight: CGFloat = 44.0
        static let userViewExpandedHeight: CGFloat = 69.0
        static let avatarSideSize: CGFloat = 39.0
        static let avatarImageViewTrailingOffset: CGFloat = 11.0
    }

    fileprivate var viewModel: SPCommentUserViewModeling!
    fileprivate var disposeBag: DisposeBag!

    private let avatarImageView: SPAvatarView = SPAvatarView()
    private let userNameView: UserNameView = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    func configure(with model: CommentViewModel) {
        self.viewModel = model.commentUserVM
        disposeBag = DisposeBag()

        avatarImageView.configure(with: viewModel.outputs.avatarVM)
        userNameView.configure(with: viewModel.outputs.userNameVM)

        let userViewHeight = model.usernameViewHeight()
        userNameView.OWSnp.updateConstraints { make in
            make.height.equalTo(userViewHeight)
        }
    }

    func setDelegate(_ delegate: SPCommentCellDelegate?) {
        guard let delegate = delegate,
              let vm = self.viewModel
        else { return }
        vm.inputs.setDelegate(delegate)
    }

    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        userNameView.updateColorsAccordingToStyle()
        avatarImageView.updateColorsAccordingToStyle()
    }

    func prepareForReuse() {
        avatarImageView.prepareForReuse()
    }
}

fileprivate extension OWCommentUserView {
    func setupViews() {
        addSubviews(avatarImageView, userNameView)

        // Setup avatar
        avatarImageView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(userNameView.OWSnp.leading).offset(-Metrics.avatarImageViewTrailingOffset)
            make.top.equalTo(userNameView)
            make.size.equalTo(Metrics.avatarSideSize)
        }

        // Setup user name view
        userNameView.OWSnp.makeConstraints { make in
            make.trailing.top.equalToSuperview()
            make.height.equalTo(Metrics.userViewCollapsedHeight)
        }
    }
}
