//
//  CommentMediaView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 29/06/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

internal class CommentMediaView: BaseView {
    private let gifWebView: GifWebView = .init()
    private let imageView: BaseUIImageView = .init()
    
    private var imageViewHeightConstraint: NSLayoutConstraint?
    private var imageViewWidthConstraint: NSLayoutConstraint?
    private var gifViewHeightConstraint: NSLayoutConstraint?
    private var gifViewWidthConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setupUI()
    }
    
    private func setupUI() {
        addSubviews(gifWebView, imageView)
        configureGifWebView()
        configureImageView()
    }
    
    private func configureGifWebView() {
        gifWebView.layout {
            $0.top.equal(to: self.topAnchor)
            $0.bottom.equal(to: self.bottomAnchor)
        }
    }
    
    private func configureImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = SPCommonConstants.commentMediaCornerRadius
        imageView.layout {
            imageViewHeightConstraint = $0.height.equal(to: 0)
            imageViewWidthConstraint = $0.width.equal(to: 0)
            $0.top.equal(to: self.topAnchor)
            $0.bottom.equal(to: self.bottomAnchor)
        }
    }
    
    func configureMedia(imageUrl: URL?, gifUrl: String?, width: Float?, height: Float?) {
        // if imageUrl exist, set image and clean gif
        if let imageUrl = imageUrl, let height = height, let width = width {
            // set placeholder
            imageView.image = UIImage(spNamed: "imageMediaPlaceholder", for: .light)
            // load image
            imageView.setImage(with: imageUrl)
            imageViewHeightConstraint?.constant = CGFloat(height)
            imageViewWidthConstraint?.constant = CGFloat(width)
            gifWebView.configure(gifUrl: nil, gifWidth: 0, gifHeight: 0)
        }
        // if gifUrl exist, set gif and clean image
        else if let gifUrl = gifUrl, let height = height, let width = width {
            gifWebView.configure(gifUrl: gifUrl, gifWidth: width, gifHeight: height)
            imageView.setImage(with: nil)
            imageViewHeightConstraint?.constant = 0
            imageViewWidthConstraint?.constant = 0
        }
    }
}
