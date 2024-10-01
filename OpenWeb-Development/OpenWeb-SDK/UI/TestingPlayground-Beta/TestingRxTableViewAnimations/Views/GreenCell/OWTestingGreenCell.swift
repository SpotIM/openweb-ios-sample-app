//
//  OWTestingGreenCell.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

#if BETA

import UIKit
import RxSwift
import RxCocoa

class OWTestingGreenCell: UITableViewCell {

    private struct Metrics {
        static let margin: CGFloat = 20.0
        static let roundCorners: CGFloat = 10.0
        static let padding: CGFloat = 8.0
        static let collapsedCellContentHeight: CGFloat = 120.0
        static let expandedCellContentHeight: CGFloat = 180.0
    }

    private lazy var cellContent: UIView = {
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

    private lazy var lblIdentifier: UILabel = {
        return UILabel()
            .textColor(.black)
            .numberOfLines(1)
            .font(OWFontBook.shared.font(typography: .bodyText))
    }()

    private lazy var btnRemove: UIButton = {
        return "Remove"
            .button
            .backgroundColor(.lightGray)
            .textColor(.black)
            .withPadding(Metrics.padding)
            .corner(radius: Metrics.roundCorners)
            .font(OWFontBook.shared.font(typography: .bodyText))
    }()

    private lazy var btnState: UIButton = {
        return "Expand"
            .button
            .backgroundColor(.lightGray)
            .textColor(.black)
            .withPadding(Metrics.padding)
            .corner(radius: Metrics.roundCorners)
            .font(OWFontBook.shared.font(typography: .bodyText))
    }()

    private var viewModel: OWTestingGreenCellViewModeling!
    private var disposeBag = DisposeBag()

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
        ensureCorrectState()
    }
}

private extension OWTestingGreenCell {
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

        viewModel.outputs.changedCellState
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

                self.cellContent.OWSnp.updateConstraints { make in
                    make.height.equalTo(height)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.changedCellState
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
       viewModel.outputs.changedCellState
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

                self.cellContent.OWSnp.updateConstraints { make in
                    make.height.equalTo(height)
                }
            })
            .disposed(by: disposeBag)
    }
}

#endif
