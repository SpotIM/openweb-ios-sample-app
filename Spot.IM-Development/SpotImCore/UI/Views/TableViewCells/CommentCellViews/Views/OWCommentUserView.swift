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
    
    fileprivate var viewModel: OWCommentUserViewModeling!
    fileprivate var disposeBag: DisposeBag!
        
    private let avatarImageView: SPAvatarView = SPAvatarView()
    private let userNameView: UserNameView = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    func configure(with model: CommentViewModel) {
        self.viewModel = model.commentUserVM
        disposeBag = DisposeBag()
        
        avatarImageView.configure(with: viewModel.outputs.avatarVM)
        
        userNameView.configure(with: viewModel.outputs.userNameVM)
        
        updateUserView(with: model)
    }
    
    func setDelegate(_ delegate: SPCommentCellDelegate?) {
        guard let delegate = delegate else { return }
        self.viewModel.inputs.setDelegate(delegate)
    }
    
    private func setupUI() {
        addSubviews(avatarImageView, userNameView)
        configureAvatarView()
        configureUserNameView()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        userNameView.updateColorsAccordingToStyle()
        avatarImageView.updateColorsAccordingToStyle()
    }
    
    private func configureAvatarView() {
        avatarImageView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(userNameView.OWSnp.leading).offset(-Metrics.avatarImageViewTrailingOffset)
            make.top.equalTo(userNameView)
            make.size.equalTo(Metrics.avatarSideSize)
        }
    }
    
    private func configureUserNameView() {
        userNameView.OWSnp.makeConstraints { make in
            make.trailing.top.equalToSuperview()
            make.height.equalTo(Metrics.userViewCollapsedHeight)
        }
    }
    
    private func updateUserView(with dataModel: CommentViewModel) {
        userNameView.setDeletedOrReported(isDeleted: dataModel.isDeleted, isReported: dataModel.isReported)
        
        userNameView.setUserName(
            dataModel.displayName,
            badgeTitle: dataModel.badgeTitle,
            contentType: dataModel.replyingToCommentId == nil ? .comment : .reply,
            isDeleted: dataModel.isDeletedOrReported(),
            isOneLine: dataModel.isUsernameOneRow())
        userNameView.setMoreButton(hidden: dataModel.isDeletedOrReported())
        userNameView.setSubtitle(
            dataModel.replyingToDisplayName?.isEmpty ?? true
                ? ""
                : LocalizationManager.localizedString(key: "To") + " \(dataModel.replyingToDisplayName!)"
        )
        userNameView.setDate(
            dataModel.replyingToDisplayName?.isEmpty ?? true
                ? dataModel.timestamp
                : " · ".appending(dataModel.timestamp ?? "")
        )
        let userViewHeight = dataModel.usernameViewHeight()
        userNameView.OWSnp.updateConstraints { make in
            make.height.equalTo(userViewHeight)
        }
    }
}
