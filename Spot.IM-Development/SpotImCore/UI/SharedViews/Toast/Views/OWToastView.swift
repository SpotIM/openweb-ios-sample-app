//
//  OWToastView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 20/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWToastView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "toast_view_id"

        static let cornerRadius: CGFloat = 8
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 8
        static let iconSize: CGFloat = 24
        static let textSize: CGFloat = 15
        static let messageLeadingPadding: CGFloat = 8
        static let actionLeadingPadding: CGFloat = 12
    }

    fileprivate lazy var iconImageView: UIImageView = {
        return UIImageView()
            .image(viewModel.outputs.iconImage)
    }()

    fileprivate lazy var messageLabel: UILabel = {
        return UILabel()
            .text(viewModel.outputs.title)
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .font(OWFontBook.shared.font(typography: .bodyText))
    }()

    fileprivate lazy var actionView: OWToastActionView = {
        return OWToastActionView(viewModel: viewModel.outputs.toastActionViewModel)
    }()

    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        actionView.addGestureRecognizer(tap)
        return tap
    }()

    fileprivate var viewModel: OWToastViewModeling
    fileprivate var disposeBag = DisposeBag()

    init(viewModel: OWToastViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        applyIdentifiers()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWToastView {
    func setupViews() {
        self.useAsThemeStyleInjector()

        self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: .light)
        self.layer.borderWidth = 1
        self.layer.borderColor = viewModel.outputs.borderColor.cgColor
        self.layer.cornerRadius = Metrics.cornerRadius
        self.apply(shadow: .standard)

        self.addSubview(iconImageView)
        iconImageView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Metrics.horizontalPadding)
            make.top.bottom.equalToSuperview().inset(Metrics.verticalPadding)
            make.size.equalTo(Metrics.iconSize)
        }

        self.addSubview(messageLabel)
        messageLabel.OWSnp.makeConstraints { make in
            make.leading.equalTo(iconImageView.OWSnp.trailing).offset(Metrics.messageLeadingPadding)
            make.centerY.equalToSuperview()
        }

        self.addSubview(actionView)
        actionView.OWSnp.makeConstraints { make in
            make.leading.equalTo(messageLabel.OWSnp.trailing).offset(Metrics.actionLeadingPadding)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(viewModel.outputs.showAction ? Metrics.horizontalPadding : 0)
            if (!viewModel.outputs.showAction) {
                make.width.equalTo(0)
            }
        }
    }

    func setupObservers() {
        tapGesture.rx.event.voidify()
            .bind(to: viewModel.inputs.actionClick)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.messageLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }

    func applyIdentifiers() {
        self.accessibilityIdentifier = Metrics.identifier
    }
}
