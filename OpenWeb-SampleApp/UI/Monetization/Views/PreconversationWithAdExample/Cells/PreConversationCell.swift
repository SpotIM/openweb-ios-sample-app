//
//  PreConversationCell.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 16/12/2024.
//

import Foundation
import UIKit
import RxSwift

class PreConversationCell: UITableViewCell {
    static let identifier = "PreConversationCell"
    private weak var tableView: UITableView?
    private var viewModel: PreconversationCellViewModeling!
    private let disposeBag = DisposeBag()

    func configure(with viewModel: PreconversationCellViewModeling, tableView: UITableView) {
        self.viewModel = viewModel
        self.tableView = tableView
        self.setupObservers()
        self.setupViews()
    }
}

private extension PreConversationCell {
    func setupViews() {
        selectionStyle = .none
        self.backgroundColor = .clear
    }

    func setupObservers() {
        viewModel.outputs.showPreConversation
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] preConversation in
                guard let self, let preConversation else { return }
                contentView.addSubview(preConversation)
                preConversation.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                tableView?.beginUpdates()
                tableView?.endUpdates()
            })
            .disposed(by: disposeBag)

        viewModel.outputs.adSizeChanged
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] in
                self?.tableView?.beginUpdates()
                self?.tableView?.endUpdates()
            })
            .disposed(by: disposeBag)
    }
}
