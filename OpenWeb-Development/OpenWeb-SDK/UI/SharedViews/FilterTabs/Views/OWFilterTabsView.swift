//
//  OWFilterTabsView.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 03/06/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWFilterTabsView: UIView {
    struct FilterTabsMetrics {
        static let itemsHeight: CGFloat = 34
    }

    fileprivate struct Metrics {
        static let identifier = "filter_tabs_view_id"
        static let height: CGFloat = 54
    }

    fileprivate var viewModel: OWFilterTabsViewViewModeling
    fileprivate var disposeBag = DisposeBag()

    fileprivate lazy var filterTabsCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.register(cellClass: OWFilterTabsCollectionCell.self)
        return collection
    }()

    init(viewModel: OWFilterTabsViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        applyIdentifiers()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWFilterTabsView {
    func setupViews() {
        self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: .light)

        self.OWSnp.makeConstraints { make in
            make.height.equalTo(Metrics.height)
        }

        self.addSubviews(filterTabsCollection)
        filterTabsCollection.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(0)
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                filterTabsCollection.reloadData()
            })
            .disposed(by: disposeBag)

        viewModel.outputs.tabs
            .observe(on: MainScheduler.instance)
            .bind(to: filterTabsCollection.rx.items(cellIdentifier: OWFilterTabsCollectionCell.identifierName, cellType: OWFilterTabsCollectionCell.self)) { _, viewModel, cell in
                cell.configure(with: viewModel)
            }
            .disposed(by: disposeBag)

        filterTabsCollection.rx.modelSelected(OWFilterTabsCollectionCellViewModel.self)
            .map { $0 as OWFilterTabsCollectionCellViewModel }
            .bind(to: viewModel.inputs.selectTab)
            .disposed(by: disposeBag)

        // Center collectionView content
        filterTabsCollection.rx.observe(CGSize.self, #keyPath(UICollectionView.contentSize))
            .unwrap()
            .withLatestFrom(viewModel.outputs.minimumLeadingTrailingMargin) { ($0, $1) }
            .subscribe(onNext: { [weak self] contentSize, minimumLeadingTrailingMargin in
                guard let self = self else { return }
                let maxWidth = self.frame.size.width
                let horizontalMargins = max((maxWidth - contentSize.width) / 2, minimumLeadingTrailingMargin)
                self.filterTabsCollection.OWSnp.updateConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(horizontalMargins)
                }
            })
            .disposed(by: disposeBag)
    }

    func applyIdentifiers() {
        self.accessibilityIdentifier = Metrics.identifier
    }
}
