//
//  PreConversationCell.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 16/12/2024.
//

import Foundation
import UIKit
import Combine

class PreConversationCell: UITableViewCell {
    static let identifier = "PreConversationCell"
    private weak var tableView: UITableView?
    private var viewModel: PreconversationCellViewModeling!
    private var cancellables = Set<AnyCancellable>()

    func configure(with viewModel: PreconversationCellViewModeling,
                   tableView: UITableView) {
        self.viewModel = viewModel
        self.tableView = tableView
        self.setupObservers()
        self.setupViews()
    }
}

private extension PreConversationCell {
    @objc func setupViews() {
        selectionStyle = .none
        self.backgroundColor = .clear
    }

    func setupObservers() {
        viewModel.outputs.showPreConversation
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] preConversation in
                guard let self, let preConversation else { return }
                contentView.addSubview(preConversation)
                preConversation.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
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
