//
//  OWRxCollectionViewSectionedReloadDataSource.swift
//  SpotImCore
//
//  Created by Alon Haiut on 10/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWRxCollectionViewSectionedReloadDataSource<Section: OWSectionModelType>: OWCollectionViewSectionedDataSource<Section>, RxCollectionViewDataSourceType {
    
    typealias Element = [Section]

    func collectionView(_ collectionView: UICollectionView, observedEvent: Event<Element>) {
        Binder(self) { [weak collectionView] dataSource, element in
            guard let collectionView = collectionView else { return }
            
            #if DEBUG
                dataSource._dataSourceBound = true
            #endif
            dataSource.setSections(element)
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
        }.on(observedEvent)
    }
}
