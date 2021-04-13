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
    
    func setLabel(iconName: String?, iconType: String?, rgbColor: String?, labelText: String?, state: LabelState) {
        if let iconName = iconName, let iconType = iconType, let rgbColor = rgbColor, let labelText = labelText {
            let hexColor = UIColor.rgbToHex(with: rgbColor) ?? "blue"
            self.commentLabelColor = UIColor.color(with: hexColor) ?? .orange
            // TODO: change icon color withour re-fetching it
            let iconUrl = "https://images.spot.im/image/upload/f_png/e_colorize,co_rgb:\(hexColor)/font-awesome/\(iconType)-\(iconName).png"
            let url: URL = URL(string: iconUrl)!
            // update UI
            DispatchQueue.main.async() {
                self.setImage(with: url)
                self.labelContainer.backgroundColor = self.commentLabelColor.withAlphaComponent(0.1)
                self.label.textColor = self.commentLabelColor
                self.label.text = labelText
                self.setState(state: state)
            }
        } else {
            // update UI
            DispatchQueue.main.async() {
                self.setImage(with: nil)
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
    
    internal func setImage(with url: URL?) {
        iconImageView.setImage(with: url) { image, error in
            if error != nil {
                self.iconImageViewHeightConstraint?.constant = 0
            }
            else if let image = image {
                self.iconImageView.image = image
                self.iconImageViewHeightConstraint?.constant = 25
            }
        }
    }
}

// MARK: - Theme

private enum Theme {
    static let fontSize: CGFloat = 13.0
}

enum LabelState {
    case hidden, idle, selected, readOnly
}

