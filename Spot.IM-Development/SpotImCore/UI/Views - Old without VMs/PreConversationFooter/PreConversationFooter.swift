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
    fileprivate struct Metrics {
        static let identifier = "pre_conversation_footer_id"
        static let showMoreCommentsButtonIdentifier = "pre_conversation_footer_show_more_comments_button_id"
        static let termsButtonIdentifier = "pre_conversation_footer_show_terms_button_id"
        static let privacyButtonIdentifier = "pre_conversation_footer_show_privacy_button_id"
        static let spotIMIconIdentifier = "pre_conversation_footer_ow_icon_id"
        static let addSpotIMButtonIdentifier = "pre_conversation_footer_open_ow_web_button_id"
    }
    private lazy var separatorView: OWBaseView = .init()
    private lazy var showMoreCommentsButton: SPShowCommentsButton = .init()
    private lazy var termsButton: OWBaseButton = {
        let btn = OWBaseButton()
        return btn
    }()
    private lazy var dotLabel: OWBaseLabel = .init()
    private lazy var privacyButton: OWBaseButton = {
        let btn = OWBaseButton()
        return btn
    }()
    private lazy var spotIMIcon: OWBaseUIImageView = .init()
    private lazy var addSpotIMButton: OWBaseButton = .init()
    private lazy var openwebLinkView: OWBaseView = .init()

    private var moreCommentsTopConstraint: OWConstraint?
    private var termsBottomConstraint: OWConstraint?

    private var buttonOnlyMode: Bool = false

    internal weak var delegate: SPPreConversationFooterDelegate?

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
        applyAccessibility()
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        showMoreCommentsButton.accessibilityIdentifier = Metrics.showMoreCommentsButtonIdentifier
        termsButton.accessibilityIdentifier = Metrics.termsButtonIdentifier
        privacyButton.accessibilityIdentifier = Metrics.privacyButtonIdentifier
        spotIMIcon.accessibilityIdentifier = Metrics.spotIMIconIdentifier
        addSpotIMButton.accessibilityIdentifier = Metrics.addSpotIMButtonIdentifier
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
        moreCommentsTopConstraint?.update(offset: withSeparator ? 20.0 : 0.0)
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
        showMoreCommentsButton.OWSnp.updateConstraints { make in
            make.height.equalTo(0)
        }
        showMoreCommentsButton.isHidden = true
        separatorView.isHidden = true
    }

    func showShowMoreCommentsButton() {
        showMoreCommentsButton.OWSnp.updateConstraints { make in
            make.height.equalTo(Theme.showMoreCommentsButtonHeight)
        }
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
            termsButton.OWSnp.updateConstraints { make in
                make.height.equalTo(0)
            }
            termsBottomConstraint?.update(offset: 0)

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
        separatorView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(15.0)
            make.trailing.equalToSuperview().offset(-15.0)
            make.height.equalTo(1.0)
        }

        let title = LocalizationManager.localizedString(key: "Show more comments")

        showMoreCommentsButton.backgroundColor = .brandColor
        showMoreCommentsButton.setTitle(title, for: .normal)
        showMoreCommentsButton.setTitleColor(.white, for: .normal)
        showMoreCommentsButton.titleLabel?.font = .preferred(style: .medium, of: Theme.showMoreCommentsButtonFontSize)
        showMoreCommentsButton.layer.cornerRadius = Theme.showMoreCommentsButtonCornerRadius
        showMoreCommentsButton.addTarget(self, action: #selector(showMoreComments), for: .touchUpInside)

        showMoreCommentsButton.OWSnp.makeConstraints { make in
            moreCommentsTopConstraint = make.top.equalToSuperview().constraint
            make.leading.equalToSuperview().offset(Theme.horizontalMargin)
            make.trailing.equalToSuperview().offset(-Theme.horizontalMargin)
            make.height.equalTo(Theme.showMoreCommentsButtonHeight)

        }
    }

    private func setupTermsButton() {
        let title = LocalizationManager.localizedString(key: "Terms")
        termsButton.setTitle(title, for: .normal)
        termsButton.setTitleColor(.coolGrey, for: .normal)
        // Intentionally using Open Sans font which we are using it in OpenWeb
        termsButton.titleLabel?.font = .openSans(style: .regular, of: Theme.bottomRowSize)
        termsButton.addTarget(self, action: #selector(showTerms), for: .touchUpInside)

        termsButton.OWSnp.makeConstraints { make in
            make.top.equalTo(showMoreCommentsButton.OWSnp.bottom).offset(Theme.showMoreCommentsButtonBottomMargin)
            make.leading.equalToSuperview().offset(Theme.horizontalMargin)
            termsBottomConstraint = make.bottom.equalToSuperview().offset(-Theme.bottomMargin).constraint
            make.height.equalTo(15)
        }
    }

    private func setupDotLabel() {
        dotLabel.text = "·"
        dotLabel.textColor = .coolGrey
        dotLabel.font = .openSans(style: .regular, of: Theme.bottomRowSize)
        dotLabel.OWSnp.makeConstraints { make in
            make.leading.equalTo(termsButton.OWSnp.trailing).offset(5.0)
            make.trailing.equalTo(privacyButton.OWSnp.leading).offset(-5.0)
            make.centerY.equalTo(termsButton)
        }
    }

    private func setupPrivacyButton() {
        let title = LocalizationManager.localizedString(key: "Privacy")
        privacyButton.setTitle(title, for: .normal)
        privacyButton.setTitleColor(.coolGrey, for: .normal)
        // Intentionally using Open Sans font which we are using it in OpenWeb
        privacyButton.titleLabel?.font = .openSans(style: .regular, of: Theme.bottomRowSize)
        privacyButton.addTarget(self, action: #selector(showPrivacy), for: .touchUpInside)

        privacyButton.OWSnp.makeConstraints { make in
            make.centerY.equalTo(termsButton)
        }
    }

    private func setupSpotIMIcon() {
        spotIMIcon.image = UIImage(spNamed: "openwebIconSimple", supportDarkMode: true)

        spotIMIcon.OWSnp.makeConstraints { make in
            make.size.equalTo(Theme.bottomRowSize)
            make.centerY.equalTo(addSpotIMButton)
            make.left.equalTo(openwebLinkView)
        }
    }

    private func setupAddSpotIMButton() {
        let title = LocalizationManager.localizedString(key: "Powered by OpenWeb")
        addSpotIMButton.setTitle(title, for: .normal)
        addSpotIMButton.setTitleColor(.coolGrey, for: .normal)
        // Intentionally using Open Sans font which we are using it in OpenWeb
        addSpotIMButton.titleLabel?.font = .openSans(style: .regular, of: Theme.bottomRowSize)
        addSpotIMButton.addTarget(self, action: #selector(showAddSpotIM), for: .touchUpInside)

        addSpotIMButton.OWSnp.makeConstraints { make in
            make.centerY.equalTo(privacyButton)
            make.right.equalTo(openwebLinkView)
        }
    }

    private func setupOpenWebLinkView() {
        addSpotIMButton.sizeToFit()
        openwebLinkView.OWSnp.makeConstraints { make in
            make.width.equalTo(Theme.bottomRowSize + Theme.iconOffset + addSpotIMButton.frame.width)
            make.height.equalTo(addSpotIMButton)
            make.centerY.equalTo(privacyButton)
            make.leading.greaterThanOrEqualTo(privacyButton.OWSnp.trailing)
            make.trailing.equalToSuperview().offset(-Theme.horizontalMargin)
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
        static let horizontalMargin: CGFloat = 16
        static let bottomMargin: CGFloat = 23
        static let iconOffset: CGFloat = 5
        static let showMoreCommentsButtonHeight: CGFloat = 46
        static let showMoreCommentsButtonBottomMargin: CGFloat = 20
        static let showMoreCommentsButtonCornerRadius: CGFloat = 4
        static let showMoreCommentsButtonFontSize: CGFloat = 14
    }
}
