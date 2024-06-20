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
        static let skeletonsWidth: CGFloat = 100
    }

    fileprivate struct Metrics {
        static let identifier = "filter_tabs_view_id"
        static let height: CGFloat = 54
        static let delayScrollToSelected = 50
    }

    fileprivate var viewModel: OWFilterTabsViewViewModeling
    fileprivate var disposeBag = DisposeBag()

    fileprivate lazy var filterTabsCollectionView: UICollectionView = {
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

    fileprivate lazy var filterTabsDataSource: OWRxCollectionViewSectionedAnimatedDataSource<FilterTabsDataSourceModel> = {
        let dataSource = OWRxCollectionViewSectionedAnimatedDataSource<FilterTabsDataSourceModel>(decideViewTransition: { [weak self] _, _, _ in
            return .reload
        }, configureCell: { [weak self] _, collectionView, indexPath, item -> UICollectionViewCell in
            guard let self = self else { return UICollectionViewCell() }
            let cell = collectionView.dequeueReusableCellAndReigsterIfNeeded(cellClass: item.cellClass, for: indexPath)
            cell.configure(with: item.viewModel)

            return cell
        })

        let animationConfiguration = OWAnimationConfiguration(insertAnimation: .top, reloadAnimation: .none, deleteAnimation: .fade)
        dataSource.animationConfiguration = animationConfiguration
        return dataSource
    }()

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

        self.addSubviews(filterTabsCollectionView)
        filterTabsCollectionView.OWSnp.makeConstraints { make in
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
                self.filterTabsCollectionView.reloadData()
            })
            .disposed(by: disposeBag)

        viewModel.outputs.filterTabsDataSourceModel
            .observe(on: MainScheduler.instance)
            .bind(to: filterTabsCollectionView.rx.items(dataSource: filterTabsDataSource))
            .disposed(by: disposeBag)

        // Scroll to selected tab
        viewModel.outputs.selectedTab
            .voidify()
            .delay(.milliseconds(Metrics.delayScrollToSelected), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .withLatestFrom(viewModel.outputs.tabs)
            .subscribe(onNext: { [weak self] tabs in
                guard let self = self,
                      let index = tabs.firstIndex(where: { $0.outputs.isSelectedNonRx }) else { return }
                self.filterTabsCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
            })
            .disposed(by: disposeBag)

        filterTabsCollectionView.rx.modelSelected(OWFilterTabsCellOption.self)
            .map { $0.viewModel as? OWFilterTabsCollectionCellViewModel }
            .unwrap()
            .bind(to: viewModel.inputs.selectTab)
            .disposed(by: disposeBag)

        // Center collectionView content
        filterTabsCollectionView.rx.observe(CGSize.self, #keyPath(UICollectionView.contentSize))
            .unwrap()
            .withLatestFrom(viewModel.outputs.minimumLeadingTrailingMargin) { ($0, $1) }
            .subscribe(onNext: { [weak self] contentSize, minimumLeadingTrailingMargin in
                guard let self = self else { return }
                let maxWidth = self.frame.size.width
                let horizontalMargins = max((maxWidth - contentSize.width) / 2, minimumLeadingTrailingMargin)
                self.filterTabsCollectionView.OWSnp.updateConstraints { make in
                    make.leading.trailing.equalToSuperview().inset(horizontalMargins)
                }
            })
            .disposed(by: disposeBag)
    }

    func applyIdentifiers() {
        self.accessibilityIdentifier = Metrics.identifier
    }
}
