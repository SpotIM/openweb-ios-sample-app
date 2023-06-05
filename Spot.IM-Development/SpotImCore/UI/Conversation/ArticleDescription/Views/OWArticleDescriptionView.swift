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
        static let identifier = "article_header_id"
        static let conversationImageIdentifier = "article_header_conversation_image_id"
        static let conversationTitleIdentifier = "article_header_conversation_title_id"
        static let conversationAuthorIdentifier = "article_header_conversation_author_id"
        static let fontSize = 13.0
        static let imageCornerRadius = 10.0
        static let separatorHeight = 0.5
        static let imagePadding = 12.0
        static let imageSize = 62.0
        static let descriptionLabelsPadding = 8.0
    }

    fileprivate lazy var topSeparatorView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor1, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
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
            .font(OWFontBook.shared.font(style: .regular,
                                         size: Metrics.fontSize))
            .textColor(OWColorPalette.shared.color(type: .textColor2,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var authorLabel: UILabel = {
        return UILabel()
            .enforceSemanticAttribute()
            .wrapContent()
            .numberOfLines(1)
            .font(OWFontBook.shared.font(style: .regular,
                                         size: Metrics.fontSize))
            .textColor(OWColorPalette.shared.color(type: .textColor2,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var titlesContainer: UIView = {
        return UIView()
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var bottomSeparatorView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor1,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer()
    }()

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
        // Setup top separator
        self.addSubview(topSeparatorView)
        topSeparatorView.OWSnp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(Metrics.separatorHeight)
        }

        // Setup article image
        self.addSubview(conversationImageView)
        conversationImageView.OWSnp.makeConstraints { make in
            make.top.equalTo(topSeparatorView.OWSnp.bottom).offset(Metrics.imagePadding)
            make.leading.equalToSuperview().offset(Metrics.imagePadding)
            make.size.equalTo(Metrics.imageSize)
        }

        // Setup bottom separator
        self.addSubview(bottomSeparatorView)
        bottomSeparatorView.OWSnp.makeConstraints { make in
            make.top.equalTo(conversationImageView.OWSnp.bottom).offset(Metrics.imagePadding)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Metrics.separatorHeight)
        }

        // Setup bottom separator
        self.addSubview(titlesContainer)
        titlesContainer.OWSnp.makeConstraints { make in
            make.leading.equalTo(conversationImageView.OWSnp.trailing).offset(Metrics.imagePadding)
            make.trailing.equalToSuperview().offset(-Metrics.imagePadding)
            make.centerY.equalTo(conversationImageView)
        }

        titlesContainer.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        titlesContainer.addSubview(authorLabel)
        authorLabel.OWSnp.makeConstraints { make in
            make.top.equalTo(titleLabel.OWSnp.bottom).offset(Metrics.descriptionLabelsPadding)
            make.bottom.leading.trailing.equalToSuperview()
        }

        self.addGestureRecognizer(tapGesture)
    }

    func setupObservers() {
        viewModel.outputs.conversationImageType
            .subscribe(onNext: { [weak self] imageType in
                switch imageType {
                case .custom(let url):
                    guard let self = self else { return }
                    self.setImage(with: url)
                case .defaultImage:
                    self?.setNoImageConstraints()
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

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.topSeparatorView.backgroundColor(OWColorPalette.shared.color(type: .separatorColor1,
                                                                                  themeStyle: currentStyle))
                self.bottomSeparatorView.backgroundColor(OWColorPalette.shared.color(type: .separatorColor1,
                                                                                  themeStyle: currentStyle))
                self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor2,
                                                                        themeStyle: currentStyle)
                self.authorLabel.textColor = OWColorPalette.shared.color(type: .textColor2,
                                                                        themeStyle: currentStyle)
                self.updateCustomUI()
            }).disposed(by: disposeBag)
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
                self.setNoImageConstraints()
            } else if let image = image {
                self.conversationImageView.image = image

                // Only when we have an imgae from article url, we can replace it with customize element
                self.viewModel.inputs.triggerCustomizeImageViewUI.onNext(self.conversationImageView)
            }
        }
    }

    func setNoImageConstraints() {
       self.conversationImageView.OWSnp.updateConstraints { make in
           make.width.equalTo(0)
       }
   }
}
