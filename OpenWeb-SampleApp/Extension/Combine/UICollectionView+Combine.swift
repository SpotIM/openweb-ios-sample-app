//
//  UICollectionView+Combine.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 27/02/2025.
//

import Combine
import CombineDataSources

extension UICollectionView {
    /// A collection view specific `Subscriber` that receives `[Element]` input and updates a single section collection view,
    /// with `reuseIdentifier: cellType.identifierName`.
    /// - Parameter cellType: The required cell type for collection rows.
    /// - Parameter cellConfig: A closure that receives an initialized cell and a collection element
    ///     and configures the cell for displaying in its containing collection view.
    public func itemsSubscriber<CellType, Items>(cellType: CellType.Type, cellConfig: @escaping CollectionViewItemsController<[Items]>.CellConfig<Items.Element, CellType>)
        -> AnySubscriber<Items, Never> where CellType: UICollectionViewCell,
        Items: RandomAccessCollection,
        Items: Equatable {
            return itemsSubscriber(CombineDataSources.CollectionViewItemsController(cellIdentifier: cellType.identifierName, cellType: cellType, cellConfig: cellConfig))
    }
}
