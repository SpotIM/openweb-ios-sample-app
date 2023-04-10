//
//  CommentMediaView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 29/06/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

internal class CommentMediaView: OWBaseView {
    fileprivate struct Metrics {
        static let identifier = "comment_media_view_id"
        static let gifIdentifier = "comment_gif_webview_id"
        static let imageIdentifier = "comment_image_view_id"
    }

    private let gifWebView: GifWebView = .init()
    private let imageView: OWBaseUIImageView = .init()

    private var imageViewHeightConstraint: NSLayoutConstraint?
    private var imageViewWidthConstraint: NSLayoutConstraint?
    private var gifViewHeightConstraint: NSLayoutConstraint?
    private var gifViewWidthConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        applyAccessibility()
    }

    private func configureGifWebView() {
        gifWebView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configureImageView() {
        imageView.contentMode = .scaleAspectFill
        // set placeholder image
        imageView.image = UIImage(spNamed: "imageMediaPlaceholder", supportDarkMode: false)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = SPCommonConstants.commentMediaCornerRadius
        imageView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func clearExistingMedia() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }

    func configureMedia(imageUrl: URL?, gifUrl: String?) {
        clearExistingMedia()
        // if imageUrl exist, set image and clean gif
        if let imageUrl = imageUrl {
            addSubview(imageView)
            configureImageView()
            imageView.setImage(with: imageUrl)
        }
        // if gifUrl exist, set gif and clean image
        else if let gifUrl = gifUrl {
            addSubview(gifWebView)
            configureGifWebView()
            gifWebView.configure(gifUrl: gifUrl)
        }
    }
}

fileprivate extension CommentMediaView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        gifWebView.accessibilityIdentifier = Metrics.gifIdentifier
        imageView.accessibilityIdentifier = Metrics.imageIdentifier
    }
}
