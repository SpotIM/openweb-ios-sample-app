//
//  OWCommentCreationFooterView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 18/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

class OWCommentCreationFooterView: UIView {
    fileprivate struct Metrics {
        static let identifier = "comment_footer_view_id"
        static let ctaButtonIdentifier = "comment_footer_view_post_button_id"
        static let addImageButtonIdentifier = "comment_footer_view_add_image_button_id"

        static let seperatorHeight: CGFloat = 1.0

        static let ctaButtonCornerRadius: CGFloat = 5.0
        static let ctaButtonHorizontalContentInset: CGFloat = 15.0
        static let ctaButtonHight: CGFloat = 40.0
        static let ctaButtonEnabledAlpha: CGFloat = 1
        static let ctaButtonDisabledAlpha: CGFloat = 0.5

        static let horizontalPortraitMargin: CGFloat = 16.0
        static let horizontalLandscapeMargin: CGFloat = 66.0

        static let addImageButtonHeight: CGFloat = 16.0 + (6.0 * 2)
        static let addImageButtonWidth: CGFloat = 18.0 + (6.0 * 2)
        static let addImageButtonInset: CGFloat = 6.0
    }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: OWCommentCreationFooterViewModeling

    fileprivate lazy var seperatorView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor4, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var ctaButton: OWLoaderButton = {
        let button = OWLoaderButton()
            .backgroundColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .font(OWFontBook.shared.font(typography: .bodyText))
            .corner(radius: Metrics.ctaButtonCornerRadius)
            .contentEdgeInsets(UIEdgeInsets(
                top: 0,
                left: Metrics.ctaButtonHorizontalContentInset,
                bottom: 0,
                right: Metrics.ctaButtonHorizontalContentInset
            ))
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    fileprivate lazy var addImageButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: "addImageIcon"), state: .normal)
            .imageEdgeInsets(UIEdgeInsets(
                top: Metrics.addImageButtonInset,
                left: Metrics.addImageButtonInset,
                bottom: Metrics.addImageButtonInset,
                right: Metrics.addImageButtonInset
            ))
    }()

    fileprivate lazy var commentLabelsContainerView: OWCommentLabelsContainerView = {
        return OWCommentLabelsContainerView()
    }()

    init(with viewModel: OWCommentCreationFooterViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        setupUI()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureCommentLabels(viewModel: OWCommentLabelsContainerViewModeling) {
        self.commentLabelsContainerView.configure(viewModel: viewModel)
    }
}

fileprivate extension OWCommentCreationFooterView {
    func setupUI() {
        self.enforceSemanticAttribute()

        addSubview(seperatorView)
        seperatorView.OWSnp.makeConstraints { make in
            make.height.equalTo(Metrics.seperatorHeight)
            make.leading.trailing.top.equalToSuperview()
        }

        let currentOrientation = OWSharedServicesProvider.shared.orientationService().currentOrientation
        let isLandscape = currentOrientation == .landscape

        addSubview(ctaButton)
        ctaButton.OWSnp.makeConstraints { make in
            make.centerY.equalTo(OWSnp.centerY)
            make.height.equalTo(Metrics.ctaButtonHight)
            make.trailing.equalToSuperviewSafeArea().offset(isLandscape ? -Metrics.horizontalLandscapeMargin : -Metrics.horizontalPortraitMargin)
        }

        addSubview(addImageButton)
        addImageButton.OWSnp.makeConstraints { make in
            make.centerY.equalTo(OWSnp.centerY)
            make.leading.equalToSuperviewSafeArea().offset(isLandscape ? Metrics.horizontalLandscapeMargin : Metrics.horizontalPortraitMargin)
            make.height.equalTo(Metrics.addImageButtonHeight)
            make.width.equalTo(Metrics.addImageButtonWidth)
        }

        self.addSubview(commentLabelsContainerView)
        commentLabelsContainerView.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(addImageButton.OWSnp.trailing).offset(10.0)
            make.trailing.lessThanOrEqualTo(ctaButton.OWSnp.leading).offset(10.0)
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.seperatorView.backgroundColor = OWColorPalette.shared.color(type: .separatorColor4, themeStyle: currentStyle)

                self.updateCustomUI()
            }).disposed(by: disposeBag)

        ctaButton.rx.tap
            .bind(to: viewModel.inputs.tapCta)
            .disposed(by: disposeBag)

        viewModel.outputs.ctaButtonEnabled
            .bind(to: ctaButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.outputs.ctaButtonEnabled
            .map { $0 ? Metrics.ctaButtonEnabledAlpha : Metrics.ctaButtonDisabledAlpha }
            .bind(to: ctaButton.rx.alpha)
            .disposed(by: disposeBag)

        viewModel.outputs.ctaTitleText
            .bind(to: ctaButton.rx.title())
            .disposed(by: disposeBag)

        addImageButton.rx.tap
            .bind(to: viewModel.inputs.tapAddImage)
            .disposed(by: disposeBag)

        viewModel.outputs.showAddImageButton
            .map { !$0 }
            .bind(to: addImageButton.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.ctaButtonLoading
            .bind(to: ctaButton.rx.isLoading)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.ctaButton.titleLabel?.font = OWFontBook.shared.font(typography: .bodyText)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.orientationService()
            .orientation
            .subscribe(onNext: { [weak self] currentOrientation in
                guard let self = self else { return }

                let isLandscape = currentOrientation == .landscape
                self.commentLabelsContainerView.isHidden = !isLandscape

                self.ctaButton.OWSnp.updateConstraints { make in
                    make.trailing.equalToSuperviewSafeArea().offset(isLandscape ? -Metrics.horizontalLandscapeMargin : -Metrics.horizontalPortraitMargin)
                }

                self.addImageButton.OWSnp.updateConstraints { make in
                    make.leading.equalToSuperviewSafeArea().offset(isLandscape ? Metrics.horizontalLandscapeMargin : Metrics.horizontalPortraitMargin)
                }
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        ctaButton.accessibilityIdentifier = Metrics.ctaButtonIdentifier
        addImageButton.accessibilityIdentifier = Metrics.addImageButtonIdentifier
    }

    func updateCustomUI() {
        viewModel.inputs.triggerCustomizeSubmitButtonUI.onNext(ctaButton)
    }
}
