//
//  SPCommentFooterView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 04/10/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

protocol SPCommentFooterViewDelegate: AnyObject {
    func clickedOnAddContentButton(type: SPCommentFooterContentButtonType)
    func updatePostCommentButtonCustomUI(button: SPBaseButton)
}

enum SPCommentFooterContentButtonType {
    case image
    case gif // Not supported yet
}

final class SPCommentFooterView: SPBaseView {
    fileprivate struct Metrics {
        static let identifier = "comment_footer_view_id"
        static let postButtonIdentifier = "comment_footer_view_post_button_id"
        static let addImageButtonIdentifier = "comment_footer_view_add_image_button_id"
    }
    private let postButton: SPBaseButton = .init()
    private let footerSeperator: SPBaseView = .init()

    private let addImageButton: SPBaseButton = .init()

    typealias PostButtonAction = () -> Void
    private var postButtonAction: PostButtonAction?

    public weak var delegate: SPCommentFooterViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
        applyAccessibility()
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        postButton.accessibilityIdentifier = Metrics.postButtonIdentifier
        addImageButton.accessibilityIdentifier = Metrics.addImageButtonIdentifier
    }

    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        footerSeperator.backgroundColor = .spSeparator2
        postButton.setBackgroundColor(color: .spInactiveButtonBG, forState: .disabled)
        postButton.backgroundColor = .brandColor
        delegate?.updatePostCommentButtonCustomUI(button: postButton)
    }

    func setIsPostButtonEnabled(_ isEnabled: Bool) {
        postButton.isEnabled = isEnabled
    }

    func configurePostButton(title: String, action: @escaping PostButtonAction) {
        postButton.setTitle(title, for: .normal)
        postButtonAction = action
    }

    func setContentButtonTypes(_ types: [SPCommentFooterContentButtonType]) {
        for type in types {
            switch type {
            case .image:
                addSubview(addImageButton)
                configureAddImageButton()

            default:
                break
            }
        }
    }

    private func setup() {
        addSubviews(footerSeperator, postButton)

        configureFooterSeperator()
        configurePostButton()
    }

    private func configurePostButton() {
        postButton.addTarget(self, action: #selector(onClickOnPostButton), for: .touchUpInside)
        postButton.setTitleColor(.white, for: .normal)
        postButton.isEnabled = false
        postButton.titleLabel?.font = UIFont.preferred(style: .regular, of: Theme.postButtonFontSize)
        postButton.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: Theme.postButtonHorizontalInset,
            bottom: 0.0,
            right: Theme.postButtonHorizontalInset
        )

        postButton.addCornerRadius(Theme.postButtonRadius)
        postButton.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-Theme.postButtonTrailing)
            make.height.equalTo(Theme.postButtonHeight)
        }
    }

    private func configureFooterSeperator() {
        footerSeperator.OWSnp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(1.0)
        }
    }

    private func configureAddImageButton() {
        addImageButton.setImage(UIImage(spNamed: "addImageIcon"), for: .normal)
        addImageButton.addTarget(self, action: #selector(onClickOnAddImageButton(_:)), for: .touchUpInside)
        addInsentsToActionButton(addImageButton)
        addImageButton.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(Theme.actionIconsLeading)
            make.height.equalTo(Theme.actionIconHeight)
            make.width.equalTo(Theme.actionIconWidth)
        }
    }

    private func addInsentsToActionButton(_ button: SPBaseButton) {
        button.imageEdgeInsets = UIEdgeInsets(top: Theme.actionButtonVerticalInset,
                                              left: Theme.actionButtonHorizontalInset,
                                              bottom: Theme.actionButtonVerticalInset,
                                              right: Theme.actionButtonHorizontalInset)
    }

    @objc
    private func onClickOnPostButton() {
        postButtonAction?()
    }

    @objc
    private func onClickOnAddImageButton(_ sender: UIButton) {
        delegate?.clickedOnAddContentButton(type: .image)
    }
}

private enum Theme {
    static let postButtonHeight: CGFloat = 32.0
    static let postButtonRadius: CGFloat = 5.0
    static let postButtonHorizontalInset: CGFloat = 32.0
    static let postButtonFontSize: CGFloat = 15.0
    static let postButtonTrailing: CGFloat = 16.0
    static let actionIconsLeading: CGFloat = 16.0
    static let actionIconHeight: CGFloat = 16.0 + (6.0 * 2)
    static let actionIconWidth: CGFloat = 18.0 + (6.0 * 2)
    static let actionButtonVerticalInset: CGFloat = 6.0
    static let actionButtonHorizontalInset: CGFloat = 6.0
}
