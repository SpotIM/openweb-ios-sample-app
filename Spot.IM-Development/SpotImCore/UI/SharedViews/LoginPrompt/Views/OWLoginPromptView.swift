//
//  OWLoginPromptView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 17/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWLoginPromptView: UIView {
    fileprivate struct Metrics {
        static let identifier = "login_promt_view_id"

        static let labelHorizontalPadding: CGFloat = 4
        static let horizontalOffset: CGFloat = 10
        static let verticalOffset: CGFloat = 16
        static let separatorHeight: CGFloat = 1
    }

    fileprivate lazy var icon: UIImageView = {
       return UIImageView()
            .contentMode(.scaleAspectFit)
            .wrapContent()
            .image(UIImage(spNamed: "loginPromptIcon", supportDarkMode: false)!)
            .tintColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
    }()

    fileprivate lazy var label: UILabel = {
        return UILabel()
            .attributedText(
                OWLocalizationManager.shared.localizedString(key: "LoginPromptTitle")
                    .attributedString
                    .underline(1)
            )
            .font(OWFontBook.shared.font(typography: .bodyInteraction))
            .textColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
    }()

    fileprivate lazy var arrow: UIImageView = {
        return UIImageView()
            .contentMode(.scaleAspectFit)
            .wrapContent()
            .image(UIImage(spNamed: "loginPromptArrow", supportDarkMode: false)!)
            .tintColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var loginPromptView: UIView = {
        let view = UIView()

        view.addSubview(icon)
        icon.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }

        view.addSubview(label)
        label.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(icon.OWSnp.trailing).offset(Metrics.labelHorizontalPadding)
        }

        view.addSubview(arrow)
        arrow.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(label.OWSnp.trailing).offset(Metrics.labelHorizontalPadding)
            make.trailing.equalToSuperview()
        }

        return view
    }()

    fileprivate lazy var seperatorView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor3, themeStyle: .light))
    }()

    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true

        return tap
    }()

    fileprivate var zeroHeighConstraint: OWConstraint? = nil
    fileprivate var zeroWidthConstraint: OWConstraint? = nil

    fileprivate var viewModel: OWLoginPromptViewModeling
    fileprivate var disposeBag: DisposeBag

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

fileprivate extension OWLoginPromptView {
    func setupUI() {
        self.enforceSemanticAttribute()

        self.OWSnp.makeConstraints { make in
            zeroHeighConstraint = make.height.equalTo(0).constraint
            zeroWidthConstraint = make.width.equalTo(0).constraint
        }

        self.addSubview(loginPromptView)
        loginPromptView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.lessThanOrEqualToSuperview()

            switch viewModel.outputs.style {
            case .center:
                make.leading.greaterThanOrEqualToSuperview()
                make.centerX.equalToSuperview()

            case .left:
                make.leading.equalToSuperviewSafeArea().inset(Metrics.verticalOffset)
            }
        }

        self.addSubview(seperatorView)
        seperatorView.OWSnp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(Metrics.verticalOffset)
            make.top.equalTo(loginPromptView.OWSnp.bottom).offset(Metrics.horizontalOffset)
            make.height.equalTo(Metrics.separatorHeight)
        }
    }

    func setupObservers() {
        viewModel.outputs.shouldShowView
            .map { !$0 }
            .bind(to: self.rx.isHidden)
            .disposed(by: disposeBag)

        if let heighConstraint = zeroHeighConstraint {
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
                self.label.font = OWFontBook.shared.font(typography: .bodyInteraction)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .withLatestFrom(OWSharedServicesProvider.shared.orientationService().orientation) { ($0, $1) }
            .subscribe(onNext: { [weak self] currentStyle, currentOrientation in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.seperatorView.backgroundColor = OWColorPalette.shared.color(type: currentOrientation == .landscape ? .separatorColor1 : .separatorColor3, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }
}
