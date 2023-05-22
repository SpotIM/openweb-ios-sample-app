//
//  OWConversationEmptyStateCell.swift
//  SpotImCore
//
//  Created by Revital Pisman on 14/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

// Should be changed to cell to support Views and small devices
class OWConversationEmptyStateCell: UITableViewCell {

    fileprivate lazy var conversationEmptyStateView: OWConversationEmptyStateView = {
        return OWConversationEmptyStateView()
    }()

    fileprivate var viewModel: OWConversationEmptyStateCellViewModeling!
    fileprivate var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWConversationEmptyStateCellViewModel else { return }

        self.viewModel = vm
        disposeBag = DisposeBag()

        conversationEmptyStateView.configure(with: self.viewModel.outputs.conversationEmptyStateViewModel)
    }
}

fileprivate extension OWConversationEmptyStateCell {
    func setupUI() {
        self.backgroundColor = .clear

        self.addSubview(conversationEmptyStateView)
        conversationEmptyStateView.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
    }
}
