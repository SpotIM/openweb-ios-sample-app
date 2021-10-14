//
//  CommentImagePreview.swift
//  SpotImCore
//
//  Created by Alon Shprung on 11/10/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

protocol CommentImagePreviewDelegate: AnyObject {
    func imageRemoved()
}

final class CommentImagePreview: BaseView {
    
    private let imageView: BaseUIImageView = .init()
    private var heightConstraint: NSLayoutConstraint?
    private let loaderView: SPLoaderView = .init(backgroundOpacity: 0.4)
    
    private lazy var removeButton: BaseButton = .init(type: .custom)
    
    weak var delegate: CommentImagePreviewDelegate?
    
    var isUploadingImage: Bool {
        didSet {
            if isUploadingImage {
                loaderView.isHidden = false
                loaderView.startLoader()
            } else {
                loaderView.isHidden = true
                loaderView.stopLoader()
            }
        }
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image
            resizeViewToFitImageSize()
            removeButton.isHidden = image == nil
        }
    }
 
    override init(frame: CGRect) {
        isUploadingImage = false
        super.init(frame: frame)
        setup()
        updateColorsAccordingToStyle()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        self.removeButton.setImage(UIImage(spNamed: "closeIcon"), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resizeViewToFitImageSize()
    }
    
    func resizeViewToFitImageSize() {
        guard let image = imageView.image else {
            heightConstraint?.constant = 0
            return
        }
        let ratio = image.size.width / image.size.height
        let newHeight = imageView.frame.width / ratio
        heightConstraint?.constant = newHeight
    }
    
    private func setup() {
        layout {
            heightConstraint = $0.height.equal(to: 0)
        }
        
        addSubviews(imageView, removeButton, loaderView)
        setupImageView()
        setupRemoveButton()
        setupLoaderView()
    }
    
    private func setupLoaderView() {
        loaderView.pinEdges(to: imageView)
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.layout {
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
    }
    
    private func setupRemoveButton() {
        removeButton.isHidden = true
        removeButton.addTarget(self, action: #selector(self.removeImage), for: .touchUpInside)
        removeButton.contentHorizontalAlignment = .right
        removeButton.contentVerticalAlignment = .top
        removeButton.layout {
            $0.top.equal(to: topAnchor, offsetBy: Theme.removeButtonTopOffset)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -Theme.removeButtonTrailingOffset)
            $0.height.equal(to: Theme.removeButtonHeight)
            $0.width.equal(to: Theme.removeButtonWidth)
        }
    }
    
    @objc
    private func removeImage() {
        self.image = nil
        self.isUploadingImage = false
        delegate?.imageRemoved()
    }
}

extension CommentImagePreview {
    // MARK: - Theme

    private enum Theme {
        static let removeButtonTopOffset: CGFloat = 8.0
        static let removeButtonTrailingOffset: CGFloat = 8.0
        static let removeButtonWidth: CGFloat = 45.0
        static let removeButtonHeight: CGFloat = 45.0
    }
}
