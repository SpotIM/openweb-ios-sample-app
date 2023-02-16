//
//  SPCommentCreationViewController.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/7/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

final class SPCommentCreationViewController: SPBaseCommentCreationViewController<SPCommentCreationModel> {

    private lazy var commentNewHeaderView = SPCommentCreationNewHeaderView()

    private lazy var articleView: SPArticleHeader = SPArticleHeader()
    private let commentingOnLabel: BaseLabel = .init()
    private let commentingContainer: UIView = .init()
    private let closeButton: BaseButton = .init()

    private var emptyArticleBottomConstarint: NSLayoutConstraint?
    private var filledArticleBottomConstarint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        topContainerView.bringSubviewToFront(closeButton)
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

    // Handle dark mode \ light mode change
    override func updateColorsAccordingToStyle() {
        super.updateColorsAccordingToStyle()
        if SpotIm.enableCreateCommentNewDesign {
            commentNewHeaderView.updateColorsAccordingToStyle()
        } else {
            commentingContainer.backgroundColor = .spBackground0
            commentingOnLabel.textColor = .spForeground4
            commentingOnLabel.backgroundColor = .spBackground0
            closeButton.backgroundColor = .spBackground0
            closeButton.setImage(UIImage(spNamed: "closeCrossIcon"), for: .normal)
        }
        articleView.updateColorsAccordingToStyle()
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

    private func shouldDisplayArticleHeader() -> Bool {
        if shouldShowArticleView(for: model?.dataModel),
           UIDevice.current.screenType != .iPhones_5_5s_5c_SE,
           SpotIm.displayArticleHeader,
           !(showCommentLabels && showsUsernameInput) {
            return true
        } else {
            return false
        }
    }

    internal override func updateModelData() {
        configureModelHandlers()

        if SpotIm.enableCreateCommentNewDesign {
            setupNewHeader()
        } else {
            setupHeader()
        }

        updateTextInputContainer(with: .comment)
        updateAvatar()
    }

    private func setupNewHeader() {
        guard commentNewHeaderView.superview == nil else {
            return
        }
        topContainerStack.insertArrangedSubview(commentNewHeaderView, at: 0)

        commentNewHeaderView.layout {
            $0.top.equal(to: topContainerStack.topAnchor)
            $0.leading.equal(to: topContainerStack.leadingAnchor)
            $0.trailing.equal(to: topContainerStack.trailingAnchor)
            $0.height.equal(to: 60)
        }

        commentNewHeaderView.delegate = self
        commentNewHeaderView.configure()
        commentNewHeaderView.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }

    private func setupHeader() {
        setupHeaderComponentsIfNeeded()
        if shouldDisplayArticleHeader(), #available(iOS 11.0, *) {
            topContainerStack.insertArrangedSubview(articleView, at: 1)
            articleView.setTitle(model?.dataModel.articleMetadata.title)
            articleView.setImage(with: URL(string: model?.dataModel.articleMetadata.thumbnailUrl ?? ""))
            articleView.setAuthor(model?.dataModel.articleMetadata.subtitle)

            articleView.layout {
                $0.height.equal(to: 85.0)
                $0.width.equal(to: topContainerStack.widthAnchor)
            }

            topContainerStack.setCustomSpacing(16, after: commentingOnLabel)
            commentingOnLabel.text = LocalizationManager.localizedString(key: "Commenting on")
        } else {
            emptyArticleBottomConstarint?.isActive = true
            commentingOnLabel.text = LocalizationManager.localizedString(key: "Add a Comment")
        }
    }

    private func setupHeaderComponentsIfNeeded() {
        guard commentingOnLabel.superview == nil, closeButton.superview == nil else {
            return
        }

        commentingContainer.addSubview(commentingOnLabel)

        topContainerStack.insertArrangedSubview(commentingContainer, at: 0)

        topContainerView.addSubview(closeButton)

        commentingOnLabel.font = UIFont.preferred(style: .regular, of: 16.0)
        commentingOnLabel.text = LocalizationManager.localizedString(key: "Commenting on")
        commentingOnLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        commentingOnLabel.sizeToFit()

        commentingContainer.layout {
            $0.top.equal(to: topContainerStack.topAnchor)
            $0.leading.equal(to: topContainerStack.leadingAnchor)
            $0.trailing.equal(to: topContainerStack.trailingAnchor)
            $0.height.equal(to: commentingOnLabel.frame.height + 41)
        }

        commentingOnLabel.layout {
            $0.top.equal(to: commentingContainer.topAnchor, offsetBy: 25)
            $0.leading.equal(to: commentingContainer.leadingAnchor, offsetBy: 16)
            $0.trailing.equal(to: commentingContainer.trailingAnchor, offsetBy: -16)
            $0.bottom.equal(to: commentingContainer.bottomAnchor, offsetBy: -16)
        }

        closeButton.setImage(UIImage(spNamed: "closeCrossIcon"), for: .normal)
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
            Logger.verbose("FirstComment: Post returned")
            guard let self = self else { return }

            if comment.status == .block || !comment.published {
                switch comment.content?.first {
                case .text(let text):
                    self.delegate?.commentReplyDidBlock(with: text.text)
                default:
                    break
                }
            } else {
                self.delegate?.commentReplyDidCreate(comment)
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

    private func shouldShowArticleView(for model: SPCommentCreationDTO?) -> Bool {
        model != nil
    }

}
