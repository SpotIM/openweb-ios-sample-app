//
//  OWCommentCell.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 05/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

class OWCommentCell: UITableViewCell {
    fileprivate lazy var commentView: OWCommentView = {
       return OWCommentView()
    }()
    fileprivate var viewModel: OWCommentCellViewModeling!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWCommentCellViewModeling else { return }

        self.viewModel = vm
        self.commentView.configure(with: self.viewModel.outputs.commentVM)
        self.applyAccessibility()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        commentView.prepareForReuse()
    }
}

fileprivate extension OWCommentCell {
    func applyAccessibility() {
        self.accessibilityIdentifier = viewModel.outputs.viewAccessibilityIdentifier
    }

    func setupUI() {
        self.backgroundColor = .clear
        self.contentView.addSubviews(commentView)
        self.selectionStyle = .none

        commentView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
