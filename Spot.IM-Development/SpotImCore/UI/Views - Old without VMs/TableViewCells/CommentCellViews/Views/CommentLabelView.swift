//
//  CommentLabelView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 06/04/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

internal final class CommentLabelView: SPBaseView {
    fileprivate struct Metrics {
        static let identifier = "comment_label_id"
    }

    private let labelContainer = SPBaseView()
    private let iconImageView = SPBaseUIImageView()
    private let label = SPBaseLabel()

    private var commentLabelColor: UIColor = .clear
    private var state: OWLabelState = .readOnly

    var id = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.accessibilityIdentifier = Metrics.identifier
        setupUI()
    }

    func setLabel(commentLabelIconUrl: URL, labelColor: UIColor, labelText: String, labelId: String, state: OWLabelState) {
        self.id = labelId
        self.commentLabelColor = labelColor
        // update UI
        self.labelContainer.backgroundColor = self.commentLabelColor.withAlphaComponent(UIColor.commentLabelBackgroundOpacity)
        self.label.textColor = self.commentLabelColor
        self.label.text = labelText
        UIImage.load(with: commentLabelIconUrl) { [weak self] image, _ in
            guard let self = self else { return }

            var iconHeight = 0.0
            if let image = image {
                self.iconImageView.image = image.withRenderingMode(.alwaysTemplate)
                iconHeight = Theme.iconImageHeight
            }

            self.iconImageView.OWSnp.updateConstraints { make in
                make.height.equalTo(iconHeight)
            }
        }
        setState(state: state)
    }

    func setState(state: OWLabelState) {
        // set background, border, image and text colors according to state
        switch state {
            case .notSelected:
                labelContainer.backgroundColor = .clear
                labelContainer.layer.borderWidth = 1
                labelContainer.layer.borderColor = self.commentLabelColor.withAlphaComponent(UIColor.commentLabelBorderOpacity).cgColor
                iconImageView.tintColor = commentLabelColor
                label.textColor = self.commentLabelColor

            case .selected:
                self.labelContainer.backgroundColor = self.commentLabelColor.withAlphaComponent(UIColor.commentLabelSelectedBackgroundOpacity)
                labelContainer.layer.borderWidth = 0
                iconImageView.tintColor = .white
                label.textColor = .white

            case .readOnly:
                labelContainer.backgroundColor = commentLabelColor.withAlphaComponent(UIColor.commentLabelBackgroundOpacity)
                labelContainer.layer.borderWidth = 0
                iconImageView.tintColor = commentLabelColor
                label.textColor = commentLabelColor

        }
        self.state = state
    }

    func getState() -> OWLabelState {
        return state
    }

    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        self.backgroundColor = .clear
        switch state {
            case .selected:
                self.labelContainer.backgroundColor = self.commentLabelColor.withAlphaComponent(UIColor.commentLabelSelectedBackgroundOpacity)

            case .readOnly:
                self.labelContainer.backgroundColor = self.commentLabelColor.withAlphaComponent(UIColor.commentLabelBackgroundOpacity)

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
        labelContainer.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configureIconImageView() {
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.backgroundColor = .clear
        iconImageView.clipsToBounds = true
        iconImageView.tintAdjustmentMode = .normal
        iconImageView.OWSnp.makeConstraints { make in
            make.width.equalTo(Theme.iconImageWidth)
            make.height.equalTo(Theme.iconImageHeight)
            make.centerY.equalTo(label)
            make.leading.equalToSuperview().offset(Theme.horizontalMargin)
            make.trailing.equalTo(label.OWSnp.leading).offset(-Theme.iconTrailingOffset)
        }
    }

    private func configureLabel() {
        label.font = .spPreferred(style: .medium, of: Theme.fontSize)
        label.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-Theme.horizontalMargin)
        }
    }
}

// MARK: - Theme

private enum Theme {
    static let fontSize: CGFloat = 13.0
    static let iconImageHeight: CGFloat = 24.0
    static let iconImageWidth: CGFloat = 14.0
    static let horizontalMargin: CGFloat = 10.0
    static let iconTrailingOffset: CGFloat = 5.0
}

enum OWLabelState {
    case notSelected, selected, readOnly
}

