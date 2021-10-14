//
//  SPCommentFooterView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 04/10/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

protocol SPCommentFooterViewDelegate: AnyObject {
    func imageSelected(image: UIImage)
}

enum SPCommentFooterContentButtonType {
    case image
    case gif // Not supported yet
}

final class SPCommentFooterView: BaseView {
    
    private let postButton: BaseButton = .init()
    private let footerSeperator: BaseView = .init()
    
    private let addImageButton: BaseButton = .init()
    
    typealias PostButtonAction = () -> Void
    private var postButtonAction: PostButtonAction?
    
    private weak var imagePicker: ImagePicker?
    public weak var delegate: SPCommentFooterViewDelegate?
    
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
    
    func setContentButtonTypes(_ types: [SPCommentFooterContentButtonType]) {
        for type in types {
            switch type {
            case .image:
                addSubview(addImageButton)
                configureAddImageButton()
                break
            default:
                break
            }
        }
    }
    
    func setImagePicker(_ imagePicker: ImagePicker) {
        self.imagePicker = imagePicker
        self.imagePicker?.delegate = self
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
    
    private func configureAddImageButton() {
        addImageButton.setImage(UIImage(spNamed: "addImageIcon"), for: .normal)
        addImageButton.addTarget(self, action: #selector(onClickOnAddImageButton(_:)), for: .touchUpInside)
        addInsentsToActionButton(addImageButton)
        addImageButton.layout {
            $0.centerY.equal(to: centerYAnchor)
            $0.leading.equal(to: leadingAnchor, offsetBy: Theme.actionIconsLeading)
            $0.height.equal(to: Theme.actionIconHeight)
            $0.width.equal(to: Theme.actionIconWidth)
        }
    }
    
    private func addInsentsToActionButton(_ button: BaseButton) {
        button.imageEdgeInsets = UIEdgeInsets(top: Theme.actionButtonVerticalInset, left: Theme.actionButtonHorizontalInset, bottom: Theme.actionButtonVerticalInset, right: Theme.actionButtonHorizontalInset)
    }
    
    @objc
    private func onClickOnPostButton() {
        postButtonAction?()
    }
    
    @objc
    private func onClickOnAddImageButton(_ sender: UIButton) {
        imagePicker?.present(from: sender)
    }
}

extension SPCommentFooterView: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        if let image = image {
            delegate?.imageSelected(image: image)
        }
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
