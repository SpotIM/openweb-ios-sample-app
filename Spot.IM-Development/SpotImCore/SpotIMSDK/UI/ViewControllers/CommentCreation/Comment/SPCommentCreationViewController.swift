//
//  SPCommentCreationViewController.swift
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

    override func viewDidLoad() {
        super.viewDidLoad()
        topContainerView.bringSubviewToFront(closeButton)
    }

    internal override func updateModelData() {
        setupHeaderComponentsIfNeeded()
        configureModelHandlers()
        if shouldShowArticleView(for: model?.dataModel) {
            topContainerStack.insertArrangedSubview(articleView, at: 1)
            if #available(iOS 11.0, *) {
                topContainerStack.setCustomSpacing(16, after: commentingOnLabel)
            }

            articleView.setTitle(model?.dataModel.articleTitle)
            articleView.setImage(with: model?.dataModel.articleImageUrl)
            articleView.setAuthor(model?.dataModel.authorName)

            articleView.layout {
                $0.height.equal(to: 85.0)
                $0.width.equal(to: topContainerStack.widthAnchor)
            }
            commentingOnLabel.text = NSLocalizedString(
                "Commenting on",
                comment: "commenting on title"
            )
        } else {
            emptyArticleBottomConstarint?.isActive = true
            commentingOnLabel.text = NSLocalizedString(
                "Add a Comment",
                comment: "commenting on title"
            )
        }

        updateTextInputContainer(with: .comment)
        updateAvatar()
    }
    
    private func setupHeaderComponentsIfNeeded() {
        guard commentingOnLabel.superview == nil, closeButton.superview == nil else {
            return
        }

        let commentingContainer = UIView.init()
        commentingContainer.backgroundColor = .spBackground0
        commentingContainer.addSubview(commentingOnLabel)

        topContainerStack.insertArrangedSubview(commentingContainer, at: 0)

        topContainerView.addSubview(closeButton)
        
        commentingOnLabel.font = UIFont.preferred(style: .regular, of: 16.0)
        commentingOnLabel.textColor = .spForeground4
        commentingOnLabel.text = NSLocalizedString(
            "Commenting on",
            comment: "commenting on title"
        )
        commentingOnLabel.backgroundColor = commentingContainer.backgroundColor
        commentingOnLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        commentingOnLabel.layout {
            $0.top.equal(to: commentingContainer.topAnchor, offsetBy: 25)
            $0.leading.equal(to: commentingContainer.leadingAnchor, offsetBy: 16)
            $0.trailing.equal(to: commentingContainer.trailingAnchor)
            $0.bottom.equal(to: commentingContainer.bottomAnchor, offsetBy: -16)
        }
        
        closeButton.setImage(UIImage(spNamed: "closeCrossIcon"), for: .normal)
        closeButton.backgroundColor = .spBackground0
        closeButton.layout {
            $0.centerY.equal(to: topContainerView.topAnchor, offsetBy: 35)
            $0.trailing.equal(to: topContainerView.trailingAnchor, offsetBy: -5.0)
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

    private func shouldShowArticleView(for model: SPCommentCreationDTO?) -> Bool {
        model?.articleTitle != nil || model?.articleImageUrl != nil
    }
    
}
