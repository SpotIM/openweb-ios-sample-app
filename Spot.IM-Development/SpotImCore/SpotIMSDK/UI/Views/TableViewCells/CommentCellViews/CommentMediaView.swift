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
        layer.cornerRadius = 6
        configureGifWebView()
        configureImageView()
    }
    
    private func configureGifWebView() {
        gifWebView.layout {
            $0.top.equal(to: self.topAnchor)
            $0.bottom.equal(to: self.bottomAnchor)
            gifViewHeightConstraint = $0.height.equal(to: 0)
            gifViewWidthConstraint = $0.width.equal(to: 0)
        }
    }
    
    private func configureImageView() {
        imageView.layer.masksToBounds = true
        imageView.layout {
            imageViewHeightConstraint = $0.height.equal(to: 0)
            imageViewWidthConstraint = $0.width.equal(to: 0)
            $0.top.equal(to: self.topAnchor)
            $0.bottom.equal(to: self.bottomAnchor)
        }
    }
    
    func configureMedia(imageUrl: URL?, gifUrl: String?, width: Float?, height: Float?) {
        if let imageUrl = imageUrl, let height = height, let width = width {
            imageView.setImage(with: imageUrl)
            imageViewHeightConstraint?.constant = CGFloat(height)
            imageViewWidthConstraint?.constant = CGFloat(width)
            gifViewHeightConstraint?.constant = 0
            gifViewWidthConstraint?.constant = 0
        } else if let gifUrl = gifUrl, let height = height, let width = width {
            gifWebView.configure(gifUrl: gifUrl, gifWidth: width, gifHeight: height)
            gifViewHeightConstraint?.constant = CGFloat(height)
            gifViewWidthConstraint?.constant = CGFloat(width)
            imageViewHeightConstraint?.constant = 0
            imageViewWidthConstraint?.constant = 0
        }
    }
}
