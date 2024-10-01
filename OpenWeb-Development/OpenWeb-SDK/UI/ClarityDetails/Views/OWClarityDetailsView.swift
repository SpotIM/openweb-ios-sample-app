//
//  OWClarityDetailsView.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 21/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class OWClarityDetailsView: UIView, OWThemeStyleInjectorProtocol {
    private struct Metrics {
        static let closeButtonSize: CGFloat = 28
        static let navigationTitleTrailingPadding: CGFloat = 8
        static let navigationBottomPadding: CGFloat = 10
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 20
        static let titleTopPadding: CGFloat = 12
        static let spaceBetweenParagraphs: CGFloat = 16
        static let buttonRadius: CGFloat = 6
        static let buttomBottomPadding: CGFloat = 36
        static let buttonTextPadding: UIEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        static let appealLabelTopPadding: CGFloat = 24
        static let scrollViewBottomPadding: CGFloat = 16

        static let identifier = "clarity_details_view_id"
        static let titleLabelIdentifier = "clarity_details_title_id"
        static let closeButtonIdentifier = "clarity_details_close_button_id"
        static let gotItButtonIdentifier = "clarity_details_got_it_button_id"
    }

    private lazy var titleLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .bodyContext))
            .text(viewModel.outputs.navigationTitle)
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .enforceSemanticAttribute()
    }()

    private lazy var closeButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), state: .normal)
    }()

    private lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentLayoutGuide.OWSnp.makeConstraints { make in
            make.width.equalTo(scrollView)
        }
        return scrollView
    }()

    private lazy var topContainerView: UIView = {
        let topContainerView = UIView()
            .enforceSemanticAttribute()

        topContainerView.addSubview(closeButton)
        closeButton.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(Metrics.navigationBottomPadding)
            make.trailing.equalToSuperview().inset(Metrics.horizontalPadding)
            make.size.equalTo(Metrics.closeButtonSize)
        }

        topContainerView.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(Metrics.navigationBottomPadding)
            make.leading.equalToSuperview().offset(Metrics.horizontalPadding)
            make.trailing.equalTo(closeButton.OWSnp.leading).inset(Metrics.navigationTitleTrailingPadding)
        }

        return topContainerView
    }()

    private lazy var topParagraphLabel: UILabel = {
        return UILabel()
            .numberOfLines(0)
            .enforceSemanticAttribute()
    }()

    private lazy var detailsTitleLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .bodyInteraction))
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .text(viewModel.outputs.detailsTitleText)
            .numberOfLines(0)
            .enforceSemanticAttribute()
    }()

    private lazy var paragraphsStackView: UIStackView = {
        let stackView = UIStackView()
            .spacing(Metrics.spaceBetweenParagraphs)
            .axis(.vertical)
        viewModel.outputs.paragraphViewModels.forEach { vm in
            let paragraphView = OWParagraphWithIconView(viewModel: vm)
            stackView.addArrangedSubview(paragraphView)
        }
        return stackView
    }()

    private lazy var bottomParagraphLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .bodyText))
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .text(viewModel.outputs.bottomParagraphText)
            .numberOfLines(0)
            .enforceSemanticAttribute()
    }()

    private lazy var appealLabel: OWAppealLabelView = {
        return OWAppealLabelView(viewModel: viewModel.outputs.appealLabelViewModel)
    }()

    private lazy var gotItButton: UIButton = {
        return UIButton()
            .backgroundColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
            .textColor(OWDesignColors.G1)
            .corner(radius: Metrics.buttonRadius)
            .setTitle(OWLocalizationManager.shared.localizedString(key: "GotIt"), state: .normal)
            .font(OWFontBook.shared.font(typography: .bodyInteraction))
            .withPadding(Metrics.buttonTextPadding)
    }()

    private let viewModel: OWClarityDetailsViewViewModeling
    private var disposeBag: DisposeBag

    init(viewModel: OWClarityDetailsViewViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        super.init(frame: .zero)

        setupViews()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OWClarityDetailsView {
    func setupViews() {
        self.enforceSemanticAttribute()
        self.useAsThemeStyleInjector()

        self.addSubview(topContainerView)
        topContainerView.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.addSubview(gotItButton)
        gotItButton.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalPadding)
            make.bottom.equalToSuperview().inset(Metrics.buttomBottomPadding)
        }

        self.addSubview(scrollView)
        scrollView.OWSnp.makeConstraints { make in
            make.top.equalTo(topContainerView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(gotItButton.OWSnp.top).offset(-Metrics.scrollViewBottomPadding)
        }

        scrollView.addSubview(topParagraphLabel)
        topParagraphLabel.OWSnp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).offset(Metrics.verticalPadding)
            make.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(Metrics.horizontalPadding)
        }

        scrollView.addSubview(detailsTitleLabel)
        detailsTitleLabel.OWSnp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(Metrics.horizontalPadding)
            make.top.equalTo(topParagraphLabel.OWSnp.bottom).offset(Metrics.titleTopPadding)
        }

        scrollView.addSubview(paragraphsStackView)
        paragraphsStackView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(Metrics.horizontalPadding)
            make.top.equalTo(detailsTitleLabel.OWSnp.bottom).offset(Metrics.spaceBetweenParagraphs)
        }

        scrollView.addSubview(bottomParagraphLabel)
        bottomParagraphLabel.OWSnp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(Metrics.horizontalPadding)
            make.top.equalTo(paragraphsStackView.OWSnp.bottom).offset(Metrics.spaceBetweenParagraphs)
        }

        scrollView.addSubview(appealLabel)
        appealLabel.OWSnp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(Metrics.horizontalPadding)
            make.top.equalTo(paragraphsStackView.OWSnp.bottom).offset(Metrics.appealLabelTopPadding)
            make.bottom.equalTo(scrollView.contentLayoutGuide)
        }
    }

    func setupObservers() {
        closeButton.rx.tap
            .bind(to: viewModel.inputs.closeClick)
            .disposed(by: disposeBag)

        gotItButton.rx.tap
            .bind(to: viewModel.inputs.gotItClick)
            .disposed(by: disposeBag)

        viewModel.outputs.topParagraphAttributedStringObservable
            .bind(to: topParagraphLabel.rx.attributedText)
            .disposed(by: disposeBag)

        viewModel.outputs.topParagraphAttributedStringObservable
            .subscribe(onNext: { [weak self] attributedText in
                guard let self = self else { return }
                self.topParagraphLabel
                    .attributedText(attributedText)
                    .addRangeGesture(targetRange: self.viewModel.outputs.communityGuidelinesClickablePlaceholder) { [weak self] in
                        guard let self = self else { return }
                        self.viewModel.inputs.communityGuidelinesClick.onNext()
                    }
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor4, themeStyle: currentStyle)
                self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
                self.closeButton.setImage(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), for: .normal)
                self.detailsTitleLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
                self.bottomParagraphLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
                self.gotItButton.backgroundColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.titleLabel.font = OWFontBook.shared.font(typography: .bodyContext)
                self.detailsTitleLabel.font = OWFontBook.shared.font(typography: .bodyInteraction)
                self.gotItButton.titleLabel?.font = OWFontBook.shared.font(typography: .bodyInteraction)
                self.bottomParagraphLabel.font = OWFontBook.shared.font(typography: .bodyText)
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        titleLabel.accessibilityIdentifier = Metrics.titleLabelIdentifier
        closeButton.accessibilityIdentifier = Metrics.closeButtonIdentifier
        gotItButton.accessibilityIdentifier = Metrics.gotItButtonIdentifier
    }
}
