//
//  OWTestingRedFirstLevel.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

#if BETA

import UIKit

class OWTestingRedFirstLevel: UIView {

    private struct Metrics {
        static let insetForSecondLevel: CGFloat = 5.0
        static let roundCorners: CGFloat = 10.0
        static let borderWidth: CGFloat = 2.0
    }

    private lazy var secondLevelView: OWTestingRedSecondLevel = {
        return OWTestingRedSecondLevel()
    }()

    private var viewModel: OWTestingRedFirstLevelViewModeling!

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: OWTestingRedFirstLevelViewModeling) {
        self.viewModel = viewModel
        secondLevelView.configure(with: self.viewModel.outputs.secondLevelVM)
    }
}

private extension OWTestingRedFirstLevel {
    func setupUI() {
        self .backgroundColor(.red)
            .border(width: Metrics.borderWidth, color: .gray)
            .corner(radius: Metrics.roundCorners)

        self.addSubview(secondLevelView)
        secondLevelView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Metrics.insetForSecondLevel)
        }
    }
}

#endif
