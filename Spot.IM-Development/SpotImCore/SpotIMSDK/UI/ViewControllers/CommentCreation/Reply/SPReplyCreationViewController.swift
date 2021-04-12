//
//  SPReplyCreationViewController.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/7/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

final class SPReplyCreationViewController: CommentReplyViewController<SPReplyCreationModel> {
    
    private lazy var commentHeaderView = SPCommentHeaderView()
    
    // Handle dark mode \ light mode change
    override func updateColorsAccordingToStyle() {
        super.updateColorsAccordingToStyle()
        commentHeaderView.updateColorsAccordingToStyle()
        updateAvatar() // placeholder is adjusted to theme
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let state = UIApplication.shared.applicationState
        if #available(iOS 12.0, *) {
            if previousTraitCollection?.userInterfaceStyle != self.traitCollection.userInterfaceStyle {
                // traitCollectionDidChange() is called multiple times, see: https://stackoverflow.com/a/63380259/583425
                if state != .background {
                    self.updateColorsAccordingToStyle()
                }
            }
        } else {
            if state != .background {
                self.updateColorsAccordingToStyle()
            }
        }
    }
    
    internal override func updateModelData() {
        configureModelHandlers()
        topContainerStack.insertArrangedSubview(commentHeaderView, at: 0)
        commentHeaderView.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        commentHeaderView.configure(
            with: CommentDataModel(
                author: model?.dataModel.authorName,
                comment: model?.dataModel.comment)
        )

        commentHeaderView.layout {
            $0.height.equal(to: 111)
            $0.width.equal(to: topContainerStack.widthAnchor)
        }

        updateTextInputContainer(with: .reply)
        updateAvatar()
    }
    
    private func configureModelHandlers() {
        model?.postCompletionHandler = { [weak self] reply in
            guard let self = self else { return }

            if reply.status == .block || !reply.published {
                self.delegate?.commentReplyDidBlock(with: reply.content?.first?.text)
            } else {
                self.delegate?.commentReplyDidCreate(reply)
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
