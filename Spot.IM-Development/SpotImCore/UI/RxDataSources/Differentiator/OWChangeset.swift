//
//  OWChangeset.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

struct OWChangeset<Section: OWSectionModelType> {
    typealias Item = Section.Item

    let reloadData: Bool

    let originalSections: [Section]
    let finalSections: [Section]

    let insertedSections: [Int]
    let deletedSections: [Int]
    let movedSections: [(from: Int, to: Int)]
    let updatedSections: [Int]

    let insertedItems: [OWItemPath]
    let deletedItems: [OWItemPath]
    let movedItems: [(from: OWItemPath, to: OWItemPath)]
    let updatedItems: [OWItemPath]

    init(reloadData: Bool = false,
         originalSections: [Section] = [],
         finalSections: [Section] = [],
         insertedSections: [Int] = [],
         deletedSections: [Int] = [],
         movedSections: [(from: Int, to: Int)] = [],
         updatedSections: [Int] = [],
         insertedItems: [OWItemPath] = [],
         deletedItems: [OWItemPath] = [],
         movedItems: [(from: OWItemPath, to: OWItemPath)] = [],
         updatedItems: [OWItemPath] = []) {
        self.reloadData = reloadData

        self.originalSections = originalSections
        self.finalSections = finalSections

        self.insertedSections = insertedSections
        self.deletedSections = deletedSections
        self.movedSections = movedSections
        self.updatedSections = updatedSections

        self.insertedItems = insertedItems
        self.deletedItems = deletedItems
        self.movedItems = movedItems
        self.updatedItems = updatedItems
    }

    static func initialValue(_ sections: [Section]) -> OWChangeset<Section> {
        return OWChangeset<Section>(
            reloadData: true,
            finalSections: sections,
            insertedSections: Array(0 ..< sections.count) as [Int]
        )
    }
}

extension OWItemPath: CustomDebugStringConvertible {
    var debugDescription : String {
        return "(\(sectionIndex), \(itemIndex))"
    }
}

extension OWChangeset: CustomDebugStringConvertible {
    var debugDescription : String {
        let serializedSections = "[\n" + finalSections.map { "\($0)" }.joined(separator: ",\n") + "\n]\n"
        return " >> Final sections"
        + "   \n\(serializedSections)"
        + (!insertedSections.isEmpty || !deletedSections.isEmpty || !movedSections.isEmpty || !updatedSections.isEmpty ? "\nSections:" : "")
        + (!insertedSections.isEmpty ? "\ninsertedSections:\n\t\(insertedSections)" : "")
        + (!deletedSections.isEmpty ?  "\ndeletedSections:\n\t\(deletedSections)" : "")
        + (!movedSections.isEmpty ? "\nmovedSections:\n\t\(movedSections)" : "")
        + (!updatedSections.isEmpty ? "\nupdatesSections:\n\t\(updatedSections)" : "")
            + (!insertedItems.isEmpty || !deletedItems.isEmpty || !movedItems.isEmpty || !updatedItems.isEmpty ? "\nItems:" : "")
        + (!insertedItems.isEmpty ? "\ninsertedItems:\n\t\(insertedItems)" : "")
        + (!deletedItems.isEmpty ? "\ndeletedItems:\n\t\(deletedItems)" : "")
        + (!movedItems.isEmpty ? "\nmovedItems:\n\t\(movedItems)" : "")
        + (!updatedItems.isEmpty ? "\nupdatedItems:\n\t\(updatedItems)" : "")
    }
}
