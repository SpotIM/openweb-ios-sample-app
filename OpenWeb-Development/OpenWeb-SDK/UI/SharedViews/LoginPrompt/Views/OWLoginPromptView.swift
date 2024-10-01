//
//  OWLoginPromptView.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 17/10/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWLoginPromptView: UIView {
    private struct Metrics {
        static let identifier = "login_promt_view_id"

        static let labelHorizontalPadding: CGFloat = 4
        static let horizontalOffset: CGFloat = 16
        static let verticalOffset: CGFloat = 10
        static let separatorHeight: CGFloat = 1
        static let lockIconSize: CGFloat = 24
        static let arrowIconSize: CGFloat = 12
    }

    private lazy var lockIconImangeView: UIImageView = {
       return UIImageView()
            .contentMode(.scaleAspectFit)
            .wrapContent()
            .image(UIImage(spNamed: "loginPromptLock", supportDarkMode: false)!)
            .tintColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
    }()

    private lazy var titleLabel: UILabel = {
        return UILabel()
            .attributedText(
                OWLocalizationManager.shared.localizedString(key: "LoginPromptTitle")
                    .attributedString
                    .underline(1)
            )
            .font(OWFontBook.shared.font(typography: .bodyInteraction))
            .textColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
    }()

    private lazy var arrowIconImangeView: UIImageView = {
        return UIImageView()
            .contentMode(.scaleAspectFit)
            .wrapContent()
            .image(UIImage(spNamed: "loginPromptArrow", supportDarkMode: false)!)
            .tintColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
            .enforceSemanticAttribute()
    }()

    private lazy var loginPromptView: UIView = {
        let view = UIView()

        view.addSubview(lockIconImangeView)
        lockIconImangeView.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.size.equalTo(Metrics.lockIconSize)
        }

        view.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(lockIconImangeView.OWSnp.trailing).offset(Metrics.labelHorizontalPadding)
        }

        view.addSubview(arrowIconImangeView)
        arrowIconImangeView.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(titleLabel.OWSnp.trailing).offset(Metrics.labelHorizontalPadding)
            make.trailing.equalToSuperview()
            make.size.equalTo(Metrics.arrowIconSize)
        }

        return view
    }()

    private lazy var seperatorView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor3, themeStyle: .light))
    }()

    private lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true

        return tap
    }()

    private var zeroHeightConstraint: OWConstraint?
    private var zeroWidthConstraint: OWConstraint?

    private var viewModel: OWLoginPromptViewModeling
    private var disposeBag: DisposeBag

    init(with viewModel: OWLoginPromptViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        super.init(frame: .zero)
        setupUI()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OWLoginPromptView {
    func setupUI() {
        self.enforceSemanticAttribute()

        self.OWSnp.makeConstraints { make in
            zeroHeightConstraint = make.height.equalTo(0).constraint
            zeroWidthConstraint = make.width.equalTo(0).constraint
        }

        self.addSubview(loginPromptView)
        loginPromptView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.verticalOffset)
            make.trailing.lessThanOrEqualToSuperview()

            switch viewModel.outputs.style {
            case .center:
                make.leading.greaterThanOrEqualToSuperview()
                make.centerX.equalToSuperview()

            case .left, .leftWithoutSeperator:
                make.leading.equalToSuperviewSafeArea().inset(Metrics.horizontalOffset)
            }
        }

        self.addSubview(seperatorView)
        seperatorView.OWSnp.makeConstraints { make in
            make.top.equalTo(loginPromptView.OWSnp.bottom).offset(Metrics.verticalOffset)
            switch viewModel.outputs.style {
            case .left:
                make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)

            case .leftWithoutSeperator, .center:
                make.leading.trailing.equalToSuperview()
            }
            make.height.equalTo(Metrics.separatorHeight)
            make.bottom.equalToSuperview()
        }
    }

    func setupObservers() {
        viewModel.outputs.shouldShowView
            .map { !$0 }
            .bind(to: self.rx.isHidden)
            .disposed(by: disposeBag)

        if let heighConstraint = zeroHeightConstraint {
            viewModel.outputs.shouldShowView
                .map { !$0 }
                .bind(to: heighConstraint.rx.isActive)
                .disposed(by: disposeBag)
        }

        if let widthConstraint = zeroWidthConstraint {
            viewModel.outputs.shouldShowView
                .map { !$0 }
                .bind(to: widthConstraint.rx.isActive)
                .disposed(by: disposeBag)
        }

        tapGesture.rx.event
            .voidify()
            .bind(to: viewModel.inputs.loginPromptTap)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.titleLabel.font = OWFontBook.shared.font(typography: .bodyInteraction)
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(OWSharedServicesProvider.shared.themeStyleService().style,
                                 OWSharedServicesProvider.shared.orientationService().orientation,
                                 OWColorPalette.shared.colorDriver)
            .subscribe(onNext: { [weak self] currentStyle, currentOrientation, colorMapper in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.seperatorView.backgroundColor = OWColorPalette.shared.color(type: currentOrientation == .landscape ? .separatorColor1 : .separatorColor3, themeStyle: currentStyle)

                if let owBrandColor = colorMapper[.brandColor] {
                    let brandColor = owBrandColor.color(forThemeStyle: currentStyle)
                    self.lockIconImangeView.tintColor = brandColor
                    self.arrowIconImangeView.tintColor = brandColor
                    self.titleLabel.textColor = brandColor
                }
                self.updateCustomUI()
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }

    func updateCustomUI() {
        viewModel.inputs.triggerCustomizeLockIconImageViewUI.onNext(lockIconImangeView)
        viewModel.inputs.triggerCustomizeTitleLabelUI.onNext(titleLabel)
        viewModel.inputs.triggerCustomizeArrowIconImageViewUI.onNext(arrowIconImangeView)
    }
}
