//
//  OWCommentThreadActionsView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 27/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWCommentThreadActionsView: UIView {
    fileprivate struct Metrics {
        static let topOffset: CGFloat = 4.0
        static let horizontalOffset: CGFloat = 16
        static let depthOffset: CGFloat = 23
        static let fontSize: CGFloat = 15.0
        static let cellHeight: CGFloat = 40.0
        static let textToImageSpacing: CGFloat = 6.5
    }

    fileprivate var viewModel: OWCommentThreadActionsViewModeling!
    fileprivate var disposeBag: DisposeBag = DisposeBag()

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
    }

    func prepareForReuse() {
        self.activityIndicator.isHidden = true
        self.disclosureImageView.isHidden = false
    }

    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        return tap
    }()

    fileprivate lazy var actionView: UIView = {
        let view = UIView()

        view.addSubview(actionLabel)
        actionLabel.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(Metrics.topOffset)
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

    fileprivate lazy var actionLabel: UILabel = {
        return UILabel()
            .userInteractionEnabled(false)
            .font(.preferred(style: .medium, of: Metrics.fontSize))
            .textColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
    }()

    fileprivate lazy var disclosureImageView: UIImageView = {
        let image = UIImage(spNamed: "messageDisclosureIndicatorIcon", supportDarkMode: false)!
        return UIImageView(image: image.withRenderingMode(.alwaysTemplate))
            .tintColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
    }()

    fileprivate lazy var activityIndicator: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .gray)
            .isHidden(true)
    }()
}

fileprivate extension OWCommentThreadActionsView {
    func setupUI() {
        self.backgroundColor = .clear

        self.addSubview(actionView)
        self.actionView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
            make.top.bottom.equalToSuperview()
            make.height.equalTo(Metrics.cellHeight)
        }
    }

    func setupObservers() {
        Observable.combineLatest(OWSharedServicesProvider.shared.themeStyleService().style, OWColorPalette.shared.colorDriver)
            .subscribe(onNext: { [weak self] (style, colorMapper) -> Void in
                guard let self = self else { return }
                if let owBrandColor = colorMapper[.brandColor] {
                    let brandColor = owBrandColor.color(forThemeStyle: style)
                    self.actionLabel.textColor = brandColor
                    self.disclosureImageView.tintColor = brandColor
                    self.activityIndicator.color = brandColor
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.actionLabelText
            .bind(to: actionLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.disclosureTransform
            .bind(to: disclosureImageView.rx.transform)
            .disposed(by: disposeBag)

        tapGesture.rx.event.voidify()
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.disclosureImageView.isHidden = true
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
            })
            .bind(to: viewModel.inputs.tap)
            .disposed(by: disposeBag)
    }
}
