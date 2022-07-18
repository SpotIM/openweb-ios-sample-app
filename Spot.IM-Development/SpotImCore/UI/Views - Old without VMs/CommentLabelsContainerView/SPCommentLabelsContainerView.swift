//
//  SPCommentLabelsContainerView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 20/04/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

protocol SPCommentLabelsContainerViewDelegate {
    func didSelectionChanged()
}

internal final class SPCommentLabelsContainerView: OWBaseView, UIGestureRecognizerDelegate {
    
    var container: OWBaseStackView = .init()
    var labelsViews: [CommentLabelView] = .init()
    var guidelineTextLabel: OWBaseLabel = .init()
    var maxLabels: Int = 1
    var selectedLabelsIds: [String] = .init()
    
    var delegate: SPCommentLabelsContainerViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func setLabelsContainer(labels: [CommentLabel],
                            guidelineText: String,
                            maxLabels: Int) {
        cleanExistingLabels()
        self.maxLabels = maxLabels
        guidelineTextLabel.text = guidelineText
        guidelineTextLabel.numberOfLines = 1
        setLabels(labels: labels)
        
        labelsViews.forEach { label in
            container.addArrangedSubview(label)
            label.OWSnp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
            }
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
            recognizer.delegate = self
            label.addGestureRecognizer(recognizer)
        }
    }
    
    func setSelectedLabels(selectedLabelIdsInEditedComment: [String]?) {
        labelsViews.forEach { label in
            if let selectedLabels = selectedLabelIdsInEditedComment,
               let labelIdIndex = selectedLabels.firstIndex(of: label.id)
            {
                label.setState(state: .selected)
                selectedLabelsIds.append(selectedLabels[labelIdIndex])
            }
        }
    }
    
    private func cleanExistingLabels() {
        labelsViews.removeAll()
        container.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
            container.removeArrangedSubview(view)
        }
    }
    
    private func setupUI() {
        addSubviews(guidelineTextLabel, container)
        configureGuidelineText()
        configureLabelsContainer()
    }
    
    private func configureGuidelineText() {
        guidelineTextLabel.textColor = .spForeground4
        guidelineTextLabel.font = UIFont.preferred(style: .medium, of: Theme.guidelineTextFontSize)
        guidelineTextLabel.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
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
        container.spacing = Theme.labelsContainerStackViewSpacing
        container.backgroundColor = .clear
  
        container.OWSnp.makeConstraints { make in
            make.top.equalTo(guidelineTextLabel.OWSnp.bottom).offset(Theme.labelsContainerStackViewTopOffset)
            make.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.height.equalTo(Theme.labelsContainerStackViewHeight)
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
        guard let tappedLabel = recognizer.view as? CommentLabelView else { return }
        if tappedLabel.getState() == .notSelected {
            if selectedLabelsIds.count != maxLabels {
                selectedLabelsIds.append(tappedLabel.id)
                tappedLabel.setState(state: .selected)
            } else if maxLabels == 1, let prevSelectedLabel = labelsViews.first(where: {$0.id == selectedLabelsIds[0]}) {
                // if max labels is 1 - un-select old selected label and select tappedLabel
                prevSelectedLabel.setState(state: .notSelected)
                selectedLabelsIds[0] = tappedLabel.id
                tappedLabel.setState(state: .selected)
            }
        } else {
            tappedLabel.setState(state: .notSelected)
            selectedLabelsIds = selectedLabelsIds.filter { $0 != tappedLabel.id }
        }
        delegate?.didSelectionChanged()
    }
}

private enum Theme {
    static let guidelineTextFontSize: CGFloat = 13.0
    static let labelsContainerStackViewSpacing: CGFloat = 10.0
    static let labelsContainerStackViewHeight: CGFloat = 28.0
    static let labelsContainerStackViewTopOffset: CGFloat = 10.0
}
