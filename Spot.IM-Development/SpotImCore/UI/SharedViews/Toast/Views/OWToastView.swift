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
    }

    fileprivate lazy var iconImageView: UIImageView = {
        return UIImageView()
    }()

    fileprivate lazy var messageLabel: UILabel = {
        return UILabel()
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.textSize))
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
        self.layer.borderColor = OWColorPalette.shared.color(type: .borderColor1, themeStyle: .light).cgColor
        self.layer.cornerRadius = Metrics.cornerRadius
        self.applyShadow()

        iconImageView.image = viewModel.outputs.iconImage
        self.addSubview(iconImageView)
        iconImageView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Metrics.horizontalPadding)
            make.top.bottom.equalToSuperview().inset(Metrics.verticalPadding)
            make.size.equalTo(Metrics.iconSize)
        }

        messageLabel.text = viewModel.outputs.title
        self.addSubview(messageLabel)
        messageLabel.OWSnp.makeConstraints { make in
            make.leading.equalTo(iconImageView.OWSnp.trailing).offset(Metrics.messageLeadingPadding)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }

    func applyShadow() {
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.07).cgColor
        layer.shadowRadius = 20
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.masksToBounds = false
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.layer.borderColor = OWColorPalette.shared.color(type: .borderColor1, themeStyle: currentStyle).cgColor
                self.messageLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }

    func applyIdentifiers() {
        self.accessibilityIdentifier = Metrics.identifier
    }
}
