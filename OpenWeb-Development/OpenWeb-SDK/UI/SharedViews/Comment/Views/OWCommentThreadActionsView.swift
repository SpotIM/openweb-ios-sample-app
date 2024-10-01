//
//  OWCommentThreadActionsView.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 27/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWCommentThreadActionsView: UIView {
    private struct Metrics {
        static let identifier = "comment_thread_actions_view_id_"
        static let actionViewIdentifier = "comment_thread_actions_view_action_view_id_"
        static let actionLabelIdentifier = "comment_thread_actions_view_action_label_id_"
        static let horizontalOffset: CGFloat = 16
        static let depthOffset: CGFloat = 23
        static let textToImageSpacing: CGFloat = 6.5
    }

    private var viewModel: OWCommentThreadActionsViewModeling!
    private var disposeBag: DisposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: OWCommentThreadActionsViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        self.setupObservers()
        self.applyAccessibility()
    }

    func prepareForReuse() {
        self.activityIndicator.isHidden = true
        self.disclosureImageView.isHidden = false
    }

    private lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        return tap
    }()

    private lazy var actionView: UIView = {
        let view = UIView()

        view.addSubview(actionLabel)
        actionLabel.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        view.addSubview(disclosureImageView)
        disclosureImageView.OWSnp.makeConstraints { make in
            make.leading.equalTo(actionLabel.OWSnp.trailing).offset(Metrics.textToImageSpacing)
            make.centerY.equalTo(actionLabel.OWSnp.centerY)
        }

        view.addSubview(activityIndicator)
        activityIndicator.OWSnp.makeConstraints { make in
            make.leading.equalTo(actionLabel.OWSnp.trailing).offset(Metrics.textToImageSpacing)
            make.centerY.equalTo(actionLabel.OWSnp.centerY)
        }

        return view
            .enforceSemanticAttribute()
    }()

    private lazy var actionLabel: UILabel = {
        return UILabel()
            .userInteractionEnabled(false)
            .font(OWFontBook.shared.font(typography: .bodyInteraction))
            .textColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
    }()

    private lazy var disclosureImageView: UIImageView = {
        return UIImageView()
            .tintColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .gray)
            .isHidden(true)
    }()
}

private extension OWCommentThreadActionsView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier + viewModel.outputs.commentId
        actionView.accessibilityIdentifier = Metrics.actionViewIdentifier + viewModel.outputs.commentId
        actionLabel.accessibilityIdentifier = Metrics.actionLabelIdentifier + viewModel.outputs.commentId
    }

    func setupUI() {
        self.backgroundColor = .clear

        self.addSubview(actionView)
        self.actionView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func setupObservers() {
        Observable.combineLatest(OWSharedServicesProvider.shared.themeStyleService().style, OWColorPalette.shared.colorDriver)
            .subscribe(onNext: { [weak self] style, colorMapper in
                guard let self else { return }
                if let owBrandColor = colorMapper[.brandColor] {
                    let brandColor = owBrandColor.color(forThemeStyle: style)
                    self.actionLabel.textColor = brandColor
                    self.disclosureImageView.tintColor = brandColor
                    self.activityIndicator.color = brandColor
                }
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.actionLabel.font = OWFontBook.shared.font(typography: .bodyInteraction)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.disclosureImage
            .subscribe(onNext: { [weak self] image in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self else { return }
                    self.disclosureImageView.image = image.withRenderingMode(.alwaysTemplate)
                }
            })
            .disposed(by: disposeBag)

        // Update bottom spacing
        viewModel.outputs.updateSpacing
            .subscribe(onNext: { [weak self] spacing in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self else { return }
                    self.actionView.OWSnp.updateConstraints { make in
                        make.top.equalToSuperview().inset(spacing.top)
                        make.bottom.equalToSuperview().inset(spacing.bottom)
                    }
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.actionLabelText
            .subscribe(onNext: { [weak self] text in
                OWScheduler.runOnMainThreadIfNeeded {
                    self?.actionLabel.text = text
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.disclosureTransform
            .bind(to: disclosureImageView.rx.transform)
            .disposed(by: disposeBag)

        tapGesture.rx.event.voidify()
            .observe(on: MainScheduler.instance)
            .bind(to: viewModel.inputs.tap)
            .disposed(by: disposeBag)

        viewModel.outputs.isLoadingChanged
            .subscribe(onNext: { [weak self] isLoading in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self else { return }
                    self.disclosureImageView.isHidden = isLoading
                    self.activityIndicator.isHidden = !isLoading

                    if isLoading {
                        self.activityIndicator.startAnimating()
                    } else {
                        self.activityIndicator.stopAnimating()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
