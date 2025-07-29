//
//  CommentCreationToolbar.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 27/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import CombineDataSources
import SnapKit

class CommentCreationToolbar: UIView {

    struct ToolbarMetrics {
        static let height: CGFloat = 50
    }

    private struct Metrics {
        static let accessibility = "comment_creation_toolbar_id"
    }

    private lazy var toolbarCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: ToolbarMetrics.height, height: ToolbarMetrics.height)

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.register(cellClass: ToolbarCollectionCell.self)
        return collection
    }()

    private let viewModel: CommentCreationToolbarViewModeling
    private var cancellables = Set<AnyCancellable>()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: CommentCreationToolbarViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        applyAccessibility()
        setupObservers()
    }
}

private extension CommentCreationToolbar {
    func setupUI() {
        self.addSubview(toolbarCollection)
        toolbarCollection.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(ToolbarMetrics.height)
        }
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.accessibility
    }

    func setupObservers() {
        viewModel.outputs.toolbarCellsVM
            .unwrap()
            .receive(on: DispatchQueue.main)
            .bind(to: toolbarCollection.itemsSubscriber(cellType: ToolbarCollectionCell.self) { cell, _, viewModel in
                cell.configure(with: viewModel)
            })
            .store(in: &cancellables)

        let modelSelectedPublisher = toolbarCollection.didSelectItemPublisher
            .map { [weak self] indexPath in
                guard let self, let cellsVM = viewModel.outputs.toolbarCellsVM.value, indexPath.item < cellsVM.count else {
                    return nil as ToolbarCollectionCellViewModeling?
                }
                return cellsVM[indexPath.item]
            }
            .unwrap()

        modelSelectedPublisher
            .bind(to: viewModel.inputs.modelSelected)
            .store(in: &cancellables)
    }
}
