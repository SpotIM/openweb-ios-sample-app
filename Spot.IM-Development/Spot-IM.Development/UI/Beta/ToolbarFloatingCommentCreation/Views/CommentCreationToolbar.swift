//
//  CommentCreationToolbar.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 27/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class CommentCreationToolbar: UIView {

    struct ToolbarMetrics {
        static let height: CGFloat = 80
    }

    fileprivate lazy var toolbarCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: ToolbarMetrics.height, height: ToolbarMetrics.height)

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.showsHorizontalScrollIndicator = false

        collection.register(cellClass: ToolbarCollectionCell.self)
        return collection
    }()

    fileprivate let viewModel: CommentCreationToolbarViewModeling
    fileprivate let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: CommentCreationToolbarViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupObservers()
    }
}

fileprivate extension CommentCreationToolbar {
    func setupUI() {
        self.addSubview(toolbarCollection)
        toolbarCollection.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(ToolbarMetrics.height)
        }
    }

    func setupObservers() {
        viewModel.outputs.toolbarCellsVM
            .observe(on: MainScheduler.instance)
            .bind(to: toolbarCollection.rx.items(cellIdentifier: ToolbarCollectionCell.identifierName, cellType: ToolbarCollectionCell.self)) { _, viewModel, cell in
                cell.configure(with: viewModel)
            }
            .disposed(by: disposeBag)

        toolbarCollection.rx.modelSelected(ToolbarCollectionCellViewModel.self)
            .map { $0 as ToolbarCollectionCellViewModeling }
            .bind(to: viewModel.inputs.modelSelected)
            .disposed(by: disposeBag)
    }
}
