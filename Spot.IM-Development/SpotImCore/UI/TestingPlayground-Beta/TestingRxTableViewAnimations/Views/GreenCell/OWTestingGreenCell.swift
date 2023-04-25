//
//  OWTestingGreenCell.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import UIKit

class OWTestingGreenCell: UITableViewCell {

    fileprivate struct Metrics {

    }

    fileprivate var viewModel: OWTestingGreenCellViewModeling!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWTestingGreenCellViewModeling else { return }
        self.viewModel = vm
    }
}

fileprivate extension OWTestingGreenCell {
    func setupUI() {
        self.backgroundColor = .green
        self.selectionStyle = .none
    }
}

#endif
