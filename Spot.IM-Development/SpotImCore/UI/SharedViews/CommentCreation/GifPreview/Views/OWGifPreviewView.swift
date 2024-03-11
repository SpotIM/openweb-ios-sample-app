//
//  OWGifPreviewView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 04/03/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWGifPreviewView: UIView {
    fileprivate struct Metrics {
        static let identifier = "comment_gif_preview_id"
        static let gifViewIdentifier = "comment_gif_preview_gif_view_id"
        static let removeButtonIdentifier = "comment_gif_preview_remove_button_id"

        static let removeButtonTopOffset: CGFloat = 8.0
        static let removeButtonTrailingOffset: CGFloat = 8.0
        static let removeButtonSize: CGFloat = 45.0
    }

    fileprivate lazy var gifView: GifWebView = {
        return GifWebView()
    }()

    fileprivate lazy var removeButton: UIButton = {
        let button = UIButton()
            .image(UIImage(spNamed: "removeImageIcon", supportDarkMode: false), state: .normal)
        button.contentHorizontalAlignment = .right
        button.contentVerticalAlignment = .top
        return button
    }()

    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: OWGifPreviewViewModeling

    init(with viewModel: OWGifPreviewViewModeling) {
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

fileprivate extension OWGifPreviewView {
    func setupUI() {
        self.enforceSemanticAttribute()

        self.isHidden = true
        self.OWSnp.makeConstraints { make in
            make.height.equalTo(0)
        }

        addSubview(gifView)
        gifView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubviews(removeButton)
        removeButton.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.removeButtonTopOffset)
            make.trailing.equalToSuperview().offset(-Metrics.removeButtonTrailingOffset)
            make.size.equalTo(Metrics.removeButtonSize)
        }
    }

    func setupObservers() {
        // In case data recived before gifView is on screen we need to re-calculate size once its displayed
        Observable.combineLatest(viewModel.outputs.gifDataOutput, gifView.rx.bounds) { data, _ in
            data
        }
        .subscribe(onNext: { [weak self] data in
            guard let self = self else { return }
            if let data = data {
                OWScheduler.runOnMainThreadIfNeeded {
                    self.isHidden = false
                    let ratio = CGFloat(data.originalWidth) / CGFloat(data.originalHeight)
                    let newHeight = self.gifView.frame.width / ratio
                    self.gifView.configure(gifUrl: data.originalUrl)
                    self.OWSnp.updateConstraints { make in
                        make.height.equalTo(newHeight)
                    }
                }
            } else {
                OWScheduler.runOnMainThreadIfNeeded {
                    self.isHidden = true
                    self.gifView.configure(gifUrl: nil)
                    self.OWSnp.updateConstraints { make in
                        make.height.equalTo(0)
                    }
                }
            }
        })
        .disposed(by: disposeBag)

        removeButton.rx.tap
            .bind(to: viewModel.inputs.removeButtonTap)
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        gifView.accessibilityIdentifier = Metrics.gifViewIdentifier
        removeButton.accessibilityIdentifier = Metrics.removeButtonIdentifier
    }
}
