//
//  CommentImagePreview.swift
//  SpotImCore
//
//  Created by Alon Shprung on 11/10/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

final class CommentImagePreview: BaseView {
    
    private let imageView: BaseUIImageView = .init()
    private var heightConstraint: NSLayoutConstraint?
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
    }
    
    func setImage(image: UIImage) {
        imageView.image = image
        resizeViewToFitImageSize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resizeViewToFitImageSize()
    }
    
    func resizeViewToFitImageSize() {
        guard let image = imageView.image else { return }
        let ratio = image.size.width / image.size.height
        let newHeight = imageView.frame.width / ratio
        heightConstraint?.constant = newHeight
    }
    
    private func setup() {
        layout {
            heightConstraint = $0.height.equal(to: 0)
        }
        
        addSubviews(imageView)
        setupImageView()
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
}
