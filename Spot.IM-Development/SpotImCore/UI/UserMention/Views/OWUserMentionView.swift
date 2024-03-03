//
//  OWUserMentionView.swift
//  SpotImCore
//
//  Created by Refael Sommer on 03/03/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import UIKit
import Foundation
import RxSwift

class OWUserMentionView: UIView {
    fileprivate struct Metrics {
        static let identifier = "user_mention_view_id"
        static let rowHeight: CGFloat = 56
    }

    fileprivate let viewModel: OWUserMentionViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var tableView: UITableView = {
        let tblView = UITableView()
            .separatorStyle(.none)
        tblView.allowsSelection = false
        tblView.rowHeight = Metrics.rowHeight
        tblView.register(cellClass: OWUserMentionCell.self)
        return tblView
    }()

    init(viewModel: OWUserMentionViewViewModeling = OWUserMentionViewVM()) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWUserMentionView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
    }

    func setupObservers() {
        viewModel.outputs.cellsViewModels
            .bind(to: tableView.rx.items(cellIdentifier: OWUserMentionCell.identifierName,
                                         cellType: OWUserMentionCell.self)) { _, viewModel, cell in
                cell.configure(with: viewModel)
            }
            .disposed(by: disposeBag)
    }
}
