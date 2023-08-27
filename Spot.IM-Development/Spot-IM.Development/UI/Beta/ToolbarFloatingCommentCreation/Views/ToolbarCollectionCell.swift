//
//  ToolbarCollectionCell.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 27/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

#if NEW_API

class ToolbarCollectionCell: UICollectionViewCell {
    fileprivate struct Metrics {
        static let margin: CGFloat = 5
        static let size: CGFloat = CommentCreationToolbar.ToolbarMetrics.height
        static let accessibilitySurfix = "toolbar_cell_id"
    }

    fileprivate lazy var titleLabel: UILabel = {
        let lbl = UILabel()
            .font(FontBook.mainHeadingBold)
            .textAlignment(.center)
        return lbl
    }()

    fileprivate lazy var mainArea: UIView = {
        let view = UIView()

        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Metrics.margin)
        }

        return view
    }()

    fileprivate var disposeBag: DisposeBag!
    fileprivate var viewModel: ToolbarCollectionCellViewModeling!

    func configure(with viewModel: ToolbarCollectionCellViewModeling) {
        self.viewModel = viewModel
        self.updateAccessibility()
        self.setupObservers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }

    override func prepareForReuse() {
        titleLabel.text = ""
    }
}

fileprivate extension ToolbarCollectionCell {
    func setupUI() {
        contentView.addSubview(mainArea)
        mainArea.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(Metrics.size)
        }
    }

    func updateAccessibility() {
        self.accessibilityIdentifier = "\(viewModel.outputs.accessibilityPrefix)_\(Metrics.accessibilitySurfix)"
    }

    func setupObservers() {
        disposeBag = DisposeBag()

        viewModel.outputs.emoji
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

#endif
