//
//  OWErrorStateCell.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 10/09/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWErrorStateCell: UITableViewCell {
    private struct Metrics {
        static let padding: CGFloat = 16
        static let depthOffset: CGFloat = 23
    }

    private lazy var errorStateView: OWErrorStateView = {
        return OWErrorStateView()
    }()

    private var viewModel: OWErrorStateCellViewModel!
    private var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWErrorStateCellViewModel else { return }
        self.disposeBag = DisposeBag()
        self.viewModel = vm
        self.errorStateView.configure(with: self.viewModel.errorStateViewModel)
        self.updateUI()
    }
}

private extension OWErrorStateCell {
    func updateUI() {
        let depth = min(self.viewModel.outputs.depth, OWCommentCell.ExternalMetrics.maxDepth)
        errorStateView.OWSnp.updateConstraints { make in
            make.leading.equalToSuperview().offset(CGFloat(depth) * Metrics.depthOffset + Metrics.padding)
        }
    }

    func setupUI() {
        self.backgroundColor = .clear
        self.selectionStyle = .none

        contentView.addSubview(errorStateView)
        errorStateView.OWSnp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview().inset(Metrics.padding)
            make.leading.equalToSuperview().offset(Metrics.padding)
        }
    }
}
