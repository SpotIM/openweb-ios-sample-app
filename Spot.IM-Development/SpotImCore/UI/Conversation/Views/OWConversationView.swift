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
        
    }
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
            .enforceSemanticAttribute()
            .backgroundColor(.spBackground0)
            .separatorStyle(.none)
        
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
        setupViews()
        setupObservers()
    }
}

fileprivate extension OWConversationView {
    func setupViews() {
        self.useAsThemeStyleInjector()
        
        // After building the other views, position the table view in the appropriate place
        self.addSubview(tableView)
        tableView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // TODO: Remove the ugly green when actually starting to work on the UI, this is only for integration purposes at the moment
        self.backgroundColor = .green
        tableView.backgroundColor = .green
    }
    
    func setupObservers() {
        viewModel.outputs.conversationDataSourceSections
            .bind(to: tableView.rx.items(dataSource: conversationDataSource))
            .disposed(by: disposeBag)
    }
}
