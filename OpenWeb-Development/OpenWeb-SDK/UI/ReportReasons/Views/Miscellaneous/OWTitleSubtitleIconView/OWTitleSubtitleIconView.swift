//
//  OWTitleSubtitleIconView.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 27/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWTitleSubtitleIconView: UIView {
    fileprivate struct Metrics {
        static let titleIconSize: CGFloat = 40
        static let verticalSpacing: CGFloat = 10
        static let titleIconSuffixIdentifier = "_title_icon_id"
        static let titleLabelSuffixIdentifier = "_title_label_id"
        static let subtitleLabelSuffixIdentifier = "_subtitle_label_id"
    }

    fileprivate let viewModel: OWTitleSubtitleIconViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var titleIcon: UIImageView = {
        return UIImageView()
            .contentMode(.scaleAspectFit)

    }()

    fileprivate lazy var titleLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .titleMedium))
            .numberOfLines(0)
            .textAlignment(.center)
            .textColor(OWColorPalette.shared.color(type: .textColor1,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var subtitleLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .bodyText))
            .numberOfLines(0)
            .textAlignment(.center)
            .textColor(OWColorPalette.shared.color(type: .textColor2,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    init(viewModel: OWTitleSubtitleIconViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWTitleSubtitleIconView {
    func applyAccessibility() {
        titleIcon.accessibilityIdentifier = viewModel.outputs.accessibilityPrefixId + Metrics.titleIconSuffixIdentifier
        titleLabel.accessibilityIdentifier = viewModel.outputs.accessibilityPrefixId + Metrics.titleLabelSuffixIdentifier
        subtitleLabel.accessibilityIdentifier = viewModel.outputs.accessibilityPrefixId + Metrics.subtitleLabelSuffixIdentifier
    }

    func setupViews() {
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

        titleIcon.image = UIImage(spNamed: viewModel.outputs.iconName, supportDarkMode: false)
        titleLabel.text = viewModel.outputs.title
        subtitleLabel.text = viewModel.outputs.subtitle
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

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.titleLabel.font = OWFontBook.shared.font(typography: .titleMedium)
                self.subtitleLabel.font = OWFontBook.shared.font(typography: .bodyText)
            })
            .disposed(by: disposeBag)
    }
}
