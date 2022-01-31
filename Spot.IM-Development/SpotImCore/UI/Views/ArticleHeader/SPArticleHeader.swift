//
//  SPArticleHeader.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 21/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal final class SPArticleHeader: BaseView {
    
    private lazy var conversationImageView: BaseUIImageView = .init()
    private lazy var conversationTitleLabel: BaseLabel = .init()
    private lazy var conversationAuthorLabel: BaseLabel = .init()
    private lazy var separatorView: BaseView = .init()
    private lazy var titlesContainer: BaseView = .init()

    // MARK: - Overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
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

    internal func setImage(with url: URL?) {
        conversationImageView.setImage(with: url) { image, error in
            if error != nil {
                self.conversationImageView.layout {
                    $0.width.equal(to: 0)
                }
            }
            else if let image = image {
                self.conversationImageView.image = image
            }
        }
    }

    internal func setTitle(_ title: String?) {
        conversationTitleLabel.text = title
    }

    internal func setAuthor(_ author: String?) {
        conversationAuthorLabel.text = author
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
        
        conversationImageView.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: Theme.imageLeadingOffset)
            $0.bottom.equal(to: bottomAnchor, offsetBy: -Theme.imageBottomOffset)
            $0.height.equal(to: Theme.imageSize)
            $0.width.equal(to: Theme.imageSize)
        }
    }

    private func configureSeparatorView() {
        separatorView.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.height.equal(to: Theme.separatorHeight)
        }
    }
    
    private func setupConversationTitleContainer() {
        titlesContainer.addSubviews(conversationTitleLabel, conversationAuthorLabel)
        titlesContainer.layout {
            $0.leading.equal(to: conversationImageView.trailingAnchor, offsetBy: Theme.insetShort)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -Theme.titlesTrailingOffset)
            $0.centerY.equal(to: conversationImageView.centerYAnchor)
        }
        setupConversationTitleLabel()
        setupConversationAuthorLabel()
    }
    
    private func setupConversationTitleLabel() {
        conversationTitleLabel.text = LocalizationManager.localizedString(key: "Loading")
        conversationTitleLabel.numberOfLines = 2
        conversationTitleLabel.font = UIFont.preferred(style: .regular, of: Theme.titleFontSize)

        conversationTitleLabel.layout {
            $0.top.equal(to: titlesContainer.topAnchor)
            $0.leading.equal(to: titlesContainer.leadingAnchor)
            $0.trailing.equal(to: titlesContainer.trailingAnchor)
        }
    }
    
    private func setupConversationAuthorLabel() {
        conversationAuthorLabel.numberOfLines = 1
        conversationAuthorLabel.font = UIFont.preferred(style: .regular, of: Theme.subTitleFontSize)
        
        conversationAuthorLabel.layout {
            $0.bottom.equal(to: titlesContainer.bottomAnchor)
            $0.top.equal(to: conversationTitleLabel.bottomAnchor, offsetBy: Theme.insetTiny)
            $0.leading.equal(to: titlesContainer.leadingAnchor)
            $0.trailing.equal(to: titlesContainer.trailingAnchor)
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
