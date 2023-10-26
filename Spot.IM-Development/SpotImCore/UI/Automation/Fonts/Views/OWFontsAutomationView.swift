//
//  OWFontsAutomationView.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if AUTOMATION

import UIKit
import RxSwift
import RxCocoa

class OWFontsAutomationView: UIView, OWThemeStyleInjectorProtocol {

    fileprivate struct Metrics {
        static let verticalOffset: CGFloat = 40
    }

    fileprivate let disposeBag = DisposeBag()

    fileprivate var viewModel: OWFontsAutomationViewViewModeling!

    fileprivate lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    fileprivate lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Metrics.verticalOffset
        return stackView
    }()

    fileprivate lazy var fontMapper: [OWWeakEncapsulation<UILabel>: OWFontTypography] = {
        let mapper: [OWWeakEncapsulation<UILabel>: OWFontTypography] = [OWWeakEncapsulation(value: titleSmall): .titleSmall,
                                                                        OWWeakEncapsulation(value: titleLarge): .titleLarge,
                                                                        OWWeakEncapsulation(value: titleMedium): .titleMedium,
                                                                        OWWeakEncapsulation(value: bodyText): .bodyText,
                                                                        OWWeakEncapsulation(value: bodyInteraction): .bodyInteraction,
                                                                        OWWeakEncapsulation(value: bodyContext): .bodyContext,
                                                                        OWWeakEncapsulation(value: bodySpecial): .bodySpecial,
                                                                        OWWeakEncapsulation(value: footnoteText): .footnoteText,
                                                                        OWWeakEncapsulation(value: footnoteLink): .footnoteLink,
                                                                        OWWeakEncapsulation(value: footnoteContext): .footnoteContext,
                                                                        OWWeakEncapsulation(value: footnoteSpecial): .footnoteSpecial,
                                                                        OWWeakEncapsulation(value: footnoteCaption): .footnoteCaption,
                                                                        OWWeakEncapsulation(value: metaText): .metaText,
                                                                        OWWeakEncapsulation(value: infoCaption): .infoCaption]
        return mapper
    }()

    fileprivate lazy var typographyString: String = {
        return OWLocalizationManager.shared.localizedString(key: "Typography") + ": "
    }()

    fileprivate lazy var titleSmall: UILabel = {
        return UILabel()
            .text(typographyString + OWLocalizationManager.shared.localizedString(key: "TitleSmall"))
            .font(OWFontBook.shared.font(typography: .titleSmall))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
    }()

    fileprivate lazy var titleLarge: UILabel = {
        return UILabel()
            .text(typographyString + OWLocalizationManager.shared.localizedString(key: "TitleLarge"))
            .font(OWFontBook.shared.font(typography: .titleLarge))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
    }()

    fileprivate lazy var titleMedium: UILabel = {
        return UILabel()
            .text(typographyString + OWLocalizationManager.shared.localizedString(key: "TitleMedium"))
            .font(OWFontBook.shared.font(typography: .titleLarge))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
    }()

    fileprivate lazy var bodyText: UILabel = {
        return UILabel()
            .text(typographyString + OWLocalizationManager.shared.localizedString(key: "BodyText"))
            .font(OWFontBook.shared.font(typography: .titleLarge))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
    }()

    fileprivate lazy var bodyInteraction: UILabel = {
        return UILabel()
            .text(typographyString + OWLocalizationManager.shared.localizedString(key: "BodyInteraction"))
            .font(OWFontBook.shared.font(typography: .titleLarge))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
    }()

    fileprivate lazy var bodyContext: UILabel = {
        return UILabel()
            .text(typographyString + OWLocalizationManager.shared.localizedString(key: "BodyContext"))
            .font(OWFontBook.shared.font(typography: .titleLarge))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
    }()

    fileprivate lazy var bodySpecial: UILabel = {
        return UILabel()
            .text(typographyString + OWLocalizationManager.shared.localizedString(key: "BodySpecial"))
            .font(OWFontBook.shared.font(typography: .titleLarge))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
    }()

    fileprivate lazy var footnoteText: UILabel = {
        return UILabel()
            .text(typographyString + OWLocalizationManager.shared.localizedString(key: "FootnoteText"))
            .font(OWFontBook.shared.font(typography: .titleLarge))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
    }()

    fileprivate lazy var footnoteLink: UILabel = {
        return UILabel()
            .text(typographyString + OWLocalizationManager.shared.localizedString(key: "FootnoteLink"))
            .font(OWFontBook.shared.font(typography: .titleLarge))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
    }()

    fileprivate lazy var footnoteContext: UILabel = {
        return UILabel()
            .text(typographyString + OWLocalizationManager.shared.localizedString(key: "FootnoteContext"))
            .font(OWFontBook.shared.font(typography: .titleLarge))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
    }()

    fileprivate lazy var footnoteSpecial: UILabel = {
        return UILabel()
            .text(typographyString + OWLocalizationManager.shared.localizedString(key: "FootnoteSpecial"))
            .font(OWFontBook.shared.font(typography: .titleLarge))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
    }()

    fileprivate lazy var footnoteCaption: UILabel = {
        return UILabel()
            .text(typographyString + OWLocalizationManager.shared.localizedString(key: "FootnoteCaption"))
            .font(OWFontBook.shared.font(typography: .titleLarge))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
    }()

    fileprivate lazy var metaText: UILabel = {
        return UILabel()
            .text(typographyString + OWLocalizationManager.shared.localizedString(key: "MetaText"))
            .font(OWFontBook.shared.font(typography: .titleLarge))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
    }()

    fileprivate lazy var infoCaption: UILabel = {
        return UILabel()
            .text(typographyString + OWLocalizationManager.shared.localizedString(key: "InfoCaption"))
            .font(OWFontBook.shared.font(typography: .titleLarge))
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: .light))
    }()

    init(viewModel: OWFontsAutomationViewViewModeling) {
        super.init(frame: .zero)
        self.viewModel = viewModel

        setupUI()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWFontsAutomationView {
    func setupUI() {
        self.useAsThemeStyleInjector()
        self.setupFonts()

        // Adding scroll view
        self.addSubview(scrollView)
        scrollView.OWSnp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        scrollView.addSubview(stackView)
        stackView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(scrollView.contentLayoutGuide).offset(Metrics.verticalOffset)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalOffset)
        }

        stackView.addArrangedSubview(titleSmall)
        stackView.addArrangedSubview(titleLarge)
        stackView.addArrangedSubview(titleMedium)
        stackView.addArrangedSubview(bodyText)
        stackView.addArrangedSubview(bodyInteraction)
        stackView.addArrangedSubview(bodyContext)
        stackView.addArrangedSubview(bodySpecial)
        stackView.addArrangedSubview(footnoteText)
        stackView.addArrangedSubview(footnoteLink)
        stackView.addArrangedSubview(footnoteContext)
        stackView.addArrangedSubview(footnoteSpecial)
        stackView.addArrangedSubview(footnoteCaption)
        stackView.addArrangedSubview(metaText)
        stackView.addArrangedSubview(infoCaption)
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.setupFonts()
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.setupLabelsTheme(theme: currentStyle)
            })
            .disposed(by: disposeBag)
    }

    func setupFonts() {
        for (key, typography) in fontMapper {
            guard let label = key.value() else { continue }
            label.font = OWFontBook.shared.font(typography: typography)
        }
    }

    func setupLabelsTheme(theme: OWThemeStyle) {
        for (key, _) in fontMapper {
            guard let label = key.value() else { continue }
            label.textColor = OWColorPalette.shared.color(type: .textColor1, themeStyle: theme)
        }
    }
}

#endif
