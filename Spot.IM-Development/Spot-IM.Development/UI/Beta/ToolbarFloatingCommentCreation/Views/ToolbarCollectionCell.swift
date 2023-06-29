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

class ToolbarCollectionCell: UICollectionViewCell {
    fileprivate struct Metrics {
        static let margin: CGFloat = 10
        static let size: CGFloat = CommentCreationToolbar.ToolbarMetrics.height
    }

    fileprivate lazy var titleLabel: UILabel = {
        let lbl = UILabel()
            .font(FontBook.secondaryHeadingBold)
            .textAlignment(.center)
        return lbl
    }()

    fileprivate lazy var mainArea: UIView = {
        let view = UIView()
            .backgroundColor(ColorPalette.shared.color(type: .white))

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
        mainArea.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(Metrics.size)
        }
    }

    func setupObservers() {
        disposeBag = DisposeBag()

        viewModel.outputs.emoji
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
