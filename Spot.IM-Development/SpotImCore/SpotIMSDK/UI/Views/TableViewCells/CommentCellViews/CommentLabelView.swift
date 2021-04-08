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
    
    private var iconUrl: String? = nil
    private var labelText: String = "label text"
    private var commentLabelColor: UIColor = .clear
    private var state: LabelState = .hidden
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let colorString = "00ab5e"
        commentLabelColor = UIColor.color(with: colorString) ?? .clear
        setupUI()
//        iconUrl = "https://images.spot.im/image/upload/f_png/e_colorize,co_rgb:\(colorString)/font-awesome/\(iconType)-\(iconName).png"
//        let url: URL = URL(string: iconUrl!)!
//        setImage(with: url)
    }
    
    func setLabel(iconName: String?, iconType: String?, hexColor: String?, labelText: String?) {
        if let iconName = iconName, let iconType = iconType, let hexColor = hexColor, let labelText = labelText {
            let hexColorTemp = "00ab5e"
            self.commentLabelColor = UIColor.color(with: hexColorTemp) ?? .clear
            self.labelText = labelText
            // TODO: color to hex from rgb
            iconUrl = "https://images.spot.im/image/upload/f_png/e_colorize,co_rgb:\(hexColorTemp)/font-awesome/\(iconType)-\(iconName).png"
            let url: URL = URL(string: iconUrl!)!
            setImage(with: url)
        }
    }
    
    func setState(state: LabelState) {
        switch state {
            case .hidden:
                self.layout {
                    $0.height.equal(to: 0)
                }
                break
            case .idle:
                break
            case .selected:
                break
            case .readOnly:
                break
        }
        
    }
    
    private func configureLabelContainer() {
        labelContainer.addSubviews(iconImageView, label)
        labelContainer.backgroundColor = commentLabelColor.withAlphaComponent(0.1)
        labelContainer.layer.cornerRadius = 3
        labelContainer.pinEdges(to: self)
    }
    
    private func configureIconImageView() {
        iconImageView.backgroundColor = .spAvatarBG
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.backgroundColor = .clear
        iconImageView.clipsToBounds = true
        iconImageView.layout {
            $0.width.equal(to: 14)
            $0.height.equal(to: 24)
            $0.centerY.equal(to: self.label.centerYAnchor)
            $0.leading.equal(to: self.labelContainer.leadingAnchor, offsetBy: 10)
            $0.trailing.equal(to: self.label.leadingAnchor, offsetBy: -5)
        }
    }
    
    private func configureLabel() {
        label.font = .preferred(style: .medium, of: Theme.fontSize)
        label.textColor = commentLabelColor
        label.text = labelText
        label.layout {
            $0.top.equal(to: labelContainer.topAnchor, offsetBy: 5)
            $0.bottom.equal(to: labelContainer.bottomAnchor, offsetBy: -5)
            $0.trailing.equal(to: labelContainer.trailingAnchor, offsetBy: -10)
//            $0.leading.equal(to: iconImageView.trailingAnchor, offsetBy: 5)
        }
    }

    // MARK: - Private

    private func setupUI() {
        addSubviews(labelContainer)
        configureLabelContainer()
        configureLabel()
        configureIconImageView()
    }
    
    internal func setImage(with url: URL?) {
        iconImageView.setImage(with: url) { image, error in
            if error != nil {
                self.iconImageView.layout {
                    $0.width.equal(to: 0)
                }
            }
            else if let image = image {
                self.iconImageView.image = image
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

