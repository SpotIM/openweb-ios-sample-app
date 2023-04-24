//
//  OWSpacerCell.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 28/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

class OWSpacerCell: UITableViewCell {

    fileprivate lazy var spacerView: OWSpacerView = {
        return OWSpacerView()
    }()

    fileprivate var viewModel: OWSpacerCellViewModeling!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWSpacerCellViewModel else { return }

        self.viewModel = vm

        spacerView.configure(with: self.viewModel.outputs.spacerViewModel)
    }
}

fileprivate extension OWSpacerCell {
    func setupUI() {
        self.backgroundColor = .clear
        self.selectionStyle = .none

        self.addSubview(spacerView)
        spacerView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
