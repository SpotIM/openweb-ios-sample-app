//
//  OWTestingBlueFirstLevel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import UIKit
import RxSwift
import RxCocoa

class OWTestingBlueFirstLevel: UIView {

    fileprivate struct Metrics {
        static let borderWidth: CGFloat = 2.0
        static let margin: CGFloat = 15.0
        static let roundCorners: CGFloat = 10.0
        static let padding: CGFloat = 8.0
        static let collapsedCellContentHeight: CGFloat = 115.0
        static let expandedCellContentHeight: CGFloat = 175.0
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

    fileprivate var viewModel: OWTestingBlueFirstLevelViewModeling!
    fileprivate var disposeBag = DisposeBag()
    fileprivate var heightConstraint: OWConstraint?

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: OWTestingBlueFirstLevelViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        setupObservers()
        ensureCorrectState()
    }
}

fileprivate extension OWTestingBlueFirstLevel {
    func setupUI() {
        self .backgroundColor(.blue)
            .border(width: Metrics.borderWidth, color: .gray)
            .corner(radius: Metrics.roundCorners)

        self.OWSnp.makeConstraints { make in
            heightConstraint = make.height.equalTo(Metrics.collapsedCellContentHeight).constraint
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

        viewModel.outputs.changeCellState
            .skip(1)
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }

                let height: CGFloat
                switch state {
                case .collapsed:
                    height = Metrics.collapsedCellContentHeight
                case .expanded:
                    height = Metrics.expandedCellContentHeight
                }

                self.heightConstraint?.update(offset: height)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.changeCellState
            .map { state -> String in
                let text: String
                switch state {
                case .collapsed:
                    text = "Expand"
                case .expanded:
                    text = "Collapse"
                }

                return text
            }
            .subscribe(onNext: { [weak self] title in
                self?.btnState.setTitle(title, for: .normal)
            })
            .disposed(by: disposeBag)
    }

    /*
     This is essential as the cells being reused and sometime and expanded cell might be reused.
     Here we are ensuring that as soon as the cell configured with a new VM - the correct size updated via the VM output which we use instantly.
     Note that `changeCellState` have share(reply:1) - means that we getting instantly the last value it had.
     Setting collapsed height in prepare for reuse won't be enough - as this will cause expanded cells to show as collapsed after scrolling away and back to them.
     We must ensure correct size as soon as we configure with a new VM.
     Lastly, since the cell is going to be shown, an animation already happen it the table view - that's why we don't need to update the view side about this height change as the table view already in "animation" mode while the cell created after the cell re-added to the table (from prepareForReuse).
     */
    func ensureCorrectState() {
       viewModel.outputs.changeCellState
            .take(1)
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }

                let height: CGFloat
                switch state {
                case .collapsed:
                    height = Metrics.collapsedCellContentHeight
                case .expanded:
                    height = Metrics.expandedCellContentHeight
                }

                self.heightConstraint?.update(offset: height)
            })
            .disposed(by: disposeBag)
    }
}

#endif
