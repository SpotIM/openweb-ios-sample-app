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
    var labelsViews: [CommentLabelView] = .init()
    var guidelineText: BaseLabel = .init()
    var maxLabels: Int
    var selectedLabelsIds: [String] = .init()

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupUI()
//    }
    
    init(labels: [CommentLabel], guidelineText: String, maxLabels: Int) {
        self.maxLabels = maxLabels
        super.init(frame: frame)
        setupUI(labels: labels, guidelineText: guidelineText)
    }
    
    private func setupUI(labels: [CommentLabel], guidelineText: String) {
        addSubviews(self.guidelineText, container)
        configureGuidelineText(text: guidelineText)
        configureLabels(labels: labels)
        configureLabelsContainer()
    }
    
    private func configureGuidelineText(text: String) {
        guidelineText.text = text
        guidelineText.textColor = .steelGrey
        guidelineText.font = UIFont.preferred(style: .medium, of: 13.0)
        guidelineText.layout {
            $0.top.equal(to: topAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
    }
    
    private func configureLabels(labels: [CommentLabel]) {
        labels.forEach { label in
            let labelView = CommentLabelView()
            labelView.setLabel(commentLabelIconUrl: label.iconUrl, labelColor: label.color, labelText: label.text, labelId: label.id, state: .notSelected)
        }
    }
    
    private func configureLabelsContainer() {
        container.axis = .horizontal
        container.alignment = .leading
        container.distribution = .fillEqually
        
        container.spacing = 10
        labelsViews.forEach { label in
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
                if selectedLabelsIds.count == maxLabels {
                    if maxLabels == 1,
                       let prevSelectedLabel = labelsViews.first(where: {$0.id == selectedLabelsIds[0]}) {
                        prevSelectedLabel.setState(state: .notSelected)
                        selectedLabelsIds[0] = tappedLabel.id
                        tappedLabel.setState(state: .selected)
                    }
                } else {
                    selectedLabelsIds.append(tappedLabel.id)
                    tappedLabel.setState(state: .selected)
                }
            } else {
                tappedLabel.setState(state: .notSelected)
                selectedLabelsIds = selectedLabelsIds.filter { $0 != tappedLabel.id}
            }
        }
    }

}
