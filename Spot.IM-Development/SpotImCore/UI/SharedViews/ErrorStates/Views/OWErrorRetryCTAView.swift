//
//  OWErrorRetryCTAView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 25/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWErrorRetryCTAView: UIView {
    fileprivate struct Metrics {
        static let ctaVerticalPadding: CGFloat = 5
        static let ctaHorizontalPadding: CGFloat = 4
        static let retryIconSize: CGFloat = 14

        static let identifier = "error_state_cta_view_id"
        static let retryIconIdentifier = "error_state_retry_image_view_id"
        static let ctaLabelIdentifier = "error_state_cta_label_id"
    }

    fileprivate var attributedString: NSAttributedString {
        return NSAttributedString(
            string: OWLocalizationManager.shared.localizedString(key: "TryAgain"),
            attributes: [
                .font: OWFontBook.shared.font(typography: .bodyInteraction),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ])
    }

    fileprivate lazy var ctaLabel: UILabel = {
        return UILabel()
            .textColor(OWColorPalette.shared.color(type: .textColor7, themeStyle: .light))
            .attributedText(attributedString)
    }()

    fileprivate lazy var retryIcon: UIImageView = {
       return UIImageView()
            .contentMode(.scaleAspectFit)
            .image(UIImage(spNamed: "errorStateRetryIcon", supportDarkMode: false)!)
    }()

    fileprivate let disposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)
        self.setupUI()
        self.setupObservers()
        self.applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWErrorRetryCTAView {
    func setupUI() {
        self.addSubview(ctaLabel)
        ctaLabel.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.bottom.top.equalToSuperview().inset(Metrics.ctaVerticalPadding)
        }

        self.addSubview(retryIcon)
        retryIcon.OWSnp.makeConstraints { make in
            make.leading.equalTo(ctaLabel.OWSnp.trailing).offset(Metrics.ctaHorizontalPadding)
            make.size.equalTo(Metrics.retryIconSize)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.ctaLabel.textColor = OWColorPalette.shared.color(type: .textColor7, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.ctaLabel.attributedText = self.attributedString
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        retryIcon.accessibilityIdentifier = Metrics.retryIconIdentifier
        ctaLabel.accessibilityIdentifier = Metrics.ctaLabelIdentifier
    }
}
