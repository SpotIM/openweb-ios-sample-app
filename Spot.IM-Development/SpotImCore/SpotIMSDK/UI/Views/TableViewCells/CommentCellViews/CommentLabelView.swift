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
    
    private var commentLabelColor: UIColor = .clear
    private var state: LabelState = .readOnly
    
    private var commentLabelViewHeightConstraint: NSLayoutConstraint?
    private var iconImageViewHeightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func setLabel(commentLabelIconUrl: URL?, rgbColor: String?, labelText: String?, state: LabelState) {
        if let commentLabelIconUrl = commentLabelIconUrl, let rgbColor = rgbColor, let labelText = labelText {
            let hexColor = UIColor.rgbToHex(with: rgbColor) ?? "blue"
            self.commentLabelColor = UIColor.color(with: hexColor) ?? .orange
            // update UI
            DispatchQueue.main.async() {
                self.labelContainer.backgroundColor = self.commentLabelColor.withAlphaComponent(0.1)
                self.label.textColor = self.commentLabelColor
                self.label.text = labelText
                self.setState(state: state)
                UIImage.load(with: commentLabelIconUrl) { image, _ in
                    if let image = image {
                        self.iconImageView.image = image
                        self.iconImageView.image = image.withRenderingMode(.alwaysTemplate)
                        self.iconImageView.tintColor = self.commentLabelColor
                        self.iconImageViewHeightConstraint?.constant = 25
                    } else {
                        self.iconImageViewHeightConstraint?.constant = 0
                    }
                }
            }
        } else {
            // update UI
            DispatchQueue.main.async() {
                self.iconImageViewHeightConstraint?.constant = 0
                self.labelContainer.backgroundColor = .clear
                self.label.textColor = .clear
                self.label.text = ""
                self.setState(state: state)
            }
        }
    }
    
    // TODO
    func setState(state: LabelState) {
        switch state {
            case .hidden:
                commentLabelViewHeightConstraint?.constant = 0
                break
            case .idle:
                break
            case .selected:
                break
            case .readOnly:
                commentLabelViewHeightConstraint?.constant = 28
                break
        }
        self.state = state
        
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
        iconImageView.layout {
            $0.width.equal(to: 14)
            iconImageViewHeightConstraint = $0.height.equal(to: 24)
            $0.centerY.equal(to: self.label.centerYAnchor)
            $0.leading.equal(to: self.labelContainer.leadingAnchor, offsetBy: 10)
            $0.trailing.equal(to: self.label.leadingAnchor, offsetBy: -5)
        }
    }
    
    private func configureLabel() {
        label.font = .preferred(style: .medium, of: Theme.fontSize)
        label.layout {
            $0.top.equal(to: labelContainer.topAnchor, offsetBy: 5)
            $0.bottom.equal(to: labelContainer.bottomAnchor, offsetBy: -5)
            $0.trailing.equal(to: labelContainer.trailingAnchor, offsetBy: -10)
        }
    }

    // MARK: - Private

    private func setupUI() {
        addSubviews(labelContainer)
        self.layout {
            commentLabelViewHeightConstraint = $0.height.equal(to: 0)
        }
        configureLabelContainer()
        configureLabel()
        configureIconImageView()
    }
}

// MARK: - Theme

private enum Theme {
    static let fontSize: CGFloat = 13.0
}

enum LabelState {
    case hidden, idle, selected, readOnly
}

