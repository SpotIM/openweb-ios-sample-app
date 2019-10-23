//
//  SPArticleHeader.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 21/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

internal final class SPArticleHeader: BaseView {
    
    private lazy var conversationImageView: UIImageView = .init()
    private lazy var conversationTitleLabel: UILabel = .init()
    private lazy var conversationAuthorLabel: UILabel = .init()
    private lazy var separatorView: UIView = .init()
    private lazy var titlesContainer: UIView = .init()

    // MARK: - Overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }

    // MARK: - Internal methods

    internal func setImage(with url: URL?) {
        conversationImageView.setImage(with: url)
    }

    internal func setTitle(_ title: String?) {
        conversationTitleLabel.text = title
    }

    internal func setAuthor(_ author: String?) {
        conversationAuthorLabel.text = author
    }
    
    // MARK: - Private Methods

    private func setup() {
        backgroundColor = .white

        addSubviews(conversationImageView, titlesContainer, separatorView)
        setupConversationImageView()
        setupConversationTitleContainer()
        configureSeparatorView()
    }

    private func setupConversationImageView() {
        conversationImageView.image = UIImage(spNamed: "imagePlaceholder")
        conversationImageView.backgroundColor = .white
        conversationImageView.contentMode = .scaleAspectFill
        conversationImageView.clipsToBounds = true
        conversationImageView.addCornerRadius(Theme.imageCornerRadius)
        
        conversationImageView.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: Theme.imageEdgesOffset)
            $0.bottom.equal(to: bottomAnchor, offsetBy: -Theme.imageEdgesOffset)
            $0.height.equal(to: Theme.imageSize)
            $0.width.equal(to: Theme.imageSize)
        }
    }

    private func configureSeparatorView() {
        separatorView.backgroundColor = .iceBlue
        separatorView.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.height.equal(to: Theme.separatorHeight)
        }
    }
    
    private func setupConversationTitleContainer() {
        titlesContainer.addSubviews(conversationTitleLabel, conversationAuthorLabel)
        titlesContainer.backgroundColor = .white
        titlesContainer.layout {
            $0.leading.equal(to: conversationImageView.trailingAnchor, offsetBy: Theme.insetShort)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -Theme.titlesTrailingOffset)
            $0.centerY.equal(to: conversationImageView.centerYAnchor)
        }
        setupConversationTitleLabel()
        setupConversationAuthorLabel()
    }
    
    private func setupConversationTitleLabel() {
        conversationTitleLabel.text = NSLocalizedString("Loading",
                                                        comment: "Main Conversation header title placeholder")
        conversationTitleLabel.numberOfLines = 2
        conversationTitleLabel.backgroundColor = .white
        conversationTitleLabel.textColor = .steelGrey
        conversationTitleLabel.font = UIFont.roboto(style: .regular, of: Theme.titleFontSize)

        conversationTitleLabel.layout {
            $0.top.equal(to: titlesContainer.topAnchor)
            $0.leading.equal(to: titlesContainer.leadingAnchor)
            $0.trailing.equal(to: titlesContainer.trailingAnchor)
        }
    }
    
    private func setupConversationAuthorLabel() {
        conversationAuthorLabel.text = NSLocalizedString("*Author name*",
                                                        comment: "Main Conversation author placeholder")
        conversationAuthorLabel.numberOfLines = 1
        conversationAuthorLabel.backgroundColor = .white
        conversationAuthorLabel.textColor = .coolGrey
        conversationAuthorLabel.font = UIFont.roboto(style: .regular, of: Theme.subTitleFontSize)
        
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
    static let imageEdgesOffset: CGFloat = 9.0
    static let titleFontSize: CGFloat = 15.0
    static let subTitleFontSize: CGFloat = 13.0
}
