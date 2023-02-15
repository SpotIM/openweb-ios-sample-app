//
//  OWCollectionViewSectionedDataSource.swift
//  SpotImCore
//
//  Created by Alon Haiut on 10/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa

class OWCollectionViewSectionedDataSource<Section: OWSectionModelType>: NSObject, UICollectionViewDataSource, SectionedViewDataSourceType {
    typealias Item = Section.Item
    typealias Section = Section
    typealias ConfigureCell = (OWCollectionViewSectionedDataSource<Section>, UICollectionView, IndexPath, Item) -> UICollectionViewCell
    typealias ConfigureSupplementaryView = (OWCollectionViewSectionedDataSource<Section>, UICollectionView, String, IndexPath) -> UICollectionReusableView
    typealias MoveItem = (OWCollectionViewSectionedDataSource<Section>, _ sourceIndexPath: IndexPath, _ destinationIndexPath: IndexPath) -> Void
    typealias CanMoveItemAtIndexPath = (OWCollectionViewSectionedDataSource<Section>, IndexPath) -> Bool

    init(
        configureCell: @escaping ConfigureCell,
        configureSupplementaryView: ConfigureSupplementaryView? = nil,
        moveItem: @escaping MoveItem = { _, _, _ in () },
        canMoveItemAtIndexPath: @escaping CanMoveItemAtIndexPath = { _, _ in false }
    ) {
        self.configureCell = configureCell
        self.configureSupplementaryView = configureSupplementaryView
        self.moveItem = moveItem
        self.canMoveItemAtIndexPath = canMoveItemAtIndexPath
    }

    #if DEBUG
    // If data source has already been bound, then mutating it
    // afterwards isn't something desired.
    // This simulates immutability after binding
    var _dataSourceBound: Bool = false

    private func ensureNotMutatedAfterBinding() {
        assert(!_dataSourceBound, "Data source is already bound. Please write this line before binding call (`bindTo`, `drive`). Data source must first be completely configured, and then bound after that, otherwise there could be runtime bugs, glitches, or partial malfunctions.")
    }

    #endif

    // This structure exists because model can be mutable
    // In that case current state value should be preserved.
    // The state that needs to be preserved is ordering of items in section
    // and their relationship with section.
    // If particular item is mutable, that is irrelevant for this logic to function
    // properly.
    typealias SectionModelSnapshot = OWSectionModel<Section, Item>

    private var _sectionModels: [SectionModelSnapshot] = []

    var sectionModels: [Section] {
        return _sectionModels.map { Section(original: $0.model, items: $0.items) }
    }

    subscript(section: Int) -> Section {
        let sectionModel = self._sectionModels[section]
        return Section(original: sectionModel.model, items: sectionModel.items)
    }

    subscript(indexPath: IndexPath) -> Item {
        get {
            return self._sectionModels[indexPath.section].items[indexPath.item]
        }
        set(item) {
            var section = self._sectionModels[indexPath.section]
            section.items[indexPath.item] = item
            self._sectionModels[indexPath.section] = section
        }
    }

    func model(at indexPath: IndexPath) throws -> Any {
        guard indexPath.section < self._sectionModels.count,
              indexPath.item < self._sectionModels[indexPath.section].items.count else {
            throw OWRxDataSourceError.outOfBounds(indexPath: indexPath)
        }

        return self[indexPath]
    }

    func setSections(_ sections: [Section]) {
        self._sectionModels = sections.map { SectionModelSnapshot(model: $0, items: $0.items) }
    }

    var configureCell: ConfigureCell {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }

    var configureSupplementaryView: ConfigureSupplementaryView? {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }

    var moveItem: MoveItem {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    var canMoveItemAtIndexPath: ((OWCollectionViewSectionedDataSource<Section>, IndexPath) -> Bool)? {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }

    // UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return _sectionModels.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _sectionModels[section].items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        precondition(indexPath.item < _sectionModels[indexPath.section].items.count)

        return configureCell(self, collectionView, indexPath, self[indexPath])
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return configureSupplementaryView!(self, collectionView, kind, indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard let canMoveItem = canMoveItemAtIndexPath?(self, indexPath) else {
            return false
        }

        return canMoveItem
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self._sectionModels.moveFromSourceIndexPath(sourceIndexPath, destinationIndexPath: destinationIndexPath)
        self.moveItem(self, sourceIndexPath, destinationIndexPath)
    }

    override func responds(to aSelector: Selector!) -> Bool {
        if aSelector == #selector(UICollectionViewDataSource.collectionView(_:viewForSupplementaryElementOfKind:at:)) {
            return configureSupplementaryView != nil
        } else {
            return super.responds(to: aSelector)
        }
    }
}
