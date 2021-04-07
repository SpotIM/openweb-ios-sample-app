//
//  CommentLabelView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 06/04/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

internal final class CommentLabelView: BaseView {
    
    private let labelContainer: BaseView = .init()
    private let iconImageView: BaseUIImageView = .init()
    private let label: BaseLabel = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }
    private func configureLabelContainer() {
        labelContainer.backgroundColor = .blue
        labelContainer.layer.cornerRadius = 3
        labelContainer.pinEdges(to: self)
    }
    
//    private func configureIconImageView() {
//        iconImageView.backgroundColor = .spAvatarBG
//        iconImageView.contentMode = .scaleAspectFill
//        iconImageView.pinEdges(to: self)
//        iconImageView.layout {
//            $0.top.equal(to: labelContainer.topAnchor, offsetBy: 10)
//            $0.bottom.equal(to: labelContainer.bottomAnchor, offsetBy: -10)
//            $0.trailing.equal(to: labelContainer.trailingAnchor, offsetBy: -10)
//            $0.leading.equal(to: labelContainer.leadingAnchor, offsetBy: 10)
//        }
//    }
    
    private func configureLabel() {
        label.font = .preferred(style: .regular, of: Theme.fontSize)
        label.text = "label text"
        label.layout {
            $0.top.equal(to: labelContainer.topAnchor, offsetBy: 5)
            $0.bottom.equal(to: labelContainer.bottomAnchor, offsetBy: -5)
            $0.trailing.equal(to: labelContainer.trailingAnchor, offsetBy: -10)
            $0.leading.equal(to: labelContainer.leadingAnchor, offsetBy: 10)
        }
    }

    // MARK: - Private

    private func setupUI() {
        addSubviews(labelContainer, /*iconImageView,*/ label)
        configureLabelContainer()
//        configureIconImageView()
        configureLabel()
    }
}

// MARK: - Theme

private enum Theme {
    static let fontSize: CGFloat = 13.0
}

