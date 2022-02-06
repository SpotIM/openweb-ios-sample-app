//
//  PreConversationFooter.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 14/08/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

protocol SPPreConversationFooterDelegate: AnyObject {
    func showMoreComments()
    func showTerms()
    func showPrivacy()
    func showAddSpotIM()
    func updateMoreCommentsButtonCustomUI(button: SPShowCommentsButton)
}

internal final class SPPreConversationFooter: OWBaseView {
    
    private lazy var separatorView: OWBaseView = .init()
    private lazy var showMoreCommentsButton: SPShowCommentsButton = .init()
    private lazy var termsButton: OWBaseButton = .init()
    private lazy var dotLabel: OWBaseLabel = .init()
    private lazy var privacyButton: OWBaseButton = .init()
    private lazy var spotIMIcon: OWBaseUIImageView = .init()
    private lazy var addSpotIMButton: OWBaseButton = .init()
    private lazy var openwebLinkView: OWBaseView = .init()
    
    private var moreCommentsHeightConstraint: NSLayoutConstraint?
    private var moreCommentsTopConstraint: NSLayoutConstraint?
    private var termsHeightConstraint: NSLayoutConstraint?
    private var termsBottomConstraint: NSLayoutConstraint?
    
    private var buttonOnlyMode: Bool = false
    
    internal weak var delegate: SPPreConversationFooterDelegate?

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        setup()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        separatorView.backgroundColor = .spSeparator5
        showMoreCommentsButton.backgroundColor = .brandColor
        addSpotIMButton.backgroundColor = .spBackground0
        openwebLinkView.backgroundColor = .spBackground0
        spotIMIcon.image = UIImage(spNamed: "openwebIconSimple", supportDarkMode: true) // reload image for dark mode if needed
        delegate?.updateMoreCommentsButtonCustomUI(button: showMoreCommentsButton)
    }

    func setShowMoreCommentsButtonColor(color: UIColor, withSeparator: Bool = false) {
        moreCommentsTopConstraint?.constant = withSeparator ? 20.0 : 0.0
        showMoreCommentsButton.backgroundColor = color
        separatorView.isHidden = !withSeparator
    }
    
    private func setup() {
        openwebLinkView.addSubviews(spotIMIcon,
                                    addSpotIMButton)
        addSubviews(separatorView,
                    showMoreCommentsButton,
                    termsButton,
                    dotLabel,
                    privacyButton,
                    openwebLinkView)
        setupShowMoreCommentsButton()
        setupTermsButton()
        setupDotLabel()
        setupPrivacyButton()
        setupSpotIMIcon()
        setupAddSpotIMButton()
        setupOpenWebLinkView()
    }

    func hideShowMoreCommentsButton() {
        moreCommentsHeightConstraint?.constant = 0
        showMoreCommentsButton.isHidden = true
        separatorView.isHidden = true
    }

    func showShowMoreCommentsButton() {
        moreCommentsHeightConstraint?.constant = Theme.showMoreCommentsButtonHeight
        showMoreCommentsButton.isHidden = false
        separatorView.isHidden = false
    }
    
    func set(buttonOnlyMode: Bool) {
        self.buttonOnlyMode = buttonOnlyMode
        setViewsAccordingToButtonOnlyMode()
    }
    
    func set(commentsCount: String?) {
        showMoreCommentsButton.setCommentsCount(commentsCount: commentsCount)
        setViewsAccordingToButtonOnlyMode()
    }
    
    private func setViewsAccordingToButtonOnlyMode() {
        termsButton.isHidden = buttonOnlyMode
        dotLabel.isHidden = buttonOnlyMode
        privacyButton.isHidden = buttonOnlyMode
        spotIMIcon.isHidden = buttonOnlyMode
        addSpotIMButton.isHidden = buttonOnlyMode
        openwebLinkView.isHidden = buttonOnlyMode
        separatorView.isHidden = buttonOnlyMode
        if (buttonOnlyMode) {
            termsHeightConstraint?.constant = 0
            termsBottomConstraint?.constant = 0
            
            var title: String
            if SpotIm.buttonOnlyMode == .withTitle {
                title = LocalizationManager.localizedString(key: "Post a Comment")
            } else { // without title
                title = LocalizationManager.localizedString(key: "Show Comments")
                if let commentsCount = showMoreCommentsButton.getCommentsCount() {
                    title += " (\(commentsCount))"
                }
            }
            showMoreCommentsButton.setTitle(title, for: .normal)
        }
        delegate?.updateMoreCommentsButtonCustomUI(button: showMoreCommentsButton)
    }

    private func setupShowMoreCommentsButton() {
        separatorView.backgroundColor = .spSeparator5
        separatorView.layout {
            $0.top.equal(to: topAnchor)
            $0.leading.equal(to: leadingAnchor, offsetBy: 15.0)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -15.0)
            $0.height.equal(to: 1.0)
        }
        
        
        let title = LocalizationManager.localizedString(key: "SHOW MORE COMMENTS")

        showMoreCommentsButton.backgroundColor = .brandColor
        showMoreCommentsButton.setTitle(title, for: .normal)
        showMoreCommentsButton.setTitleColor(.white, for: .normal)
        showMoreCommentsButton.titleLabel?.font = .preferred(style: .medium, of: Theme.showMoreCommentsButtonFontSize)
        showMoreCommentsButton.layer.cornerRadius = Theme.showMoreCommentsButtonCornerRadius
        showMoreCommentsButton.addTarget(self, action: #selector(showMoreComments), for: .touchUpInside)

        showMoreCommentsButton.layout {
            moreCommentsTopConstraint = $0.top.equal(to: topAnchor, offsetBy: 0.0)
            $0.leading.equal(to: leadingAnchor, offsetBy: Theme.horisontalMargin)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -Theme.horisontalMargin)
            moreCommentsHeightConstraint = $0.height.equal(to: Theme.showMoreCommentsButtonHeight)
        }
    }
    
    private func setupTermsButton() {
        let title = LocalizationManager.localizedString(key: "Terms")
        termsButton.setTitle(title, for: .normal)
        termsButton.setTitleColor(.coolGrey, for: .normal)
        termsButton.titleLabel?.font = .preferred(style: .regular, of: Theme.bottomRowSize)
        termsButton.addTarget(self, action: #selector(showTerms), for: .touchUpInside)

        termsButton.layout {
            $0.top.equal(to: showMoreCommentsButton.bottomAnchor, offsetBy: Theme.showMoreCommentsButtonBottomMargin)
            $0.leading.equal(to: leadingAnchor, offsetBy: Theme.horisontalMargin)
            termsBottomConstraint = $0.bottom.equal(to: bottomAnchor, offsetBy: -Theme.bottomMargin)
            termsHeightConstraint = $0.height.equal(to: 15)
        }
    }

    private func setupDotLabel() {
        dotLabel.text = "·"
        dotLabel.textColor = .coolGrey
        dotLabel.font = .preferred(style: .regular, of: Theme.bottomRowSize)
        dotLabel.layout {
            $0.leading.equal(to: termsButton.trailingAnchor, offsetBy: 5.0)
            $0.trailing.equal(to: privacyButton.leadingAnchor, offsetBy: -5.0)
            $0.centerY.equal(to: termsButton.centerYAnchor)
        }
    }

    private func setupPrivacyButton() {
        let title = LocalizationManager.localizedString(key: "Privacy")
        privacyButton.setTitle(title, for: .normal)
        privacyButton.setTitleColor(.coolGrey, for: .normal)
        privacyButton.titleLabel?.font = .preferred(style: .regular, of: Theme.bottomRowSize)
        privacyButton.addTarget(self, action: #selector(showPrivacy), for: .touchUpInside)

        privacyButton.layout {
            $0.centerY.equal(to: termsButton.centerYAnchor)
        }
    }

    private func setupSpotIMIcon() {
        spotIMIcon.image = UIImage(spNamed: "openwebIconSimple", supportDarkMode: true)
        spotIMIcon.layout {
            $0.width.equal(to: Theme.bottomRowSize)
            $0.height.equal(to: Theme.bottomRowSize)
            $0.centerY.equal(to: addSpotIMButton.centerYAnchor)
            $0.left.equal(to: openwebLinkView.leftAnchor)
        }
    }

    private func setupAddSpotIMButton() {
        let title = LocalizationManager.localizedString(key: "Powered by OpenWeb")
        addSpotIMButton.setTitle(title, for: .normal)
        addSpotIMButton.setTitleColor(.coolGrey, for: .normal)
        addSpotIMButton.titleLabel?.font = .preferred(style: .regular, of: Theme.bottomRowSize)
        addSpotIMButton.addTarget(self, action: #selector(showAddSpotIM), for: .touchUpInside)

        addSpotIMButton.layout {
            $0.centerY.equal(to: privacyButton.centerYAnchor)
            $0.right.equal(to: openwebLinkView.rightAnchor)
        }
    }

    private func setupOpenWebLinkView() {
        addSpotIMButton.sizeToFit()
        openwebLinkView.layout {
            $0.width.equal(to: Theme.bottomRowSize + Theme.iconOffset + addSpotIMButton.frame.width)
            $0.height.equal(to: addSpotIMButton.heightAnchor)
            $0.centerY.equal(to: privacyButton.centerYAnchor)
            $0.leading.greaterThanOrEqual(to: privacyButton.trailingAnchor)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -Theme.horisontalMargin)
        }
    }
    
    @objc
    private func showMoreComments() {
        delegate?.showMoreComments()
    }

    @objc
    private func showTerms() {
        delegate?.showTerms()
    }

    @objc
    private func showPrivacy() {
        delegate?.showPrivacy()
    }
    @objc
    private func showAddSpotIM() {
        delegate?.showAddSpotIM()
    }
}

private extension SPPreConversationFooter {
    private enum Theme {
        static let bottomRowSize: CGFloat = 13
        static let horisontalMargin: CGFloat = 16
        static let bottomMargin: CGFloat = 23
        static let iconOffset: CGFloat = 5
        static let showMoreCommentsButtonHeight: CGFloat = 46
        static let showMoreCommentsButtonBottomMargin: CGFloat = 20
        static let showMoreCommentsButtonCornerRadius: CGFloat = 4
        static let showMoreCommentsButtonFontSize: CGFloat = 14
    }
}
