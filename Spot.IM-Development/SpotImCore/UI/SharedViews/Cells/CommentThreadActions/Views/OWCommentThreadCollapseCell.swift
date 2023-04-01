//
//  OWCommentThreadCollapseCell.swift
//  SpotImCore
//
//  Created by Alon Shprung on 29/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

class OWCommentThreadCollapseCell: UITableViewCell {
    fileprivate struct Metrics {
        static let horizontalOffset: CGFloat = 16
        static let depthOffset: CGFloat = 23
    }

    fileprivate lazy var commentThreadActionsView: OWCommentThreadActionsView = {
       return OWCommentThreadActionsView()
    }()

    fileprivate var viewModel: OWCommentThreadCollapseCellViewModeling!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWCommentThreadCollapseCellViewModeling else { return }
        self.viewModel = vm

        // TODO - Add data to comment thread vm
        commentThreadActionsView.configure(with: OWCommentThreadActionsViewModel())
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

fileprivate extension OWCommentThreadCollapseCell {
    func setupUI() {
        self.backgroundColor = .clear
        self.contentView.addSubviews(commentThreadActionsView)

        commentThreadActionsView.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
        }
    }
}
