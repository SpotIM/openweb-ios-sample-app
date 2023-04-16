//
//  OWConversationView.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWConversationView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let conversationTitleHeaderHeight: CGFloat = 56
        static let articleDescriptionHeight: CGFloat = 86
        static let conversationSummaryHeight: CGFloat = 44
    }

    fileprivate lazy var conversationTitleHeaderView: OWConversationTitleHeaderView = {
        return OWConversationTitleHeaderView(viewModel: self.viewModel.outputs.conversationTitleHeaderViewModel)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var articleDescriptionView: OWArticleDescriptionView = {
        return OWArticleDescriptionView(viewModel: self.viewModel.outputs.articleDescriptionViewModel)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var conversationSummaryView: OWConversationSummaryView = {
        return OWConversationSummaryView(viewModel: self.viewModel.outputs.conversationSummaryViewModel)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
            .enforceSemanticAttribute()
            .backgroundColor(UIColor.clear)
            .separatorStyle(.none)

        tableView.isScrollEnabled = false
        tableView.allowsSelection = false

        // Register cells
        for option in OWConversationCellOption.allCases {
            tableView.register(cellClass: option.cellClass)
        }

        return tableView
    }()

    fileprivate lazy var conversationDataSource: OWRxTableViewSectionedAnimatedDataSource<ConversationDataSourceModel> = {
        let dataSource = OWRxTableViewSectionedAnimatedDataSource<ConversationDataSourceModel>(configureCell: { [weak self] _, tableView, indexPath, item -> UITableViewCell in
            guard let self = self else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCellAndReigsterIfNeeded(cellClass: item.cellClass, for: indexPath)
            cell.configure(with: item.viewModel)

            return cell
        })

        let animationConfiguration = OWAnimationConfiguration(insertAnimation: .top, reloadAnimation: .none, deleteAnimation: .fade)
        dataSource.animationConfiguration = animationConfiguration
        return dataSource
    }()

    fileprivate let viewModel: OWConversationViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWConversationViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        viewModel.inputs.viewInitialized.onNext()
        setupUI()
        setupObservers()
    }
}

fileprivate extension OWConversationView {
    func setupUI() {
        self.useAsThemeStyleInjector()

        let shouldShowTiTleHeader = viewModel.outputs.shouldShowTiTleHeader
        if shouldShowTiTleHeader {
            self.addSubview(conversationTitleHeaderView)
            conversationTitleHeaderView.OWSnp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(Metrics.conversationTitleHeaderHeight)
            }
        }

        self.addSubview(articleDescriptionView)
        articleDescriptionView.OWSnp.makeConstraints { make in
            if shouldShowTiTleHeader {
                make.top.equalTo(conversationTitleHeaderView.OWSnp.bottom)
            } else {
                make.top.equalToSuperview()
            }
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.articleDescriptionHeight)
        }

        self.addSubview(conversationSummaryView)
        conversationSummaryView.OWSnp.makeConstraints { make in
            make.top.equalTo(articleDescriptionView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.conversationSummaryHeight)
        }

        // After building the other views, position the table view in the appropriate place
        self.addSubview(tableView)
        tableView.OWSnp.makeConstraints { make in
            make.top.equalTo(conversationSummaryView.OWSnp.bottom)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }

    func setupObservers() {
        viewModel.outputs.conversationDataSourceSections
            .bind(to: tableView.rx.items(dataSource: conversationDataSource))
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.updateCellSizeAtIndex
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.tableView.reloadItemsAtIndexPaths([IndexPath(row: index, section: 0)], animationStyle: .none)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.initialDataLoaded
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] initialDataLoaded in
            guard initialDataLoaded, let self = self else { return }
                UIView.performWithoutAnimation {
                    self.tableView.reloadData()
                }

                self.tableView.isScrollEnabled = true
        })
        .disposed(by: disposeBag)
    }
}
