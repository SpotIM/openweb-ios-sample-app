//
//  IndependentAdCell.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 24/12/2024.
//

import Foundation
import UIKit
import RxSwift

class IndependentAdCell: UITableViewCell {
    static let identifier = "IndependentAdCell"
    private weak var independentAdView: UIView?
    private weak var tableView: UITableView?
    private var viewModel: IndependentAdCellViewModeling!
    private let disposeBag = DisposeBag()

    func configure(with viewModel: IndependentAdCellViewModeling,
                   tableView: UITableView) {
        self.viewModel = viewModel
        self.tableView = tableView
        self.setupObservers()
        self.setupViews()
    }
}

private extension IndependentAdCell {
    func setupViews() {
        selectionStyle = .none
        self.backgroundColor = .clear
    }

    func setupObservers() {
        viewModel.outputs.adView
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] independentAdView in
                guard let self else { return }
                self.independentAdView = independentAdView
                contentView.addSubview(independentAdView)
                independentAdView.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                tableView?.beginUpdates()
                tableView?.endUpdates()
            })
            .disposed(by: disposeBag)

        viewModel.outputs.adSizeChanged
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.tableView?.beginUpdates()
                self?.tableView?.endUpdates()
            })
            .disposed(by: disposeBag)
    }
}
