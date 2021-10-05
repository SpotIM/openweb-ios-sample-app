//
//  SPCommentFooterView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 04/10/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

final class SPCommentFooterView: BaseView {
    
    private let postButton: BaseButton = .init()
    private let footerSeperator: BaseView = .init()
    
    typealias PostButtonAction = () -> Void
    private var postButtonAction: PostButtonAction?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        footerSeperator.backgroundColor = .spSeparator2
        postButton.setBackgroundColor(color: .spInactiveButtonBG, forState: .disabled)
        postButton.backgroundColor = .brandColor
    }
    
    func setIsPostButtonEnabled(_ isEnabled: Bool) {
        postButton.isEnabled = isEnabled
    }
    
    func configurePostButton(title: String, action: @escaping PostButtonAction) {
        postButton.setTitle(title, for: .normal)
        postButtonAction = action
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
        postButton.layout {
            $0.centerY.equal(to: centerYAnchor)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -Theme.postButtonTrailing)
            $0.height.equal(to: Theme.postButtonHeight)
        }
    }
    
    private func configureFooterSeperator() {
        footerSeperator.layout {
            $0.top.equal(to: topAnchor)
            $0.height.equal(to: 1.0)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
    }
    
    @objc
    private func onClickOnPostButton() {
        postButtonAction?()
    }
    
}

private enum Theme {
    static let postButtonHeight: CGFloat = 32.0
    static let postButtonRadius: CGFloat = 5.0
    static let postButtonHorizontalInset: CGFloat = 32.0
    static let postButtonFontSize: CGFloat = 15.0
    static let postButtonTrailing: CGFloat = 16.0
}
