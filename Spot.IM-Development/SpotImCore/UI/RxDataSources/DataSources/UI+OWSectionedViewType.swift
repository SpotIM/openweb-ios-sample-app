//
//  UI+OWSectionedViewType.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

func indexSet(_ values: [Int]) -> IndexSet {
    let indexSet = NSMutableIndexSet()
    for i in values {
        indexSet.add(i)
    }
    return indexSet as IndexSet
}

extension UITableView : OWSectionedViewType {
  
    func insertItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation) {
        self.insertRows(at: paths, with: animationStyle)
    }
    
    func deleteItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation) {
        self.deleteRows(at: paths, with: animationStyle)
    }
    
    func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath) {
        self.moveRow(at: from, to: to)
    }
    
    func reloadItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation) {
        self.reloadRows(at: paths, with: animationStyle)
    }
    
    func insertSections(_ sections: [Int], animationStyle: UITableView.RowAnimation) {
        self.insertSections(indexSet(sections), with: animationStyle)
    }
    
    func deleteSections(_ sections: [Int], animationStyle: UITableView.RowAnimation) {
        self.deleteSections(indexSet(sections), with: animationStyle)
    }
    
    func moveSection(_ from: Int, to: Int) {
        self.moveSection(from, toSection: to)
    }
    
    func reloadSections(_ sections: [Int], animationStyle: UITableView.RowAnimation) {
        self.reloadSections(indexSet(sections), with: animationStyle)
    }
}

extension UICollectionView : OWSectionedViewType {
    func insertItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation) {
        self.insertItems(at: paths)
    }
    
    func deleteItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation) {
        self.deleteItems(at: paths)
    }

    func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath) {
        self.moveItem(at: from, to: to)
    }
    
    func reloadItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation) {
        self.reloadItems(at: paths)
    }
    
    func insertSections(_ sections: [Int], animationStyle: UITableView.RowAnimation) {
        self.insertSections(indexSet(sections))
    }
    
    func deleteSections(_ sections: [Int], animationStyle: UITableView.RowAnimation) {
        self.deleteSections(indexSet(sections))
    }
    
    func moveSection(_ from: Int, to: Int) {
        self.moveSection(from, toSection: to)
    }
    
    func reloadSections(_ sections: [Int], animationStyle: UITableView.RowAnimation) {
        self.reloadSections(indexSet(sections))
    }
}

protocol OWSectionedViewType {
    func insertItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation)
    func deleteItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation)
    func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath)
    func reloadItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation)
    
    func insertSections(_ sections: [Int], animationStyle: UITableView.RowAnimation)
    func deleteSections(_ sections: [Int], animationStyle: UITableView.RowAnimation)
    func moveSection(_ from: Int, to: Int)
    func reloadSections(_ sections: [Int], animationStyle: UITableView.RowAnimation)
}

extension OWSectionedViewType {
    func batchUpdates<OWSection>(_ changes: OWChangeset<OWSection>, animationConfiguration: OWAnimationConfiguration) {
        // swiftlint:disable:next nesting
        typealias OWItem = OWSection.Item
        
        deleteSections(changes.deletedSections, animationStyle: animationConfiguration.deleteAnimation)
        
        insertSections(changes.insertedSections, animationStyle: animationConfiguration.insertAnimation)
        for (from, to) in changes.movedSections {
            moveSection(from, to: to)
        }
        
        deleteItemsAtIndexPaths(
            changes.deletedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
            animationStyle: animationConfiguration.deleteAnimation
        )
        insertItemsAtIndexPaths(
            changes.insertedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
            animationStyle: animationConfiguration.insertAnimation
        )
        reloadItemsAtIndexPaths(
            changes.updatedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
            animationStyle: animationConfiguration.reloadAnimation
        )
        
        for (from, to) in changes.movedItems {
            moveItemAtIndexPath(
                IndexPath(item: from.itemIndex, section: from.sectionIndex),
                to: IndexPath(item: to.itemIndex, section: to.sectionIndex)
            )
        }
    }
}
