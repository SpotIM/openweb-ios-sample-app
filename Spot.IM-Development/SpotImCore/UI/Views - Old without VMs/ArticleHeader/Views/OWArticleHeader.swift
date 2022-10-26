//
//  SPArticleHeader.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 21/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

internal final class OWArticleHeader: OWBaseView {
    fileprivate struct Metrics {
        static let identifier = "article_header_id"
        static let conversationImageIdentifier = "conversation_image_id"
        static let conversationTitleIdentifier = "conversation_title_id"
        static let conversationAuthorIdentifier = "conversation_author_id"
        static let separatorIdentifier = "separator_id"
        static let titlesContainerIdentifier = "titles_container_id"
    }
    
    private lazy var conversationImageView: OWBaseUIImageView = .init()
    private lazy var conversationTitleLabel: OWBaseLabel = .init()
    private lazy var conversationAuthorLabel: OWBaseLabel = .init()
    private lazy var separatorView: OWBaseView = .init()
    private lazy var titlesContainer: OWBaseView = .init()

    fileprivate var viewModel: OWArticleHeaderViewModeling!
    fileprivate var disposeBag: DisposeBag!
    
    // MARK: - Overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        applyAccessibility()
    }
    
    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        conversationImageView.accessibilityIdentifier = Metrics.conversationImageIdentifier
        conversationTitleLabel.accessibilityIdentifier = Metrics.conversationTitleIdentifier
        conversationAuthorLabel.accessibilityIdentifier = Metrics.conversationAuthorIdentifier
        separatorView.accessibilityIdentifier = Metrics.separatorIdentifier
        titlesContainer.accessibilityIdentifier = Metrics.titlesContainerIdentifier
    }
    
    func configure(with viewModel: OWArticleHeaderViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        setupObservers()
    }

    func setupObservers() {
        viewModel.outputs.conversationImageType
            .subscribe(onNext: { [weak self] imageType in
                switch imageType {
                case .custom(let url):
                    self?.setImage(with: url)
                case .defaultImage:
                    self?.setNoImageConstraints()
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.conversationTitle
            .bind(to: conversationTitleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.conversationAuthor
            .bind(to: conversationAuthorLabel.rx.text)
            .disposed(by: disposeBag)
        
        let tapGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event.map { _ in
            return
        }
        .bind(to: viewModel.inputs.tap)
        .disposed(by: disposeBag)
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        conversationImageView.backgroundColor = .spBackground0
        separatorView.backgroundColor = .spSeparator2
        titlesContainer.backgroundColor = .spBackground0
        conversationTitleLabel.backgroundColor = .spBackground0
        conversationTitleLabel.textColor = .spForeground4
        conversationAuthorLabel.backgroundColor = .spBackground0
        conversationAuthorLabel.textColor = .spForeground2
    }

    // MARK: - Internal methods

    private func setImage(with url: URL) {
        conversationImageView.setImage(with: url) { [weak self] image, error in
            guard let self = self else { return }
            
            if error != nil {
                self.setNoImageConstraints()
            }
            else if let image = image {
                self.conversationImageView.image = image
            }
        }
    }
    
    private func setNoImageConstraints() {
        self.conversationImageView.OWSnp.updateConstraints { make in
            make.width.equalTo(0)
        }
    }
    
    // MARK: - Private Methods

    private func setup() {
        addSubviews(conversationImageView, titlesContainer, separatorView)
        setupConversationImageView()
        setupConversationTitleContainer()
        configureSeparatorView()
        updateColorsAccordingToStyle()
    }

    private func setupConversationImageView() {
        conversationImageView.image = UIImage(spNamed: "imagePlaceholder", supportDarkMode: false)
        conversationImageView.contentMode = .scaleAspectFill
        conversationImageView.clipsToBounds = true
        conversationImageView.addCornerRadius(Theme.imageCornerRadius)
        
        conversationImageView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Theme.imageLeadingOffset)
            make.bottom.equalToSuperview().offset(-Theme.imageBottomOffset)
            make.size.equalTo(Theme.imageSize)
        }
    }

    private func configureSeparatorView() {
        separatorView.OWSnp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Theme.separatorHeight)
        }
    }
    
    private func setupConversationTitleContainer() {
        titlesContainer.addSubviews(conversationTitleLabel, conversationAuthorLabel)
        titlesContainer.OWSnp.makeConstraints { make in
            make.leading.equalTo(conversationImageView.OWSnp.trailing).offset(Theme.insetShort)
            make.trailing.equalToSuperview().offset(-Theme.titlesTrailingOffset)
            make.centerY.equalTo(conversationImageView)
        }

        setupConversationTitleLabel()
        setupConversationAuthorLabel()
    }
    
    private func setupConversationTitleLabel() {
        conversationTitleLabel.text = LocalizationManager.localizedString(key: "Loading")
        conversationTitleLabel.numberOfLines = 2
        conversationTitleLabel.font = UIFont.preferred(style: .regular, of: Theme.titleFontSize)

        conversationTitleLabel.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupConversationAuthorLabel() {
        conversationAuthorLabel.numberOfLines = 1
        conversationAuthorLabel.font = UIFont.preferred(style: .regular, of: Theme.subTitleFontSize)
        
        conversationAuthorLabel.OWSnp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.top.equalTo(conversationTitleLabel.OWSnp.bottom).offset(Theme.insetTiny)
        }
    }
    
}

private enum Theme {
    
    static let titlesTrailingOffset: CGFloat = 24.0
    static let separatorHeight: CGFloat = 1.0
    static let insetTiny: CGFloat = 6.0
    static let insetShort: CGFloat = 11.0
    static let imageSize: CGFloat = 67.0
    static let imageCornerRadius: CGFloat = 4.0
    static let imageLeadingOffset: CGFloat = 16.0
    static let imageBottomOffset: CGFloat = 9.0
    static let titleFontSize: CGFloat = 15.0
    static let subTitleFontSize: CGFloat = 13.0
}
