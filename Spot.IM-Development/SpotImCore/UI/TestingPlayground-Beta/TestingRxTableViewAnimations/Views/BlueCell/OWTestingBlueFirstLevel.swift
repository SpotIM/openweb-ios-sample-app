//
//  OWTestingBlueFirstLevel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import UIKit

class OWTestingBlueFirstLevel: UIView {

    fileprivate struct Metrics {
        static let borderWidth: CGFloat = 2.0
    }

    fileprivate var viewModel: OWTestingBlueFirstLevelViewModeling!

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: OWTestingBlueFirstLevelViewModeling) {
        self.viewModel = viewModel
    }
}

fileprivate extension OWTestingBlueFirstLevel {
    func setupUI() {
        self.backgroundColor = .blue
        self.border(width: Metrics.borderWidth, color: .gray)
    }
}

#endif
