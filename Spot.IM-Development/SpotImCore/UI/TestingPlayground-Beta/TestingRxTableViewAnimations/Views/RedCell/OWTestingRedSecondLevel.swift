//
//  OWTestingRedSecondLevel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import UIKit
import RxSwift
import RxCocoa

class OWTestingRedSecondLevel: UIView {

    fileprivate struct Metrics {
        static let borderWidth: CGFloat = 2.0
        static let margin: CGFloat = 10.0
        static let roundCorners: CGFloat = 10.0
        static let padding: CGFloat = 8.0
        static let collapsedCellContentHeight: CGFloat = 110.0
        static let expandedCellContentHeight: CGFloat = 170.0
    }

    fileprivate lazy var lblIdentifier: UILabel = {
        return UILabel()
            .textColor(.black)
            .numberOfLines(1)
            .font(OWFontBook.shared.font(style: .regular, size: 15.0))
    }()

    fileprivate lazy var btnRemove: UIButton = {
        return "Remove"
            .button
            .backgroundColor(.lightGray)
            .textColor(.black)
            .withPadding(Metrics.padding)
            .corner(radius: Metrics.roundCorners)
            .font(OWFontBook.shared.font(style: .regular, size: 15.0))
    }()

    fileprivate lazy var btnState: UIButton = {
        return "Expand"
            .button
            .backgroundColor(.lightGray)
            .textColor(.black)
            .withPadding(Metrics.padding)
            .corner(radius: Metrics.roundCorners)
            .font(OWFontBook.shared.font(style: .regular, size: 15.0))
    }()

    fileprivate var viewModel: OWTestingRedSecondLevelViewModeling!
    fileprivate var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: OWTestingRedSecondLevelViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        setupObservers()
    }
}

fileprivate extension OWTestingRedSecondLevel {
    func setupUI() {
        self .backgroundColor(.red)
            .border(width: Metrics.borderWidth, color: .gray)
            .corner(radius: Metrics.roundCorners)

        self.OWSnp.makeConstraints { make in
            make.height.equalTo(Metrics.collapsedCellContentHeight)
        }

        self.addSubview(lblIdentifier)
        lblIdentifier.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.margin)
            make.leading.trailing.equalToSuperview().inset(Metrics.margin)
        }

        self.addSubview(btnState)
        btnState.OWSnp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-Metrics.margin)
            make.leading.equalToSuperview().offset(Metrics.margin)
        }

        self.addSubview(btnRemove)
        btnRemove.OWSnp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-Metrics.margin)
            make.trailing.equalToSuperview().offset(-Metrics.margin)
        }
    }

    func setupObservers() {
        lblIdentifier.text = "Cell ID: \(viewModel.outputs.id)"

        btnRemove.rx.tap
            .bind(to: viewModel.inputs.removeTap)
            .disposed(by: disposeBag)

        btnState.rx.tap
            .bind(to: viewModel.inputs.changeCellStateTap)
            .disposed(by: disposeBag)
    }
}

#endif
