//
//  OWArticleDescriptionView.swift
//  SpotImCore
//
//  Created by Revital Pisman on 30/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWArticleDescriptionView: UIView {
    fileprivate struct Metrics {
        static let imageCornerRadius: CGFloat = 10
        static let separatorHeight: CGFloat = 0.5
        static let imageSize: CGFloat = 62
        static let paddingBetweenImageAndLabels: CGFloat = 10
        static let LabelsPadding: CGFloat = 8

        static let margins: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 16, right: 16)

        static let identifier = "article_header_id"
        static let conversationImageIdentifier = "article_header_conversation_image_id"
        static let conversationTitleIdentifier = "article_header_conversation_title_id"
        static let conversationAuthorIdentifier = "article_header_conversation_author_id"
    }

    fileprivate lazy var topSeparatorView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor3, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var conversationImageView: UIImageView = {
        return UIImageView()
            .enforceSemanticAttribute()
            .image(UIImage(spNamed: "imagePlaceholder", supportDarkMode: false)!)
            .contentMode(.scaleAspectFill)
            .clipsToBounds(true)
            .cornerRadius(Metrics.imageCornerRadius)
    }()

    fileprivate lazy var titleLabel: UILabel = {
        return UILabel()
            .enforceSemanticAttribute()
            .wrapContent()
            .numberOfLines(2)
            .font(OWFontBook.shared.font(typography: .footnoteText))
            .textColor(OWColorPalette.shared.color(type: .textColor2,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var authorLabel: UILabel = {
        return UILabel()
            .enforceSemanticAttribute()
            .wrapContent()
            .numberOfLines(1)
            .font(OWFontBook.shared.font(typography: .footnoteText))
            .textColor(OWColorPalette.shared.color(type: .textColor2,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var titlesContainer: UIView = {
        return UIView()
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var bottomSeparatorView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor3,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer()
    }()

    fileprivate var zeroHeightConstraint: OWConstraint? = nil
    fileprivate var viewModel: OWArticleDescriptionViewModeling!
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: OWArticleDescriptionViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        applyAccessibility()
        setupUI()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWArticleDescriptionView {
    func setupUI() {
        self.OWSnp.makeConstraints { make in
            zeroHeightConstraint = make.height.equalTo(0).constraint
            zeroHeightConstraint?.isActive = false
        }

        // Setup top separator
        self.addSubview(topSeparatorView)
        topSeparatorView.OWSnp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(Metrics.separatorHeight)
        }

        // Setup article image
        self.addSubview(conversationImageView)
        conversationImageView.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(Metrics.imageSize)
            make.top.greaterThanOrEqualTo(topSeparatorView.OWSnp.bottom).offset(Metrics.margins.top)
            make.leading.equalToSuperview().offset(Metrics.margins.left)
        }

        // Setup bottom separator
        self.addSubview(bottomSeparatorView)
        bottomSeparatorView.OWSnp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(conversationImageView.OWSnp.bottom).offset(-Metrics.margins.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Metrics.separatorHeight)
        }

        // Setup bottom separator
        self.addSubview(titlesContainer)
        titlesContainer.OWSnp.makeConstraints { make in
            make.leading.equalTo(conversationImageView.OWSnp.trailing).offset(Metrics.paddingBetweenImageAndLabels)
            make.trailing.equalToSuperview().offset(-Metrics.margins.right)
            make.top.equalTo(topSeparatorView.OWSnp.bottom).offset(Metrics.margins.top)
            make.bottom.equalTo(bottomSeparatorView.OWSnp.top).offset(-Metrics.margins.bottom)
        }

        titlesContainer.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        titlesContainer.addSubview(authorLabel)
        authorLabel.OWSnp.makeConstraints { make in
            make.top.equalTo(titleLabel.OWSnp.bottom).offset(Metrics.LabelsPadding)
            make.bottom.leading.trailing.equalToSuperview()
        }

        self.addGestureRecognizer(tapGesture)
    }

    func setupObservers() {
        viewModel.outputs.conversationImageType
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] imageType in
                guard let self = self else { return }
                switch imageType {
                case .custom(let url):
                    self.setImage(with: url)
                    self.setImageConstraints(isVisible: true)
                case .defaultImage:
                    self.setImageConstraints(isVisible: false)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.conversationTitle
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.conversationAuthor
            .bind(to: authorLabel.rx.text)
            .disposed(by: disposeBag)

        tapGesture.rx.event
            .voidify()
            .bind(to: viewModel.inputs.tap)
            .disposed(by: disposeBag)

        if let zeroHeightConstraint = zeroHeightConstraint {
            viewModel.outputs.shouldShow
                .map { !$0 }
                .bind(to: zeroHeightConstraint.rx.isActive)
                .disposed(by: disposeBag)
        }

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.topSeparatorView.backgroundColor(OWColorPalette.shared.color(type: .separatorColor3,
                                                                                  themeStyle: currentStyle))
                self.bottomSeparatorView.backgroundColor(OWColorPalette.shared.color(type: .separatorColor3,
                                                                                  themeStyle: currentStyle))
                self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor2,
                                                                        themeStyle: currentStyle)
                self.authorLabel.textColor = OWColorPalette.shared.color(type: .textColor2,
                                                                        themeStyle: currentStyle)
                self.updateCustomUI()
            }).disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.titleLabel.font = OWFontBook.shared.font(typography: .footnoteText)
                self.authorLabel.font = OWFontBook.shared.font(typography: .footnoteText)
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        conversationImageView.accessibilityIdentifier = Metrics.conversationImageIdentifier
        titleLabel.accessibilityIdentifier = Metrics.conversationTitleIdentifier
        authorLabel.accessibilityIdentifier = Metrics.conversationAuthorIdentifier
    }

    func updateCustomUI() {
        viewModel.inputs.triggerCustomizeTitleLabelUI.onNext(titleLabel)
        viewModel.inputs.triggerCustomizeAuthorLabelUI.onNext(authorLabel)
        viewModel.inputs.triggerCustomizeImageViewUI.onNext(conversationImageView)
    }

    func setImage(with url: URL) {
        conversationImageView.setImage(with: url) { [weak self] image, error in
            guard let self = self else { return }

            if error != nil {
                self.setImageConstraints(isVisible: false)
            } else if let image = image {
                self.conversationImageView.image = image
                self.setImageConstraints(isVisible: true)
                // Only when we have an imgae from article url, we can replace it with customize element
                self.viewModel.inputs.triggerCustomizeImageViewUI.onNext(self.conversationImageView)
            }
        }
    }

    func setImageConstraints(isVisible: Bool) {
       self.conversationImageView.OWSnp.updateConstraints { make in
           make.size.equalTo(isVisible ? Metrics.imageSize : 0)
       }
   }
}
