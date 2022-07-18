//
//  CommentImagePreview.swift
//  SpotImCore
//
//  Created by Alon Shprung on 11/10/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

protocol OWCommentImagePreviewDelegate: AnyObject {
    func clickedOnRemoveButton()
}

final class OWCommentImagePreview: OWBaseView {
    
    private let imageView: OWBaseUIImageView = .init()
    private let loaderView: SPLoaderView = .init(backgroundOpacity: 0.4)
    
    private lazy var removeButton: OWBaseButton = .init(type: .custom)
    
    weak var delegate: OWCommentImagePreviewDelegate?
    
    var isUploadingImage: Bool {
        didSet {
            if isUploadingImage {
                loaderView.startLoader()
            } else {
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
        
        self.removeButton.setImage(UIImage(spNamed: "removeImageIcon", supportDarkMode: false), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resizeViewToFitImageSize()
    }
    
    func resizeViewToFitImageSize() {
        guard let image = imageView.image else {
            self.OWSnp.updateConstraints { make in
                make.height.equalTo(0)
            }
            return
        }
        let ratio = image.size.width / image.size.height
        let newHeight = imageView.frame.width / ratio
        self.OWSnp.updateConstraints { make in
            make.height.equalTo(newHeight)
        }
    }
    
    private func setup() {
        self.OWSnp.makeConstraints { make in
            make.height.equalTo(0)
        }
        
        addSubviews(imageView, removeButton, loaderView)
        setupImageView()
        setupLoaderView()
        setupRemoveButton()
    }
    
    private func setupLoaderView() {
        loaderView.OWSnp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupRemoveButton() {
        bringSubviewToFront(removeButton)
        removeButton.isHidden = true
        removeButton.addTarget(self, action: #selector(self.removeImage), for: .touchUpInside)
        removeButton.contentHorizontalAlignment = .right
        removeButton.contentVerticalAlignment = .top
        removeButton.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Theme.removeButtonTopOffset)
            make.trailing.equalToSuperview().offset(-Theme.removeButtonTrailingOffset)
            make.size.equalTo(Theme.removeButtonWidth)
        }
    }
    
    @objc
    private func removeImage() {
        self.image = nil
        self.isUploadingImage = false
        delegate?.clickedOnRemoveButton()
    }
}

extension OWCommentImagePreview {
    // MARK: - Theme

    private enum Theme {
        static let removeButtonTopOffset: CGFloat = 8.0
        static let removeButtonTrailingOffset: CGFloat = 8.0
        static let removeButtonWidth: CGFloat = 45.0
        static let removeButtonHeight: CGFloat = 45.0
    }
}
