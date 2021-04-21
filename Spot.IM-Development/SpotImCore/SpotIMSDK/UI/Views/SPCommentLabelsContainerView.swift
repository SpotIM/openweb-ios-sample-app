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
    var guidelineTextLabel: BaseLabel = .init()
    var maxLabels: Int = 0
    var selectedLabelsIds: [String] = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func setLabelsContainer(labels: [CommentLabel], guidelineText: String, maxLabels: Int) {
        self.maxLabels = maxLabels
        guidelineTextLabel.text = guidelineText
        guidelineTextLabel.numberOfLines = 0
        setLabels(labels: labels)
        
        labelsViews.forEach { label in
            container.addArrangedSubview(label)
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
            recognizer.delegate = self
            label.addGestureRecognizer(recognizer)
        }
    }
    
    private func setupUI() {
        addSubviews(guidelineTextLabel, container)
        configureGuidelineText()
        configureLabelsContainer()
    }
    
    private func configureGuidelineText() {
        guidelineTextLabel.textColor = .spForeground4
        guidelineTextLabel.font = UIFont.preferred(style: .medium, of: 13.0)
        guidelineTextLabel.layout {
            $0.top.equal(to: topAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
    }
    
    private func setLabels(labels: [CommentLabel]) {
        labels.forEach { label in
            let labelView = CommentLabelView()
            labelView.setLabel(commentLabelIconUrl: label.iconUrl, labelColor: label.color, labelText: label.text, labelId: label.id, state: .notSelected)
            labelsViews.append(labelView)
        }
    }
    
    private func configureLabelsContainer() {
        container.axis = .horizontal
        container.alignment = .leading
        container.distribution = .equalSpacing
        container.spacing = 10
        container.backgroundColor = .clear
        
        container.layout {
            $0.top.equal(to: guidelineTextLabel.bottomAnchor, offsetBy: 10.0)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.lessThanOrEqual(to: trailingAnchor)
            $0.height.equal(to: 28.0)
        }
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        self.backgroundColor = .clear
        guidelineTextLabel.textColor = .spForeground4
        labelsViews.forEach { label in
            label.updateColorsAccordingToStyle()
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
                selectedLabelsIds = selectedLabelsIds.filter { $0 != tappedLabel.id }
            }
        }
    }

}
