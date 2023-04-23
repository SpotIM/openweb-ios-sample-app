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

#if NEW_API

class OWReportReasonView: UIView {
    fileprivate struct Metrics {
        static let identifier = "report_reason_view_id"
        static let cellIdentifier = "reportReasonCell"
        static let titleViewIdentifier = "title_view_id"
        static let titleLabelIdentifier = "title_label_id"
        static let cellHeight: CGFloat = 68
        static let titleFontSize: CGFloat = 15
        static let titleViewHeight: CGFloat = 70
        static let titleLeadingPadding: CGFloat = 16
    }

    fileprivate lazy var titleView: UIView = {
        let titleView = UIView()
        return titleView
    }()

    fileprivate lazy var titleLabel: UILabel = {
        return viewModel.outputs.title
                .label
                .font(UIFont.preferred(style: .bold, of: Metrics.titleFontSize))
    }()

    fileprivate lazy var tableViewReasons: UITableView = {
        var tableViewReasons = UITableView()
        tableViewReasons.separatorStyle = .none
        tableViewReasons.delegate = self
        return tableViewReasons
    }()

    fileprivate let viewModel: OWReportReasonViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: OWReportReasonViewViewModeling = OWReportReasonViewViewModel()) {
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
        titleView.accessibilityIdentifier = Metrics.titleViewIdentifier
        titleLabel.accessibilityIdentifier = Metrics.titleLabelIdentifier
    }

    func setupViews() {
        self.addSubview(titleView)
        titleView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.titleViewHeight)
        }

        titleView.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Metrics.titleLeadingPadding)
            make.centerY.equalToSuperview()
        }

        self.addSubview(tableViewReasons)
        tableViewReasons.OWSnp.makeConstraints { make in
            make.top.equalTo(titleView.OWSnp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func setupObservers() {
        bindTableView()
    }

    func bindTableView() {
        tableViewReasons.register(OWReportReasonCell.self, forCellReuseIdentifier: Metrics.cellIdentifier)

        viewModel.outputs.reportReasonCellViewModels
            .bind(to: tableViewReasons.rx.items(cellIdentifier: Metrics.cellIdentifier, cellType: OWReportReasonCell.self)) { (_, viewModel, cell) in
            cell.configure(with: viewModel)
        }.disposed(by: disposeBag)

        tableViewReasons.rx.modelDeselected(OWReportReasonCellViewModeling.self)
            .subscribe(onNext: { viewModel in
            viewModel.inputs.setSelected.onNext(false)
        }).disposed(by: disposeBag)

        tableViewReasons.rx.modelSelected(OWReportReasonCellViewModeling.self)
            .subscribe(onNext: { viewModel in
            viewModel.inputs.setSelected.onNext(true)
        }).disposed(by: disposeBag)
    }
}

extension OWReportReasonView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Metrics.cellHeight
    }

}

#endif
