//
//  OWTestingGreenCell.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import UIKit
import RxSwift
import RxCocoa

class OWTestingGreenCell: UITableViewCell {

    fileprivate struct Metrics {
        static let margin: CGFloat = 20.0
        static let roundCorners: CGFloat = 10.0
        static let padding: CGFloat = 8.0
        static let collapsedCellContentHeight: CGFloat = 120.0
        static let expandedCellContentHeight: CGFloat = 160.0
    }

    fileprivate lazy var cellContent: UIView = {
        let view = UIView()
            .backgroundColor(.green)
            .corner(radius: Metrics.roundCorners)

        view.addSubview(lblIdentifier)
        lblIdentifier.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.margin)
            make.leading.trailing.equalToSuperview().inset(Metrics.margin)
        }

        view.addSubview(btnState)
        btnState.OWSnp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-Metrics.margin)
            make.leading.equalToSuperview().offset(Metrics.margin)
        }

        view.addSubview(btnRemove)
        btnRemove.OWSnp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-Metrics.margin)
            make.trailing.equalToSuperview().offset(-Metrics.margin)
        }

        return view
    }()

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

    fileprivate var viewModel: OWTestingGreenCellViewModeling!
    fileprivate var disposeBag = DisposeBag()

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
        self.disposeBag = DisposeBag()
        setupObservers()
    }
}

fileprivate extension OWTestingGreenCell {
    func setupUI() {
        self.backgroundColor = .clear
        self.selectionStyle = .none

        contentView.addSubview(cellContent)
        cellContent.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Metrics.padding)
            make.height.equalTo(Metrics.collapsedCellContentHeight)
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
