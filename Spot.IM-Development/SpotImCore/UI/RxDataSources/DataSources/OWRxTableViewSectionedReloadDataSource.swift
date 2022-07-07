//
//  OWRxTableViewSectionedReloadDataSource.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class OWRxTableViewSectionedReloadDataSource<Section: OWSectionModelType>: OWTableViewSectionedDataSource<Section>, RxTableViewDataSourceType {
    typealias Element = [Section]

    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        Binder(self) { dataSource, element in
            #if DEBUG
                dataSource._dataSourceBound = true
            #endif
            dataSource.setSections(element)
            tableView.reloadData()
        }.on(observedEvent)
    }
}
