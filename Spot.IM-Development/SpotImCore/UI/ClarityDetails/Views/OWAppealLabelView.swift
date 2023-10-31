//
//  OWAppealLabelView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 31/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWAppealLabelView: UIView {
    fileprivate struct Metrics {
        static let cornerRadius: CGFloat = 5
        static let borderWidth: CGFloat = 1
        static let padding: CGFloat = 15
        static let skeletonHeight: CGFloat = 48
        static let skeletonCornerRadius: CGFloat = 10
        static let iconSize: CGFloat = 24
    }

    fileprivate let disposeBag: DisposeBag
    fileprivate let viewModel: OWAppealLabelViewModeling

    fileprivate lazy var skeletonContentView: UIView = {
        return UIView()
            .corner(radius: Metrics.skeletonCornerRadius)
            .backgroundColor(OWColorPalette.shared.color(type: .skeletonColor, themeStyle: .light))
    }()
    fileprivate lazy var skelatonView: OWSkeletonShimmeringView = {
        let view = OWSkeletonShimmeringView()
        view.enforceSemanticAttribute()
        view.addSubview(skeletonContentView)
        skeletonContentView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(Metrics.skeletonHeight)
        }
        return view
    }()

    fileprivate lazy var defaultLabel: UILabel = {
        return UILabel()
            .numberOfLines(0)
    }()

    fileprivate lazy var icon: UIImageView = {
        return UIImageView()
    }()
    fileprivate lazy var label: UILabel = {
        return UILabel()
            .numberOfLines(0)
    }()
    fileprivate lazy var iconAndLabelView: UIView = {
        let view = UIView()
        view.addSubview(icon)
        icon.OWSnp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.height.equalTo(Metrics.iconSize)
        }

        view.addSubview(label)
        label.OWSnp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.leading.equalTo(icon.OWSnp.trailing).offset(Metrics.padding)
        }

        return view
    }()

    init(viewModel: OWAppealLabelViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        super.init(frame: .zero)

        setupViews()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWAppealLabelView {
    func setupViews() {
        self.enforceSemanticAttribute()
        self.corner(radius: Metrics.cornerRadius)
        self.backgroundColor = OWColorPalette.shared.color(type: .skeletonColor, themeStyle: .light)

        skelatonView.addSkeletonShimmering()
    }

    func setupObservers() {
        viewModel.outputs.viewType
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                var contentView: UIView
                switch type {
                case .skeleton:
                    contentView = self.skelatonView
                case .default:
                    contentView = self.defaultLabel
                case .appealRejected, .error, .unavailable:
                    contentView = self.iconAndLabelView
                }
                self.subviews.forEach { $0.removeFromSuperview() }
                self.addSubview(contentView)
                contentView.OWSnp.makeConstraints { make in
                    make.edges.equalToSuperview().inset(Metrics.padding)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.backgroundColor
            .bind(to: self.rx.backgroundColor)
            .disposed(by: disposeBag)

        viewModel.outputs.borderColor
            .subscribe(onNext: { [weak self] borderColor in
                self?.border(width: Metrics.borderWidth, color: borderColor)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.defaultAttributedText
            .subscribe(onNext: { [weak self] attributedText in
                guard let self = self else { return }
                self.defaultLabel
                    .attributedText(attributedText)
                    .addRangeGesture(targetRange: self.viewModel.outputs.appealClickableText) { [weak self] in
                        guard let self = self else { return }
//                        self.viewModel.inputs.communityGuidelinesClick.onNext() // TODO: click
                    }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.iconImage
            .bind(to: icon.rx.image)
            .disposed(by: disposeBag)

        viewModel.outputs.labelAttributedString
            .bind(to: label.rx.attributedText)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.skeletonContentView.backgroundColor = OWColorPalette.shared.color(type: .skeletonColor, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }
}
