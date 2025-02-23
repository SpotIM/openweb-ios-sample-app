//
//  IndependentAdCell.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 24/12/2024.
//

import Foundation
import UIKit
import Combine

class IndependentAdCell: UITableViewCell {
    static let identifier = "IndependentAdCell"
    private weak var tableView: UITableView?
    private var viewModel: IndependentAdCellViewModeling!
    private var cancellables = Set<AnyCancellable>()

    private struct Metrics {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 16
    }

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
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] independentAdView in
                guard let self else { return }
                contentView.addSubview(independentAdView)
                independentAdView.snp.makeConstraints { make in
                    make.top.bottom.equalToSuperview().inset(Metrics.verticalPadding)
                    make.leading.trailing.equalToSuperview().inset(Metrics.horizontalPadding)
                }
                tableView?.beginUpdates()
                tableView?.endUpdates()
            })
            .store(in: &cancellables)

        viewModel.outputs.adSizeChanged
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.tableView?.beginUpdates()
                self?.tableView?.endUpdates()
            })
            .store(in: &cancellables)
    }
}
