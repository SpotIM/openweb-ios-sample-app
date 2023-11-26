//
//  OWCommunityGuidelinesView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommunityGuidelinesView: UIView {
    fileprivate struct Metrics {
        static let containerCorderRadius: CGFloat = 8
        static let containerHeight: CGFloat = 44
        static let horizontalOffset: CGFloat = 16
        static let verticalOffset: CGFloat = 14
        static let horizontalPadding: CGFloat = 10
        static let iconSize: CGFloat = 16
        static let sideOffset: CGFloat = 20

        static let identifier = "community_guidelines_id"
        static let communityGuidelinesLabelIdentifier = "community_guidelines_label_id"
    }

    fileprivate lazy var titleLabel: UILabel = {
        return UILabel()
            .numberOfLines(0)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var guidelinesContainer: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor1, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .corner(radius: Metrics.containerCorderRadius)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var guidelinesIcon: UIImageView = {
        return UIImageView()
            .contentMode(.scaleAspectFit)
            .wrapContent()
            .image(UIImage(spNamed: "guidelinesIcon", supportDarkMode: false)!)
    }()

    fileprivate var heightConstraint: OWConstraint? = nil
    fileprivate var viewModel: OWCommunityGuidelinesViewModeling!
    fileprivate var disposeBag = DisposeBag()

    // For init when using in Views and not in cells
    init(with viewModel: OWCommunityGuidelinesViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.isUserInteractionEnabled = true
        updateUI()
        setupObservers()
        applyAccessibility()
    }

    // For using in cells that will then call the configure function
    init() {
        super.init(frame: .zero)
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Only when using community guidelines as a cell
    func configure(with viewModel: OWCommunityGuidelinesViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        updateUI()
        setupObservers()
        self.layoutIfNeeded()
    }
}

fileprivate extension OWCommunityGuidelinesView {
    // This function is Called updateUI instead of setupUI since it is designed to be reused for cells -
    // using function configure and here it is also called in init when this class is used as a standalone uiview
    func updateUI() {
        self.backgroundColor = .clear
        self.isHidden = true

        guidelinesContainer.removeFromSuperview()
        guidelinesIcon.removeFromSuperview()
        titleLabel.removeFromSuperview()

        if viewModel.outputs.shouldShowContainer {
            self.addSubview(guidelinesContainer)
            guidelinesContainer.OWSnp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(viewModel.outputs.spacing)
                make.leading.trailing.equalToSuperview()
                heightConstraint = make.height.equalTo(0).constraint
            }

            guidelinesContainer.addSubview(guidelinesIcon)
            guidelinesIcon.OWSnp.makeConstraints { make in
                make.size.equalTo(Metrics.iconSize)
                make.centerY.equalToSuperview().inset(Metrics.verticalOffset)
                make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            }

            guidelinesContainer.addSubview(titleLabel)
            titleLabel.OWSnp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(Metrics.horizontalPadding)
                make.leading.equalTo(guidelinesIcon.OWSnp.trailing).offset(Metrics.horizontalPadding)
                make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            }
        } else {
            self.addSubview(titleLabel)
            titleLabel.OWSnp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(viewModel.outputs.spacing)
                make.leading.trailing.equalToSuperview()
                heightConstraint = make.height.equalTo(0).constraint
            }
        }
    }

    func setupObservers() {
        viewModel.outputs.shouldShowView
            .map { !$0 }
            .bind(to: self.rx.isHidden)
            .disposed(by: disposeBag)

        if let heightConstraint = heightConstraint {
            viewModel.outputs.shouldShowView
                .map { !$0 }
                .bind(to: heightConstraint.rx.isActive)
                .disposed(by: disposeBag)
        }

        let communityGuidelinesClickableStringObservable = viewModel.outputs
            .communityGuidelinesClickableString

        let communityGuidelinesAttributedStringObservable = viewModel.outputs
            .communityGuidelinesAttributedString

        Observable.combineLatest(communityGuidelinesAttributedStringObservable,
                                 communityGuidelinesClickableStringObservable)
            .subscribe(onNext: { [weak self] attributedText, clickableString in
                guard let self = self else { return }
                self.titleLabel
                    .attributedText(attributedText)
                    .addRangeGesture(targetRange: clickableString) { [weak self] in
                        guard let self = self else { return }
                        self.viewModel.inputs.urlClicked.onNext(())
                    }
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.guidelinesContainer.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor1, themeStyle: currentStyle)
                self.updateCustomUI()
            })
            .disposed(by: disposeBag)
    }

    func updateCustomUI() {
        viewModel.inputs.triggerCustomizeContainerViewUI.onNext(guidelinesContainer)
        viewModel.inputs.triggerCustomizeTitleLabelUI.onNext(titleLabel)
        viewModel.inputs.triggerCustomizeIconImageViewUI.onNext(guidelinesIcon)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        titleLabel.accessibilityIdentifier = Metrics.communityGuidelinesLabelIdentifier
    }
}
