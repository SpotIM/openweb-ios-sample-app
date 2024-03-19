//
//  SPReplyCreationViewController.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/7/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

final class SPReplyCreationViewController: SPBaseCommentCreationViewController<SPReplyCreationModel> {

    private lazy var commentHeaderView = SPCommentReplyHeaderView()
    private lazy var commentNewHeaderView = SPCommentCreationNewHeaderView()

    // Handle dark mode \ light mode change
    override func updateColorsAccordingToStyle() {
        super.updateColorsAccordingToStyle()
        if SpotIm.enableCreateCommentNewDesign {
            commentNewHeaderView.updateColorsAccordingToStyle()
        } else {
            commentHeaderView.updateColorsAccordingToStyle()
        }
        updateAvatar() // placeholder is adjusted to theme
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
           self,
           selector: #selector(overrideUserInterfaceStyleDidChange),
           name: Notification.Name(SpotIm.OVERRIDE_USER_INTERFACE_STYLE_NOTIFICATION),
           object: nil)
    }

    @objc
    private func overrideUserInterfaceStyleDidChange() {
        self.updateColorsAccordingToStyle()
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

        let shouldHideCommentText = showCommentLabels && showsUsernameInput
        let commentReplyDataModel = CommentReplyDataModel(
            author: model?.dataModel.authorName,
            comment: model?.dataModel.comment
        )

        let headerView: UIView
        if SpotIm.enableCreateCommentNewDesign {
            commentNewHeaderView.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
            commentNewHeaderView.delegate = self
            commentNewHeaderView.configure(with: commentReplyDataModel)
            if shouldHideCommentText {
                commentNewHeaderView.hideCommentText()
            }
            headerView = commentNewHeaderView
        } else {
            commentHeaderView.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
            commentHeaderView.configure(with: commentReplyDataModel)
            if shouldHideCommentText {
                commentHeaderView.hideCommentText()
            }
            headerView = commentHeaderView
        }

        topContainerStack.insertArrangedSubview(headerView, at: 0)

        let heightWithCommentText: CGFloat = SpotIm.enableCreateCommentNewDesign ? 135 : 111
        let heightWithoutCommentText: CGFloat = SpotIm.enableCreateCommentNewDesign ? 115 : 68

        headerView.layout {
            $0.top.equal(to: topContainerStack.topAnchor)
            $0.height.equal(to: shouldHideCommentText ? heightWithoutCommentText : heightWithCommentText)
            $0.width.equal(to: topContainerStack.widthAnchor)
        }

        updateTextInputContainer(with: .reply)
        updateAvatar()
    }

    private func configureModelHandlers() {
        model?.postCompletionHandler = { [weak self] reply in
            guard let self = self else { return }

            if reply.status == .block || !reply.published {
                switch reply.content?.first {
                case .text(let text):
                    self.delegate?.commentReplyDidBlock(with: text.text)
                default: break
                }

            } else {
                self.delegate?.commentReplyDidCreate(reply)
            }
            self.dismissController()
        }

        model?.errorHandler = { [weak self] error in
            guard let self = self else { return }

            self.hideLoader()
            self.showAlert(
                title: LocalizationManager.localizedString(key: "Oops..."),
                message: error.localizedDescription
            )
        }
    }
}
