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
        gifWebView.isHidden = true
        gifWebView.layout {
            $0.top.equal(to: self.topAnchor)
            $0.bottom.equal(to: self.bottomAnchor)
        }
    }
    
    private func configureImageView() {
        imageView.isHidden = true
        imageView.layer.masksToBounds = true
        imageView.layout {
            imageViewHeightConstraint = $0.height.equal(to: 0)
            imageViewWidthConstraint = $0.width.equal(to: 0)
            $0.top.equal(to: self.topAnchor)
            $0.bottom.equal(to: self.bottomAnchor)
        }
    }
    
    func configureImage(imageUrl: URL?, gifWidth: Float?, gifHeight: Float?) {
        gifWebView.isHidden = true
        imageView.isHidden = false
        imageView.setImage(with: imageUrl)
        imageViewHeightConstraint?.constant = CGFloat(gifHeight ?? 0)
        imageViewWidthConstraint?.constant = CGFloat(gifWidth ?? 0)
//        updateGifWebView(gifUrl: gifUrl, gifWidth: gifWidth, gifHeight: gifHeight)
    }
    
    func configureGif(gifUrl: String?, gifWidth: Float?, gifHeight: Float?) {
        gifWebView.isHidden = false
        imageView.isHidden = true
        gifWebView.configure(gifUrl: gifUrl, gifWidth: gifWidth, gifHeight: gifHeight)
    }
}
