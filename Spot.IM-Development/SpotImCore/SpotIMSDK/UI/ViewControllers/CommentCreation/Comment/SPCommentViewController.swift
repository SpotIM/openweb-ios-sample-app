//
//  SPCommentViewController.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/7/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

final class SPCommentCreationViewController: CommentReplyViewController<SPCommentCreationModel> {
    
    private lazy var articleView: SPArticleHeader = SPArticleHeader()
    private let commentingOnLabel: BaseLabel = .init()
    private let closeButton: BaseButton = .init()

    private var emptyArticleBottomConstarint: NSLayoutConstraint?
    private var filledArticleBottomConstarint: NSLayoutConstraint?

    internal override func updateModelData() {
        setupHeaderComponentsIfNeeded()
        configureModelHandlers()
        if model?.dataModel.articleTitle != nil || model?.dataModel.articleImageUrl != nil {
            topContainerView.addSubview(articleView)
            articleView.setTitle(model?.dataModel.articleTitle)
            articleView.setImage(with: model?.dataModel.articleImageUrl)
            articleView.setAuthor(model?.dataModel.authorName)
            articleView.layout {
                filledArticleBottomConstarint = $0.top.equal(to: commentingOnLabel.bottomAnchor, offsetBy: 16.0)
                $0.leading.equal(to: topContainerView.leadingAnchor)
                $0.trailing.equal(to: topContainerView.trailingAnchor)
                $0.bottom.equal(to: topContainerView.bottomAnchor)
                $0.height.equal(to: 85.0)
            }
        } else {
            emptyArticleBottomConstarint?.isActive = true
        }
        textInputViewContainer.configureCommentType(
            .comment,
            avatar: SPUserSessionHolder.session.user?.imageURL(size: navigationAvatarSize)
        )
        textInputViewContainer.updateText(model?.commentText ?? "")
        
        model?.fetchNavigationAvatar { [weak self] image, _ in
            guard
                let self = self,
                let image = image
                else { return }
            
            self.updateUserIcon(image: image)
        }
    }
    
    private func setupHeaderComponentsIfNeeded() {
        guard commentingOnLabel.superview == nil, closeButton.superview == nil else {
            return
        }
        topContainerView.addSubviews(commentingOnLabel, closeButton)
        
        commentingOnLabel.font = UIFont.preferred(style: .regular, of: 16.0)
        commentingOnLabel.textColor = .spForeground4
        commentingOnLabel.text = LocalizationManager.localizedString(key: "Commenting on")
        commentingOnLabel.backgroundColor = .spBackground0
        commentingOnLabel.layout {
            $0.top.equal(to: topContainerView.topAnchor, offsetBy: 25.0)
            $0.leading.equal(to: topContainerView.leadingAnchor, offsetBy: 12.0)
            $0.trailing.lessThanOrEqual(to: closeButton.leadingAnchor)
            emptyArticleBottomConstarint = $0.bottom.equal(to: topContainerView.bottomAnchor,
                                                           offsetBy: 16.0, isActive: false)
        }
        
        closeButton.setImage(UIImage(spNamed: "closeCrossIcon"), for: .normal)
        closeButton.backgroundColor = .spBackground0
        closeButton.layout {
            $0.centerY.equal(to: commentingOnLabel.centerYAnchor)
            $0.trailing.equal(to: topContainerView.trailingAnchor, offsetBy: -6.0)
            $0.width.equal(to: 40.0)
            $0.height.equal(to: 40.0)
        }
        
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }

    private func configureModelHandlers() {
        model?.postCompletionHandler = { [weak self] comment in
            guard let self = self else { return }

            if comment.status == .block || !comment.published {
                self.delegate?.commentReplyDidBlock(with: comment.content?.first?.text)
            } else {
                self.delegate?.commentReplyDidCreate(comment)
            }
            self.dismissController()
        }
        model?.postErrorHandler = { [weak self] error in
            guard let self = self else { return }

            self.hideLoader()
            self.showAlert(
                title: LocalizationManager.localizedString(key: "Oops..."),
                message: error.localizedDescription
            )
        }
    }
    
}
