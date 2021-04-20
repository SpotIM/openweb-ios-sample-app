//
//  SPCommentLabelsContainerView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 20/04/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

internal final class SPCommentLabelsContainerView: BaseView {
    var labels: [CommentLabelView] = .init()
    var container: BaseStackView = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        addSubviews(container)
        configureLabels()
        configureLabelsContainer()
    }
    
    private func configureLabels() {
        let url = URL(string: "https://images.spot.im/image/upload/f_png/font-awesome/solid-chart-line-down.png")
        labels.append(CommentLabelView())
        labels.append(CommentLabelView())
        labels.append(CommentLabelView())
        labels[0].setLabel(commentLabelIconUrl: url!, labelColor: .red, labelText: "text1", state: .notSelected)
        labels[1].setLabel(commentLabelIconUrl: url!, labelColor: .red, labelText: "text2", state: .readOnly)
        labels[2].setLabel(commentLabelIconUrl: url!, labelColor: .red, labelText: "text3", state: .selected)
    }
    
    private func configureLabelsContainer() {
        container.axis = .horizontal
        container.alignment = .leading
        container.distribution = .fillEqually
        
        container.spacing = 10
        labels.forEach { label in
            container.addArrangedSubview(label)
        }

        container.layout {
            $0.width.equal(to: 350)
        }
    }
}
