//
//  OWPreConversationFooterView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

internal class OWPreConversationFooterView: UIView {
    fileprivate struct Metrics {
        static let identifier = "pre_conversation_footer_id"
        static let termsButtonIdentifier = "pre_conversation_footer_show_terms_button_id"
        static let privacyButtonIdentifier = "pre_conversation_footer_show_privacy_button_id"
        static let poweredByOWButtonIdentifier = "pre_conversation_footer_powered_by_ow_button_id"

        static let fontSize: CGFloat = 13
        static let poweredByFontSize: CGFloat = 11
        static let iconSize: CGFloat = 13
        static let iconTrailingPadding: CGFloat = 5
        static let separatorPadding: CGFloat = 10
    }

    private lazy var termsButton: UIButton = {
        return LocalizationManager.localizedString(key: "Terms")
            .button
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .font(.openSans(style: .regular, of: Metrics.fontSize))
    }()
    private lazy var separator: UILabel = {
        "|"
            .label
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .font(.openSans(style: .regular, of: Metrics.fontSize))
    }()
    private lazy var privacyButton: UIButton = {
        return LocalizationManager.localizedString(key: "Privacy")
            .button
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .font(.openSans(style: .regular, of: Metrics.fontSize))
    }()
    private lazy var openWebIconImageView: UIImageView = {
        return UIImageView(image: UIImage(spNamed: "openwebIconSimple", supportDarkMode: true))
    }()
    private lazy var poweredByOWButton: UIButton = {
        let btn = LocalizationManager.localizedString(key: "Powered by OpenWeb")
            .button
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .font(.openSans(style: .regular, of: Metrics.poweredByFontSize))
        return btn
    }()

    fileprivate let disposeBag = DisposeBag()

    fileprivate let viewModel: OWPreConversationFooterViewModeling

    init(with viewModel: OWPreConversationFooterViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        self.enforceSemanticAttribute()
            .backgroundColor(.clear)

        setupUI()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate extension OWPreConversationFooterView {
    func setupUI() {
        self.addSubview(termsButton)
        termsButton.OWSnp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }

        self.addSubview(separator)
        separator.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(termsButton.OWSnp.trailing).offset(Metrics.separatorPadding)
        }

        self.addSubview(privacyButton)
        privacyButton.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(separator.OWSnp.trailing).offset(Metrics.separatorPadding)
        }

        self.addSubview(poweredByOWButton)
        poweredByOWButton.OWSnp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
        }

        poweredByOWButton.addSubview(openWebIconImageView)
        openWebIconImageView.OWSnp.makeConstraints { make in
            make.size.equalTo(Metrics.iconSize)
            make.top.bottom.leading.equalToSuperview()
            if let buttonTextLeading = poweredByOWButton.titleLabel?.OWSnp.leading {
                make.trailing.equalTo(buttonTextLeading).offset(-Metrics.iconTrailingPadding)
            }
        }
    }

    func setupObservers() {
        termsButton.rx.tap
            .bind(to: viewModel.inputs.termsTapped)
            .disposed(by: disposeBag)

        privacyButton.rx.tap
            .bind(to: viewModel.inputs.privacyTapped)
            .disposed(by: disposeBag)

        poweredByOWButton.rx.tap
            .bind(to: viewModel.inputs.poweredByOWTapped)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.termsButton.textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle))
                self.separator.textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle))
                self.privacyButton.textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle))
                self.openWebIconImageView.image = UIImage(spNamed: "openwebIconSimple", supportDarkMode: true)
                self.poweredByOWButton.textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle))
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        termsButton.accessibilityIdentifier = Metrics.termsButtonIdentifier
        privacyButton.accessibilityIdentifier = Metrics.privacyButtonIdentifier
        poweredByOWButton.accessibilityIdentifier = Metrics.poweredByOWButtonIdentifier
    }
}
