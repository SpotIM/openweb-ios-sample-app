//
//  OWTitleSubtitleIconView.swift
//  SpotImCore
//
//  Created by Refael Sommer on 27/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol OWTitleSubtitleIconViewInputs {

}

class OWTitleSubtitleIconView: UIView, OWTitleSubtitleIconViewInputs {
    fileprivate struct Metrics {
        static let titleIconSize: CGFloat = 40
        static let titleFontSize: CGFloat = 20
        static let subtitleFontSize: CGFloat = 15
        static let verticalSpacing: CGFloat = 10
    }
    var inputs: OWTitleSubtitleIconViewInputs { return self }
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var titleIcon: UIImageView = {
        return UIImageView()
            .contentMode(.scaleAspectFit)

    }()

    fileprivate lazy var titleLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(style: .bold, size: Metrics.titleFontSize))
            .numberOfLines(0)
            .textAlignment(.center)
            .textColor(OWColorPalette.shared.color(type: .textColor1,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var subtitleLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.subtitleFontSize))
            .numberOfLines(0)
            .textAlignment(.center)
            .textColor(OWColorPalette.shared.color(type: .textColor2,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    init(iconName: String, title: String, subtitle: String, accessibilityPrefixId: String) {
        super.init(frame: .zero)
        setupViews(iconName: iconName, title: title, subtitle: subtitle)
        setupObservers()
        applyAccessibility(prefixId: accessibilityPrefixId)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWTitleSubtitleIconView {
    func applyAccessibility(prefixId: String) {
        titleIcon.accessibilityIdentifier = prefixId + "_title_icon_id"
        titleLabel.accessibilityIdentifier = prefixId + "_title_label_id"
        subtitleLabel.accessibilityIdentifier = prefixId + "_subtitle_label_id"
    }

    func setupViews(iconName: String, title: String, subtitle: String) {
        self.addSubviews(titleIcon)
        titleIcon.OWSnp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(Metrics.titleIconSize)
        }

        self.addSubviews(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.top.equalTo(titleIcon.OWSnp.bottom).offset(Metrics.verticalSpacing)
            make.leading.trailing.equalToSuperview()
        }

        self.addSubviews(subtitleLabel)
        subtitleLabel.OWSnp.makeConstraints { make in
            make.top.equalTo(titleLabel.OWSnp.bottom).offset(Metrics.verticalSpacing)
            make.leading.trailing.bottom.equalToSuperview()
        }

        titleIcon.image = UIImage(spNamed: iconName, supportDarkMode: false)
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor1, themeStyle: currentStyle)
                self.subtitleLabel.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }
}
