//
//  OWCommentCreationRegularView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 07/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentCreationRegularView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "comment_creation_regular_view_id"
    }

    fileprivate lazy var titleLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(style: .regular, size: 15.0))
            .text(OWLocalizationManager.shared.localizedString(key: "Commenting on"))
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var closeButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), state: .normal)
    }()

    fileprivate lazy var topContainerView: UIView = {
        let topContainerView = UIView()

        topContainerView.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.centerY.equalTo(topContainerView.OWSnp.centerY)
            make.leading.equalToSuperview().offset(16.0)
        }

        topContainerView.addSubview(closeButton)
        closeButton.OWSnp.makeConstraints { make in
            make.centerY.equalTo(topContainerView.OWSnp.centerY)
            make.trailing.equalToSuperview().offset(-5.0)
            make.size.equalTo(40.0)
        }

        return topContainerView
    }()

    fileprivate lazy var articleDescriptionView: OWArticleDescriptionView = {
        return OWArticleDescriptionView(viewModel: self.viewModel.outputs.articleDescriptionViewModel)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var textInput: UITextView = {
        return UITextView()
    }()

    fileprivate lazy var footerView: OWCommentCreationFooterView = {
        return OWCommentCreationFooterView(with: self.viewModel.outputs.footerViewModel)
    }()

    fileprivate let viewModel: OWCommentCreationRegularViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWCommentCreationRegularViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
        applyAccessibility()
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }
}

fileprivate extension OWCommentCreationRegularView {
    func setupViews() {
        self.useAsThemeStyleInjector()

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.closeButton.image(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), state: .normal)
            })
            .disposed(by: disposeBag)

        self.addSubview(topContainerView)
        topContainerView.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(68.0)
        }

        self.addSubview(articleDescriptionView)
        articleDescriptionView.OWSnp.makeConstraints { make in
            make.top.equalTo(topContainerView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        self.addSubview(footerView)
        footerView.OWSnp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(72.0)
        }

        self.addSubview(textInput)
        textInput.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(articleDescriptionView.OWSnp.bottom).offset(12.0)
            make.bottom.equalTo(footerView.OWSnp.top)
        }
    }

    func setupObservers() {
        closeButton.rx.tap
            .bind(to: viewModel.inputs.closeButtonTap)
            .disposed(by: disposeBag)
    }
}
