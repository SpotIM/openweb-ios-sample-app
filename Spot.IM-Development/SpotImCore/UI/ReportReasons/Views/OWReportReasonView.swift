//
//  OWReportReasonView.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Foundation

class OWReportReasonView: UIView {
    fileprivate struct Metrics {
        static let identifier = "report_reason_view_id"
        static let cellIdentifier = "reportReasonCell"
    }

    fileprivate lazy var tableViewReasons: UITableView = {
        var tableViewReasons = UITableView()
        return tableViewReasons
    }()

    fileprivate let viewModel: OWReportReasonViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: OWReportReasonViewModeling = OWReportReasonViewModel()) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        setupViews()
        applyAccessibility()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWReportReasonView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
        self.addSubview(tableViewReasons)
        tableViewReasons.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupObservers() {
        bindTableView()
    }

    func bindTableView() {
        tableViewReasons.register(OWReportReasonCell.self, forCellReuseIdentifier: Metrics.cellIdentifier)

        viewModel.outputs.reportReasonCellViewModels.bind(to: tableViewReasons.rx.items(cellIdentifier: Metrics.cellIdentifier, cellType: OWReportReasonCell.self)) { (_, viewModel, cell) in
            cell.configure(with: viewModel)
        }.disposed(by: disposeBag)

        tableViewReasons.rx.modelSelected(OWReportReasonCellViewModeling.self).subscribe(onNext: { viewModel in
            print("SelectedItem: \(viewModel.outputs.title)")
        }).disposed(by: disposeBag)
    }
}

extension OWReportReasonView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

}
