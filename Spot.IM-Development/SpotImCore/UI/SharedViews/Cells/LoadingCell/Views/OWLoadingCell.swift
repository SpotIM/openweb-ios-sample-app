//
//  OWLoadingCell.swift
//  SpotImCore
//
//  Created by Refael Sommer on 18/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import Foundation

class OWLoadingCell: UITableViewCell {
    fileprivate struct Metrics {
        static let identifier = "loading_cell_id"
        static let indicatorIdentifier = "loading_cell_indicator_id"
        static let indicatorVerticalPadding: CGFloat = 10
    }

    fileprivate var viewModel: OWLoadingCellViewModeling!

    fileprivate lazy var indicator: UIActivityIndicatorView = {
        return UIActivityIndicatorView()
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        applyAccessibility()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
        applyAccessibility()
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWLoadingCellViewModel else { return }
        self.viewModel = vm
        indicator.startAnimating()
    }
}

fileprivate extension OWLoadingCell {
    func setupViews() {
        self.contentView.addSubview(indicator)
        indicator.OWSnp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(Metrics.indicatorVerticalPadding)
        }
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        indicator.accessibilityIdentifier = Metrics.indicatorIdentifier
    }
}
