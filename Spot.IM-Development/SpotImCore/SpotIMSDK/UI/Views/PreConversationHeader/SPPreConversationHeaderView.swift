//
//  SPPreConversationHeaderView.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 13/08/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal final class SPPreConversationHeaderView: BaseView {
    private lazy var titleLabel: BaseLabel = .init()
    private lazy var counterLabel: BaseLabel = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }

    internal func set(title: String) {
        titleLabel.text = title
    }

    internal func set(commentCount: String?) {
        counterLabel.text = commentCount == nil ? nil : "(\(commentCount!))"
    }

    private func setup() {
        addSubviews(titleLabel, counterLabel)
        setupTitleLabel()
        setupCounterLabel()
    }

    private func setupTitleLabel() {
        titleLabel.font = UIFont.preferred(style: .bold, of: Theme.titleFontSize)
        titleLabel.textColor = .spForeground0
        titleLabel.layout {
            $0.centerY.equal(to: centerYAnchor)
            $0.leading.equal(to: leadingAnchor, offsetBy: Theme.margins.left)
        }
    }

    private func setupCounterLabel() {
        counterLabel.font = UIFont.preferred(style: .regular, of: Theme.counterFontSize)
        counterLabel.textColor = .spForeground1
        counterLabel.layout {
            $0.firstBaseline.equal(to: titleLabel.firstBaselineAnchor)
            $0.leading.equal(to: titleLabel.trailingAnchor, offsetBy: Theme.counterLeading)
            $0.trailing.lessThanOrEqual(to: trailingAnchor)
        }
    }
}

private extension SPPreConversationHeaderView {
    private enum Theme {
        static let counterLeading: CGFloat = 5
        static let titleFontSize: CGFloat = 25
        static let counterFontSize: CGFloat = 16
        static let margins: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
    }
}
