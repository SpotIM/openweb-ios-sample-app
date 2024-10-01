//
//  OWCommentCreationImagePreviewView.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 20/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWCommentCreationImagePreviewView: UIView {
    private struct Metrics {
        static let identifier = "comment_image_preview_id"
        static let imageViewIdentifier = "comment_image_preview_image_view_id"
        static let loaderViewIdentifier = "comment_image_preview_loader_view_id"
        static let removeButtonIdentifier = "comment_image_preview_remove_button_id"

        static let removeButtonTopOffset: CGFloat = 8.0
        static let removeButtonTrailingOffset: CGFloat = 8.0
        static let removeButtonSize: CGFloat = 45.0
        static let loadingCoverViewOpacity: CGFloat = 0.2
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
            .contentMode(.scaleAspectFit)
            .image(UIImage(spNamed: "imageMediaPlaceholder", supportDarkMode: false)) // Placeholder
        imageView.addSubviews(imageViewLoadingCoverView)
        imageViewLoadingCoverView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return imageView
    }()

    private lazy var imageViewLoadingCoverView: UIView = {
        return UIView()
            .backgroundColor(UIColor.black.withAlphaComponent(Metrics.loadingCoverViewOpacity))
    }()

    private lazy var loaderView: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .whiteLarge)
    }()

    private lazy var removeButton: UIButton = {
        let button = UIButton()
            .image(UIImage(spNamed: "removeImageIcon", supportDarkMode: false), state: .normal)
        button.contentHorizontalAlignment = .right
        button.contentVerticalAlignment = .top
        return button
    }()

    private let disposeBag = DisposeBag()
    private let viewModel: OWCommentCreationImagePreviewViewModeling

    init(with viewModel: OWCommentCreationImagePreviewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        setupUI()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OWCommentCreationImagePreviewView {
    func setupUI() {
        self.enforceSemanticAttribute()

        self.OWSnp.makeConstraints { make in
            make.height.equalTo(0)
        }

        addSubview(imageView)
        imageView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(loaderView)
        loaderView.OWSnp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }

        addSubviews(removeButton)
        removeButton.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.removeButtonTopOffset)
            make.trailing.equalToSuperview().offset(-Metrics.removeButtonTrailingOffset)
            make.size.equalTo(Metrics.removeButtonSize)
        }
    }

    func setupObservers() {
        viewModel.outputs.imageOutput
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] imageType in
                guard let self = self else { return }
                switch imageType {
                case .image(let image):
                    self.isHidden = false
                    let ratio = image.size.width / image.size.height
                    let newHeight = self.imageView.frame.width / ratio
                    self.OWSnp.updateConstraints { make in
                        make.height.equalTo(newHeight)
                    }
                    self.imageView.image = image
                case .noImage:
                    self.isHidden = true
                    self.OWSnp.updateConstraints { make in
                        make.height.equalTo(0)
                    }
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowLoadingState
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldShowLoader in
                guard let self = self else { return }
                self.loaderView.isHidden = !shouldShowLoader
                self.imageViewLoadingCoverView.isHidden = !shouldShowLoader
                if shouldShowLoader {
                    self.loaderView.startAnimating()
                } else {
                    self.loaderView.stopAnimating()
                }
            })
            .disposed(by: disposeBag)

        removeButton.rx.tap
            .bind(to: viewModel.inputs.removeButtonTap)
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        imageView.accessibilityIdentifier = Metrics.imageViewIdentifier
        loaderView.accessibilityIdentifier = Metrics.loaderViewIdentifier
        removeButton.accessibilityIdentifier = Metrics.removeButtonIdentifier
    }
}
