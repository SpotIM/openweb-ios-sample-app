//
//  OWTableViewSectionedDataSource.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa

class OWTableViewSectionedDataSource<Section: OWSectionModelType>: NSObject, UITableViewDataSource, SectionedViewDataSourceType {
    
    typealias Item = Section.Item
    
    typealias OWConfigureCell = (OWTableViewSectionedDataSource<Section>, UITableView, IndexPath, Item) -> UITableViewCell
    typealias OWTitleForHeaderInSection = (OWTableViewSectionedDataSource<Section>, Int) -> String?
    typealias OWTitleForFooterInSection = (OWTableViewSectionedDataSource<Section>, Int) -> String?
    typealias OWCanEditRowAtIndexPath = (OWTableViewSectionedDataSource<Section>, IndexPath) -> Bool
    typealias OWCanMoveRowAtIndexPath = (OWTableViewSectionedDataSource<Section>, IndexPath) -> Bool
    typealias OWSectionIndexTitles = (OWTableViewSectionedDataSource<Section>) -> [String]?
    typealias OWSectionForSectionIndexTitle = (OWTableViewSectionedDataSource<Section>, _ title: String, _ index: Int) -> Int
    
    init(configureCell: @escaping OWConfigureCell,
        titleForHeaderInSection: @escaping  OWTitleForHeaderInSection = { _, _ in nil },
        titleForFooterInSection: @escaping OWTitleForFooterInSection = { _, _ in nil },
        canEditRowAtIndexPath: @escaping OWCanEditRowAtIndexPath = { _, _ in true },
        canMoveRowAtIndexPath: @escaping OWCanMoveRowAtIndexPath = { _, _ in true },
        sectionIndexTitles: @escaping OWSectionIndexTitles = { _ in nil },
        sectionForSectionIndexTitle: @escaping OWSectionForSectionIndexTitle = { _, _, index in index }) {
        self.configureCell = configureCell
        self.titleForHeaderInSection = titleForHeaderInSection
        self.titleForFooterInSection = titleForFooterInSection
        self.canEditRowAtIndexPath = canEditRowAtIndexPath
        self.canMoveRowAtIndexPath = canMoveRowAtIndexPath
        self.sectionIndexTitles = sectionIndexTitles
        self.sectionForSectionIndexTitle = sectionForSectionIndexTitle
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
    typealias OWSectionModelSnapshot = OWSectionModel<Section, Item>
    
    private var _sectionModels: [OWSectionModelSnapshot] = []
    
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
        self._sectionModels = sections.map { OWSectionModelSnapshot(model: $0, items: $0.items) }
    }
    
    var configureCell: OWConfigureCell {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    var titleForHeaderInSection: OWTitleForHeaderInSection {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    var titleForFooterInSection: OWTitleForFooterInSection {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    var canEditRowAtIndexPath: OWCanEditRowAtIndexPath {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    var canMoveRowAtIndexPath: OWCanMoveRowAtIndexPath {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    var sectionIndexTitles: OWSectionIndexTitles {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    var sectionForSectionIndexTitle: OWSectionForSectionIndexTitle {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    
    // UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return _sectionModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard _sectionModels.count > section else { return 0 }
        return _sectionModels[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        precondition(indexPath.item < _sectionModels[indexPath.section].items.count)
        
        return configureCell(self, tableView, indexPath, self[indexPath])
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeaderInSection(self, section)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return titleForFooterInSection(self, section)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return canEditRowAtIndexPath(self, indexPath)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return canMoveRowAtIndexPath(self, indexPath)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self._sectionModels.moveFromSourceIndexPath(sourceIndexPath, destinationIndexPath: destinationIndexPath)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionIndexTitles(self)
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sectionForSectionIndexTitle(self, title, index)
    }
}
