//
//  CommentLabelView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 06/04/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

internal final class CommentLabelView: OWBaseView {
    
    private let labelContainer: OWBaseView = .init()
    private let iconImageView: OWBaseUIImageView = .init()
    private let label: OWBaseLabel = .init()
    
    private var commentLabelColor: UIColor = .clear
    private var state: LabelState = .readOnly 
    
    private var iconImageViewHeightConstraint: NSLayoutConstraint?
    
    var id: String = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func setLabel(commentLabelIconUrl: URL, labelColor: UIColor, labelText: String, labelId: String, state: LabelState) {
        self.id = labelId
        self.commentLabelColor = labelColor
        // update UI
        self.labelContainer.backgroundColor = self.commentLabelColor.withAlphaComponent(UIColor.commentLabelBackgroundOpacity)
        self.label.textColor = self.commentLabelColor
        self.label.text = labelText
        UIImage.load(with: commentLabelIconUrl) { image, _ in
            if let image = image {
                self.iconImageView.image = image.withRenderingMode(.alwaysTemplate)
                self.iconImageViewHeightConstraint?.constant = Theme.iconImageHeight
            } else {
                self.iconImageViewHeightConstraint?.constant = 0
            }
        }
        setState(state: state)
    }
    
    func setState(state: LabelState) {
        // set background, border, image and text colors according to state
        switch state {
            case .notSelected:
                labelContainer.backgroundColor = .clear
                labelContainer.layer.borderWidth = 1
                labelContainer.layer.borderColor = self.commentLabelColor.withAlphaComponent(UIColor.commentLabelBorderOpacity).cgColor
                iconImageView.tintColor = commentLabelColor
                label.textColor = self.commentLabelColor
                break
            case .selected:
                self.labelContainer.backgroundColor = self.commentLabelColor.withAlphaComponent(UIColor.commentLabelSelectedBackgroundOpacity)
                labelContainer.layer.borderWidth = 0
                iconImageView.tintColor = .white
                label.textColor = .white
                break
            case .readOnly:
                labelContainer.backgroundColor = commentLabelColor.withAlphaComponent(UIColor.commentLabelBackgroundOpacity)
                labelContainer.layer.borderWidth = 0
                iconImageView.tintColor = commentLabelColor
                label.textColor = commentLabelColor
                break
        }
        self.state = state
    }
    
    func getState() -> LabelState {
        return state
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        self.backgroundColor = .clear
        switch state {
            case .selected:
                self.labelContainer.backgroundColor = self.commentLabelColor.withAlphaComponent(UIColor.commentLabelSelectedBackgroundOpacity)
                break
            case .readOnly:
                self.labelContainer.backgroundColor = self.commentLabelColor.withAlphaComponent(UIColor.commentLabelBackgroundOpacity)
                break
            case .notSelected:
                break
        }
    }

    // MARK: - Private

    private func setupUI() {
        addSubviews(labelContainer)
        configureLabelContainer()
        configureLabel()
        configureIconImageView()
    }
    
    private func configureLabelContainer() {
        labelContainer.addSubviews(iconImageView, label)
        labelContainer.layer.cornerRadius = 3
        labelContainer.pinEdges(to: self)
    }
    
    private func configureIconImageView() {
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.backgroundColor = .clear
        iconImageView.clipsToBounds = true
        iconImageView.tintAdjustmentMode = .normal
        iconImageView.layout {
            $0.width.equal(to: Theme.iconImageWidth)
            iconImageViewHeightConstraint = $0.height.equal(to: Theme.iconImageHeight)
            $0.centerY.equal(to: self.label.centerYAnchor)
            $0.leading.equal(to: self.labelContainer.leadingAnchor, offsetBy: Theme.horizontalMargin)
            $0.trailing.equal(to: self.label.leadingAnchor, offsetBy: -Theme.verticalMargin)
        }
    }
    
    private func configureLabel() {
        label.font = .preferred(style: .medium, of: Theme.fontSize)
        label.layout {
            $0.top.equal(to: labelContainer.topAnchor)
            $0.bottom.equal(to: labelContainer.bottomAnchor)
            $0.trailing.equal(to: labelContainer.trailingAnchor, offsetBy: -Theme.horizontalMargin)
        }
    }
}

// MARK: - Theme

private enum Theme {
    static let fontSize: CGFloat = 13.0
    static let iconImageHeight: CGFloat = 24.0
    static let iconImageWidth: CGFloat = 14.0
    static let horizontalMargin: CGFloat = 10.0
    static let verticalMargin: CGFloat = 5.0
}

enum LabelState {
    case notSelected, selected, readOnly
}

