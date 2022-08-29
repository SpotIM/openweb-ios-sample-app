//
//  OWPreConversationView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 29/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWPreConversationView: UIView {
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
    
    fileprivate lazy var preConversationDataSource: OWRxTableViewSectionedAnimatedDataSource<PreConversationDataSourceModel> = {
        let dataSource = OWRxTableViewSectionedAnimatedDataSource<PreConversationDataSourceModel>(configureCell: { [weak self] _, tableView, indexPath, item -> UITableViewCell in
            guard let self = self else { return UITableViewCell() }
            
            let cell = tableView.dequeueReusableCellAndReigsterIfNeeded(cellClass: item.cellClass, for: indexPath)
            cell.configure(with: item.viewModel)
            
            return cell
        })
        
        let animationConfiguration = OWAnimationConfiguration(insertAnimation: .top, reloadAnimation: .none, deleteAnimation: .fade)
        dataSource.animationConfiguration = animationConfiguration
        return dataSource
    }()
    
    fileprivate let viewModel: OWPreConversationViewViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(viewModel: OWPreConversationViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
    }
}

fileprivate extension OWPreConversationView {
    func setupViews() {
        // After building the other views, position the table view in the appropriate place
        self.addSubview(tableView)
        tableView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupObservers() {
        viewModel.outputs.preConversationDataSourceSections
            .bind(to: tableView.rx.items(dataSource: preConversationDataSource))
            .disposed(by: disposeBag)
    }
}
