//
//  OWErrorStateCell.swift
//  SpotImCore
//
//  Created by Refael Sommer on 10/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWErrorStateCell: UITableViewCell {

    fileprivate lazy var errorStateView: OWErrorStateView = {
        return OWErrorStateView()
    }()

    fileprivate var viewModel: OWErrorStateCellViewModel!
    fileprivate var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWErrorStateCellViewModel else { return }
        self.disposeBag = DisposeBag()
        self.viewModel = vm
        self.errorStateView.configure(with: self.viewModel.errorStateViewModel)
    }
}

fileprivate extension OWErrorStateCell {
    func setupViews() {
        self.backgroundColor = .clear
        self.selectionStyle = .none

        self.addSubview(errorStateView)
        errorStateView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
