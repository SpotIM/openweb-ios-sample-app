//
//  OWUserStatusAutomationView.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if AUTOMATION

import UIKit
import RxSwift
import RxCocoa

class OWUserStatusAutomationView: UIView, OWThemeStyleInjectorProtocol {

    fileprivate struct Metrics {
        static let horizontalOffset: CGFloat = 20
        static let verticalOffset: CGFloat = 20
        static let activeSpotIdBaseText: String = OWLocalizationManager.shared.localizedString(key: "ActiveSpotId") + ": "
        static let activePostIdBaseText: String = OWLocalizationManager.shared.localizedString(key: "ActivePostId") + ": "
        static let userStatusBaseText: String = OWLocalizationManager.shared.localizedString(key: "UserStatus") + ": "
        static let identifier = "user_status_automation_view_id"
        static let activeSpotIdentifier = "active_spot_id"
        static let activePostIdentifier = "active_post_id"
        static let userStatusIdentifier = "user_status_id"
    }

    fileprivate let disposeBag = DisposeBag()
    fileprivate var viewModel: OWUserStatusAutomationViewViewModeling!

    fileprivate lazy var activeSpotIdLbl: UILabel = {
        return UILabel()
            .text(Metrics.activeSpotIdBaseText)
            .font(OWFontBook.shared.font(typography: .bodyText))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
            .numberOfLines(0)
    }()

    fileprivate lazy var activePostIdLbl: UILabel = {
        return UILabel()
            .text(Metrics.activePostIdBaseText)
            .font(OWFontBook.shared.font(typography: .bodyText))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
            .numberOfLines(0)
    }()

    fileprivate lazy var userStatusLbl: UILabel = {
        return UILabel()
            .text(Metrics.userStatusBaseText)
            .font(OWFontBook.shared.font(typography: .bodyText))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
            .numberOfLines(0)
    }()

    init(viewModel: OWUserStatusAutomationViewViewModeling) {
        super.init(frame: .zero)
        self.viewModel = viewModel

        setupUI()
        applyAccessibility()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWUserStatusAutomationView {
    func setupUI() {
        self.useAsThemeStyleInjector()

        self.addSubview(activeSpotIdLbl)
        activeSpotIdLbl.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.verticalOffset)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
        }

        self.addSubview(activePostIdLbl)
        activePostIdLbl.OWSnp.makeConstraints { make in
            make.top.equalTo(activeSpotIdLbl.OWSnp.bottom).offset(Metrics.verticalOffset)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
        }

        self.addSubview(userStatusLbl)
        userStatusLbl.OWSnp.makeConstraints { make in
            make.top.equalTo(activePostIdLbl.OWSnp.bottom).offset(Metrics.verticalOffset)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let font = OWFontBook.shared.font(typography: .bodyText)
                self.activeSpotIdLbl.font = font
                self.activePostIdLbl.font = font
                self.userStatusLbl.font = font
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                let textColor = OWColorPalette.shared.color(type: .textColor1, themeStyle: currentStyle)
                self.activeSpotIdLbl.textColor = textColor
                self.activePostIdLbl.textColor = textColor
                self.userStatusLbl.textColor = textColor
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        activeSpotIdLbl.accessibilityIdentifier = Metrics.activeSpotIdentifier
        activePostIdLbl.accessibilityIdentifier = Metrics.activePostIdentifier
        userStatusLbl.accessibilityIdentifier = Metrics.userStatusIdentifier
    }
}

#endif
