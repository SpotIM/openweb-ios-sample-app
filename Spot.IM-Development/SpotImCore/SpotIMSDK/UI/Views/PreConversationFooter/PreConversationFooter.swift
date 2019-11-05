//
//  PreConversationFooter.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 14/08/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

protocol SPPreConversationFooterDelegate: class {
    func showMoreComments()
    func showTerms()
    func showPrivacy()
    func showAddSpotIM()
}

internal final class SPPreConversationFooter: BaseView {
    
    private lazy var separatorView: UIView = .init()
    private lazy var showMoreCommentsButton: UIButton = .init(type: .system)
    private lazy var termsButton: UIButton = .init(type: .system)
    private lazy var dotLabel: UILabel = .init()
    private lazy var privacyButton: UIButton = .init(type: .system)
    private lazy var spotIMIcon: UIImageView = .init()
    private lazy var addSpotIMButton: UIButton = .init(type: .system)
    private lazy var bannerContainerView: UIView = .init()
    private var bannerView: UIView?
    
    private var moreCommentsHeightConstraint: NSLayoutConstraint?
    private var moreCommentsTopConstraint: NSLayoutConstraint?
    private var bannerContainerHeight: NSLayoutConstraint?
    
    internal weak var delegate: SPPreConversationFooterDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    func setShowMoreCommentsButtonColor(color: UIColor, withSeparator: Bool = false) {
        moreCommentsTopConstraint?.constant = withSeparator ? 20.0 : 0.0
        showMoreCommentsButton.backgroundColor = color
        separatorView.isHidden = !withSeparator
    }

    func updateBannerView(_ bannerView: UIView, height: CGFloat) {
        self.bannerView?.removeFromSuperview()
        self.bannerView = bannerView
        bannerContainerView.addSubview(bannerView)
        bannerView.layout {
            $0.height.equal(to: height)
            $0.leading.equal(to: bannerContainerView.leadingAnchor)
            $0.trailing.equal(to: bannerContainerView.trailingAnchor)
            $0.bottom.equal(to: bannerContainerView.bottomAnchor)
        }
        bannerContainerHeight?.constant = height + 30.0
    }
    
    private func setup() {
        addSubviews(separatorView,
                    showMoreCommentsButton,
                    bannerContainerView,
                    termsButton,
                    dotLabel,
                    privacyButton,
                    spotIMIcon,
                    addSpotIMButton)

        setupShowMoreCommentsButton()
        setupBannerView()
        setupTermsButton()
        setupDotLabel()
        setupPrivacyButton()
        setupSpotIMIcon()
        setupAddSpotIMButton()
    }

    func hideShowMoreCommentsButton() {
        moreCommentsHeightConstraint?.constant = 0
        showMoreCommentsButton.isHidden = true
    }

    func showShowMoreCommentsButton() {
        moreCommentsHeightConstraint?.constant = Theme.showMoreCommentsButtonHeight
        showMoreCommentsButton.isHidden = false
    }

    private func setupShowMoreCommentsButton() {
        separatorView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
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

    private func setupBannerView() {
        bannerContainerView.layout {
            $0.top.equal(to: showMoreCommentsButton.bottomAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            bannerContainerHeight = $0.height.equal(to: 0.0)
        }
    }
    
    private func setupTermsButton() {
        let title = LocalizationManager.localizedString(key: "Terms")
        termsButton.setTitle(title, for: .normal)
        termsButton.setTitleColor(.coolGrey, for: .normal)
        termsButton.titleLabel?.font = .preferred(style: .regular, of: Theme.bottomRowSize)
        termsButton.addTarget(self, action: #selector(showTerms), for: .touchUpInside)

        termsButton.layout {
            $0.top.equal(to: bannerContainerView.bottomAnchor, offsetBy: Theme.showMoreCommentsButtonBottomMargin)
            $0.leading.equal(to: leadingAnchor, offsetBy: Theme.horisontalMargin)
            $0.bottom.equal(to: bottomAnchor, offsetBy: -Theme.bottomMargin)
        }
    }

    private func setupDotLabel() {
        dotLabel.text = " · "
        dotLabel.textColor = .coolGrey
        dotLabel.font = .preferred(style: .regular, of: Theme.bottomRowSize)
        dotLabel.layout {
            $0.leading.equal(to: termsButton.trailingAnchor)
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
            $0.leading.equal(to: dotLabel.trailingAnchor)
        }
    }

    private func setupSpotIMIcon() {
        spotIMIcon.image = UIImage(spNamed: "spotIconSimple")
        spotIMIcon.layout {
            $0.width.equal(to: Theme.bottomRowSize)
            $0.height.equal(to: Theme.bottomRowSize)
            $0.centerY.equal(to: addSpotIMButton.centerYAnchor)
            $0.trailing.equal(to: addSpotIMButton.leadingAnchor, offsetBy: -Theme.iconOffset)
        }
    }

    private func setupAddSpotIMButton() {
        let title = LocalizationManager.localizedString(key: "Add Spot.IM to your app")
        addSpotIMButton.setTitle(title, for: .normal)
        addSpotIMButton.setTitleColor(.coolGrey, for: .normal)
        addSpotIMButton.titleLabel?.font = .preferred(style: .regular, of: Theme.bottomRowSize)
        addSpotIMButton.addTarget(self, action: #selector(showAddSpotIM), for: .touchUpInside)

        addSpotIMButton.layout {
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
