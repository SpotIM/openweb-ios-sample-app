//
//  OWZoomableImageView.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 04/12/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import UIKit

class OWZoomableImageView: UIView {
    private struct Metrics {
        static let identifier = "zoomable_image_view_id"
        static let scrollViewMinimumZoomScale = 1.0
        static let scrollViewMaximumZoomScale = 5.0
    }

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = Metrics.scrollViewMinimumZoomScale
        scrollView.maximumZoomScale = Metrics.scrollViewMaximumZoomScale
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        applyIdentifiers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        applyIdentifiers()
    }

    func setImage(_ image: UIImage) {
        imageView.image = image
    }
}

private extension OWZoomableImageView {
    func applyIdentifiers() {
        self.accessibilityIdentifier = Metrics.identifier
    }

    func setupView() {
        addSubview(scrollView)
        scrollView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.addSubview(imageView)
        imageView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalToSuperview()
        }

        scrollView.delegate = self
    }
}

extension OWZoomableImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageView()
    }

    private func centerImageView() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size

        let verticalPadding = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        let horizontalPadding = max(0, (scrollViewSize.width - imageViewSize.width) / 2)

        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
}
