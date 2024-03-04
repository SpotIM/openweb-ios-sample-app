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
        static let maxNumberOfCellsHeight = 2.7
        static let heightAnimationDuration: CGFloat = 0.2
    }

    fileprivate let viewModel: OWUserMentionViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
            .separatorStyle(.none)
        tableView.allowsSelection = false
        tableView.rowHeight = Metrics.rowHeight
        tableView.register(cellClass: OWUserMentionCell.self)
        return tableView
    }()

    fileprivate var heightContraint: OWConstraint?

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
        self.OWSnp.makeConstraints { make in
            make.height.equalTo(0)
        }

        self.addSubviews(tableView)
        tableView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupObservers() {
        viewModel.outputs.cellsViewModels
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: OWUserMentionCell.identifierName,
                                         cellType: OWUserMentionCell.self)) { _, viewModel, cell in
                cell.configure(with: viewModel)
            }
            .disposed(by: disposeBag)

        viewModel.outputs.cellsViewModels
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] cellsViewModels in
                guard let self = self else { return }
                let maxHeight = CGFloat(Metrics.maxNumberOfCellsHeight) * Metrics.rowHeight
                let wantedHeight = CGFloat(cellsViewModels.count) * Metrics.rowHeight
                let newHeight = min(maxHeight, wantedHeight)
                self.OWSnp.updateConstraints { make in
                    make.height.equalTo(newHeight)
                }

                UIView.animate(withDuration: Metrics.heightAnimationDuration) {
                    self.superview?.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }
}
