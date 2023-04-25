//
//  OWTestingRedSecondLevel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import UIKit

class OWTestingRedSecondLevel: UIView {

    fileprivate struct Metrics {
        static let borderWidth: CGFloat = 2.0
        static let buttonsMargin: CGFloat = 10.0
    }

    fileprivate lazy var btnRemove: UIButton = {
        return "Remove"
            .button
            .backgroundColor(.lightGray)
            .textColor(.black)
            .font(OWFontBook.shared.font(style: .regular, size: 15.0))
    }()

    fileprivate lazy var btnState: UIButton = {
        return "Expand"
            .button
            .backgroundColor(.lightGray)
            .textColor(.black)
            .font(OWFontBook.shared.font(style: .regular, size: 15.0))
    }()

    fileprivate var viewModel: OWTestingRedSecondLevelViewModeling!

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: OWTestingRedSecondLevelViewModeling) {
        self.viewModel = viewModel
    }
}

fileprivate extension OWTestingRedSecondLevel {
    func setupUI() {
        self.backgroundColor = .red
        self.border(width: Metrics.borderWidth, color: .gray)

        self.addSubview(btnState)
        btnState.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(Metrics.buttonsMargin)
        }

        self.addSubview(btnRemove)
        btnRemove.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-Metrics.buttonsMargin)
        }
    }
}

#endif
