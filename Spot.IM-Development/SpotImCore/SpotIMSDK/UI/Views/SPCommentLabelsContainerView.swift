//
//  SPCommentLabelsContainerView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 20/04/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

internal final class SPCommentLabelsContainerView: BaseView, UIGestureRecognizerDelegate {
    
    var container: BaseStackView = .init()
    var labels: [CommentLabelView] = .init()
    var guidelineText: BaseLabel = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        addSubviews(guidelineText, container)
        configureGuidelineText()
        configureLabelsContainer()
    }
    
    private func configureGuidelineText() {
        let text = "How do you think the stock is performing?"
        guidelineText.text = text
        guidelineText.textColor = .steelGrey
        guidelineText.font = UIFont.preferred(style: .medium, of: 13.0)
        guidelineText.layout {
            $0.top.equal(to: topAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
    }
    
    private func configureLabels() {
        let url = URL(string: "https://images.spot.im/image/upload/f_png/font-awesome/solid-chart-line-down.png")
        labels.append(CommentLabelView())
        labels.append(CommentLabelView())
        labels.append(CommentLabelView())
        labels[0].setLabel(commentLabelIconUrl: url!, labelColor: .red, labelText: "text1", state: .notSelected)
        labels[1].setLabel(commentLabelIconUrl: url!, labelColor: .red, labelText: "text2", state: .notSelected)
        labels[2].setLabel(commentLabelIconUrl: url!, labelColor: .red, labelText: "text3", state: .notSelected)
    }
    
    private func configureLabelsContainer() {
        configureLabels()

        container.axis = .horizontal
        container.alignment = .leading
        container.distribution = .fillEqually
        
        container.spacing = 10
        labels.forEach { label in
            container.addArrangedSubview(label)
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
            recognizer.delegate = self
            label.addGestureRecognizer(recognizer)
        }

        container.layout {
            $0.top.equal(to: guidelineText.bottomAnchor, offsetBy: 10.0)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.height.equal(to: 28.0)
        }
    }
    
    @objc func labelTapped(_ recognizer: UITapGestureRecognizer) {
        if let tappedLabel = recognizer.view as? CommentLabelView {
            if tappedLabel.getState() == .notSelected {
                tappedLabel.setState(state: .selected)
            } else {
                tappedLabel.setState(state: .notSelected)
            }
        }
    }

}
