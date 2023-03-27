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
    fileprivate struct Metrics {
        static let horizontalOffset: CGFloat = 16
        static let depthOffset: CGFloat = 23
    }

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

        if let depth = self.viewModel.outputs.commentVM.outputs.comment.depth {
            commentView.OWSnp.updateConstraints { make in
                make.leading.equalToSuperview().inset(CGFloat(depth) * Metrics.depthOffset + Metrics.horizontalOffset)
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        commentView.prepareForReuse()
    }
}

fileprivate extension OWCommentCell {
    func setupUI() {
        self.backgroundColor = .clear
        self.contentView.addSubviews(commentView)

        commentView.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
        }
    }
}
