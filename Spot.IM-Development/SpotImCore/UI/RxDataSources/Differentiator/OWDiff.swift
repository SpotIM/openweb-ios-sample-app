//
//  OWDiff.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

fileprivate extension OWAnimatableSectionModelType {
    init(safeOriginal: Self, safeItems: [Item]) throws {
        self.init(original: safeOriginal, items: safeItems)

        if self.items != safeItems || self.identity != safeOriginal.identity {
            throw OWDiff.Error.invalidInitializerImplementation(section: self, expectedItems: safeItems, expectedIdentifier: safeOriginal.identity)
        }
    }
}

enum OWDiff {

    enum Error: Swift.Error, CustomDebugStringConvertible {

        case duplicateItem(item: Any)
        case duplicateSection(section: Any)
        case invalidInitializerImplementation(section: Any, expectedItems: Any, expectedIdentifier: Any)

        var debugDescription: String {
            switch self {
            case let .duplicateItem(item):
                return "Duplicate item \(item)"
            case let .duplicateSection(section):
                return "Duplicate section \(section)"
            case let .invalidInitializerImplementation(section, expectedItems, expectedIdentifier):
                return "Wrong initializer implementation for: \(section)\n" +
                    "Expected it should return items: \(expectedItems)\n" +
                "Expected it should have id: \(expectedIdentifier)"
            }
        }
    }

    private enum OWEditEvent: CustomDebugStringConvertible {
        case inserted               // can't be found in old sections
        case insertedAutomatically  // Item inside section being inserted
        case deleted                // Was in old, not in new, in it's place is something "not new" :(, otherwise it's Updated
        case deletedAutomatically   // Item inside section that is being deleted
        case moved                  // same item, but was on different index, and needs explicit move
        case movedAutomatically     // don't need to specify any changes for those rows
        case untouched

        var debugDescription: String {
            switch self {
            case .inserted:
                return "Inserted"
            case .insertedAutomatically:
                return "InsertedAutomatically"
            case .deleted:
                return "Deleted"
            case .deletedAutomatically:
                return "DeletedAutomatically"
            case .moved:
                return "Moved"
            case .movedAutomatically:
                return "MovedAutomatically"
            case .untouched:
                return "Untouched"
            }
        }
    }

    private struct OWSectionAssociatedData: CustomDebugStringConvertible {
        var event: OWEditEvent
        var indexAfterDelete: Int?
        var moveIndex: Int?
        var itemCount: Int

        var debugDescription: String {
            return "\(event), \(String(describing: indexAfterDelete))"
        }

        static var initial: OWSectionAssociatedData {
            return OWSectionAssociatedData(event: .untouched, indexAfterDelete: nil, moveIndex: nil, itemCount: 0)
        }
    }

    private struct OWItemAssociatedData: CustomDebugStringConvertible {
        var event: OWEditEvent
        var indexAfterDelete: Int?
        var moveIndex: OWItemPath?

        var debugDescription: String {
            return "\(event) \(String(describing: indexAfterDelete))"
        }

        static var initial: OWItemAssociatedData {
            return OWItemAssociatedData(event: .untouched, indexAfterDelete: nil, moveIndex: nil)
        }
    }

    private static func indexSections<Section: OWAnimatableSectionModelType>(_ sections: [Section]) throws -> [Section.Identity: Int] {
        var indexedSections: [Section.Identity: Int] = [:]
        for (i, section) in sections.enumerated() {
            guard indexedSections[section.identity] == nil else {
                #if DEBUG
                    if indexedSections[section.identity] != nil {
                        print("Section \(section) has already been indexed at \(indexedSections[section.identity]!)")
                    }
                #endif
                throw Error.duplicateSection(section: section)
            }
            indexedSections[section.identity] = i
        }

        return indexedSections
    }

    // ================================================================================
    //  Optimizations because Swift dictionaries are extremely slow (ARC, bridging ...)
    // ================================================================================
    // swift dictionary optimizations {

    private struct OWOptimizedIdentity<Identity: Hashable>: Hashable {

        let identity: UnsafePointer<Identity>
        private let cachedHashValue: Int

        init(_ identity: UnsafePointer<Identity>) {
            self.identity = identity
            self.cachedHashValue = identity.pointee.hashValue
        }

        func hash(into hasher: inout Hasher) {
          hasher.combine(self.cachedHashValue)
        }

        static func == (lhs: OWOptimizedIdentity<Identity>, rhs: OWOptimizedIdentity<Identity>) -> Bool {
            if lhs.hashValue != rhs.hashValue {
                return false
            }

            if lhs.identity.distance(to: rhs.identity) == 0 {
                return true
            }

            return lhs.identity.pointee == rhs.identity.pointee
        }

    }

    private static func calculateAssociatedData<Item: OWIdentifiableType>(
        initialItemCache: ContiguousArray<ContiguousArray<Item>>,
        finalItemCache: ContiguousArray<ContiguousArray<Item>>
    ) throws
        -> (ContiguousArray<ContiguousArray<OWItemAssociatedData>>, ContiguousArray<ContiguousArray<OWItemAssociatedData>>) {
            typealias OWIdentity = Item.Identity
            let totalInitialItems = initialItemCache.map { $0.count }.reduce(0, +)

            var initialIdentities: ContiguousArray<OWIdentity> = ContiguousArray()
            var initialItemPaths: ContiguousArray<OWItemPath> = ContiguousArray()

            initialIdentities.reserveCapacity(totalInitialItems)
            initialItemPaths.reserveCapacity(totalInitialItems)

            for (i, items) in initialItemCache.enumerated() {
                for j in 0 ..< items.count {
                    let item = items[j]
                    initialIdentities.append(item.identity)
                    initialItemPaths.append(OWItemPath(sectionIndex: i, itemIndex: j))
                }
            }

            var initialItemData = ContiguousArray(initialItemCache.map { items in
                return ContiguousArray<OWItemAssociatedData>(repeating: OWItemAssociatedData.initial, count: items.count)
            })

            var finalItemData = ContiguousArray(finalItemCache.map { items in
                return ContiguousArray<OWItemAssociatedData>(repeating: OWItemAssociatedData.initial, count: items.count)
            })

            try initialIdentities.withUnsafeBufferPointer { (identitiesBuffer: UnsafeBufferPointer<OWIdentity>) -> Void in
                var dictionary: [OWOptimizedIdentity<OWIdentity>: Int] = Dictionary(minimumCapacity: totalInitialItems * 2)

                for i in 0 ..< initialIdentities.count {
                    let identityPointer = identitiesBuffer.baseAddress!.advanced(by: i)

                    let key = OWOptimizedIdentity(identityPointer)

                    if let existingValueItemPathIndex = dictionary[key] {
                        let itemPath = initialItemPaths[existingValueItemPathIndex]
                        let item = initialItemCache[itemPath.sectionIndex][itemPath.itemIndex]
                        #if DEBUG
                            print("Item \(item) has already been indexed at \(itemPath)" )
                        #endif
                        throw Error.duplicateItem(item: item)
                    }

                    dictionary[key] = i
                }

                for (i, items) in finalItemCache.enumerated() {
                    for j in 0 ..< items.count {
                        let item = items[j]
                        var identity = item.identity
                        let key = OWOptimizedIdentity(&identity)
                        guard let initialItemPathIndex = dictionary[key] else {
                            continue
                        }
                        let itemPath = initialItemPaths[initialItemPathIndex]
                        if initialItemData[itemPath.sectionIndex][itemPath.itemIndex].moveIndex != nil {
                            throw Error.duplicateItem(item: item)
                        }

                        initialItemData[itemPath.sectionIndex][itemPath.itemIndex].moveIndex = OWItemPath(sectionIndex: i, itemIndex: j)
                        finalItemData[i][j].moveIndex = itemPath
                    }
                }

                return ()
            }

            return (initialItemData, finalItemData)
    }

    // Generates differential changes suitable for sectioned view consumption.
    // It will not only detect changes between two states, but it will also try to compress those changes into
    // almost minimal set of changes.
    //
    // I know, I know, it's ugly :( Totally agree, but this is the only general way I could find that works 100%, and
    // avoids UITableView quirks.
    //
    // Please take into consideration that I was also convinced about 20 times that I've found a simple general
    // solution, but then UITableView falls apart under stress testing :(
    //
    // Sincerely, if somebody else would present me this 250 lines of code, I would call him a mad man. I would think
    // that there has to be a simpler solution. Well, after 3 days, I'm not convinced any more :)
    //
    // Maybe it can be made somewhat simpler, but don't think it can be made much simpler.
    //
    // The algorithm could take anywhere from 1 to 3 table view transactions to finish the updates.
    //
    //  * stage 1 - remove deleted sections and items
    //  * stage 2 - move sections into place
    //  * stage 3 - fix moved and new items
    //
    // There maybe exists a better division, but time will tell.
    //
    static func differencesForSectionedView<Section: OWAnimatableSectionModelType>(
        initialSections: [Section],
        finalSections: [Section])
        throws -> [OWChangeset<Section>] {
            var result: [OWChangeset<Section>] = []

            var sectionCommands = try OWCommandGenerator<Section>.generatorForInitialSections(initialSections, finalSections: finalSections)

            result.append(contentsOf: try sectionCommands.generateDeleteSectionsDeletedItemsAndUpdatedItems())
            result.append(contentsOf: try sectionCommands.generateInsertAndMoveSections())
            result.append(contentsOf: try sectionCommands.generateInsertAndMovedItems())

            return result
    }

    private struct OWCommandGenerator<Section: OWAnimatableSectionModelType> {
        typealias Item = Section.Item

        let initialSections: [Section]
        let finalSections: [Section]

        let initialSectionData: ContiguousArray<OWSectionAssociatedData>
        let finalSectionData: ContiguousArray<OWSectionAssociatedData>

        let initialItemData: ContiguousArray<ContiguousArray<OWItemAssociatedData>>
        let finalItemData: ContiguousArray<ContiguousArray<OWItemAssociatedData>>

        let initialItemCache: ContiguousArray<ContiguousArray<Item>>
        let finalItemCache: ContiguousArray<ContiguousArray<Item>>

        static func generatorForInitialSections(
            _ initialSections: [Section],
            finalSections: [Section]
            ) throws -> OWCommandGenerator<Section> {

            let (initialSectionData, finalSectionData) = try calculateSectionMovements(initialSections: initialSections, finalSections: finalSections)

            let initialItemCache = ContiguousArray(initialSections.map {
                ContiguousArray($0.items)
            })

            let finalItemCache = ContiguousArray(finalSections.map {
                ContiguousArray($0.items)
            })

            let (initialItemData, finalItemData) = try calculateItemMovements(
                initialItemCache: initialItemCache,
                finalItemCache: finalItemCache,
                initialSectionData: initialSectionData,
                finalSectionData: finalSectionData
            )

            return OWCommandGenerator<Section>(
                initialSections: initialSections,
                finalSections: finalSections,

                initialSectionData: initialSectionData,
                finalSectionData: finalSectionData,

                initialItemData: initialItemData,
                finalItemData: finalItemData,

                initialItemCache: initialItemCache,
                finalItemCache: finalItemCache
            )
        }

        static func calculateItemMovements(
            initialItemCache: ContiguousArray<ContiguousArray<Item>>,
            finalItemCache: ContiguousArray<ContiguousArray<Item>>,
            initialSectionData: ContiguousArray<OWSectionAssociatedData>,
            finalSectionData: ContiguousArray<OWSectionAssociatedData>) throws
            -> (ContiguousArray<ContiguousArray<OWItemAssociatedData>>, ContiguousArray<ContiguousArray<OWItemAssociatedData>>) {

                var (initialItemData, finalItemData) = try OWDiff.calculateAssociatedData(
                    initialItemCache: initialItemCache,
                    finalItemCache: finalItemCache
                )

                let findNextUntouchedOldIndex = { (initialSectionIndex: Int, initialSearchIndex: Int?) -> Int? in
                    guard var i2 = initialSearchIndex else {
                        return nil
                    }

                    while i2 < initialSectionData[initialSectionIndex].itemCount {
                        if initialItemData[initialSectionIndex][i2].event == .untouched {
                            return i2
                        }

                        i2 += 1
                    }

                    return nil
                }

                // first mark deleted items
                for i in 0 ..< initialItemCache.count {
                    guard initialSectionData[i].moveIndex != nil else {
                        continue
                    }

                    var indexAfterDelete = 0
                    for j in 0 ..< initialItemCache[i].count {

                        guard let finalIndexPath = initialItemData[i][j].moveIndex else {
                            initialItemData[i][j].event = .deleted
                            continue
                        }

                        // from this point below, section has to be move type because it's initial and not deleted

                        // because there is no move to inserted section
                        if finalSectionData[finalIndexPath.sectionIndex].event == .inserted {
                            initialItemData[i][j].event = .deleted
                            continue
                        }

                        initialItemData[i][j].indexAfterDelete = indexAfterDelete
                        indexAfterDelete += 1
                    }
                }

                // mark moved or moved automatically
                for i in 0 ..< finalItemCache.count {
                    guard let originalSectionIndex = finalSectionData[i].moveIndex else {
                        continue
                    }

                    var untouchedIndex: Int? = 0
                    for j in 0 ..< finalItemCache[i].count {
                        untouchedIndex = findNextUntouchedOldIndex(originalSectionIndex, untouchedIndex)

                        guard let originalIndex = finalItemData[i][j].moveIndex else {
                            finalItemData[i][j].event = .inserted
                            continue
                        }

                        // In case trying to move from deleted section, abort, otherwise it will crash table view
                        if initialSectionData[originalIndex.sectionIndex].event == .deleted {
                            finalItemData[i][j].event = .inserted
                            continue
                        }
                            // original section can't be inserted
                        else if initialSectionData[originalIndex.sectionIndex].event == .inserted {
                            try differentiatorPrecondition(false, "New section in initial sections, that is wrong")
                        }

                        let initialSectionEvent = initialSectionData[originalIndex.sectionIndex].event
                        try differentiatorPrecondition(initialSectionEvent == .moved || initialSectionEvent == .movedAutomatically, "Section not moved")

                        let eventType = originalIndex == OWItemPath(sectionIndex: originalSectionIndex, itemIndex: untouchedIndex ?? -1)
                            ? OWEditEvent.movedAutomatically : OWEditEvent.moved

                        initialItemData[originalIndex.sectionIndex][originalIndex.itemIndex].event = eventType
                        finalItemData[i][j].event = eventType
                    }
                }

                return (initialItemData, finalItemData)
        }

        static func calculateSectionMovements(initialSections: [Section], finalSections: [Section]) throws
            -> (ContiguousArray<OWSectionAssociatedData>, ContiguousArray<OWSectionAssociatedData>) {

                let initialSectionIndexes = try OWDiff.indexSections(initialSections)

                var initialSectionData = ContiguousArray<OWSectionAssociatedData>(repeating: OWSectionAssociatedData.initial, count: initialSections.count)
                var finalSectionData = ContiguousArray<OWSectionAssociatedData>(repeating: OWSectionAssociatedData.initial, count: finalSections.count)

                for (i, section) in finalSections.enumerated() {
                    finalSectionData[i].itemCount = finalSections[i].items.count
                    guard let initialSectionIndex = initialSectionIndexes[section.identity] else {
                        continue
                    }

                    if initialSectionData[initialSectionIndex].moveIndex != nil {
                        throw Error.duplicateSection(section: section)
                    }

                    initialSectionData[initialSectionIndex].moveIndex = i
                    finalSectionData[i].moveIndex = initialSectionIndex
                }

                var sectionIndexAfterDelete = 0

                // deleted sections
                for i in 0 ..< initialSectionData.count {
                    initialSectionData[i].itemCount = initialSections[i].items.count
                    if initialSectionData[i].moveIndex == nil {
                        initialSectionData[i].event = .deleted
                        continue
                    }

                    initialSectionData[i].indexAfterDelete = sectionIndexAfterDelete
                    sectionIndexAfterDelete += 1
                }

                // moved sections

                var untouchedOldIndex: Int? = 0
                let findNextUntouchedOldIndex = { (initialSearchIndex: Int?) -> Int? in
                    guard var i = initialSearchIndex else {
                        return nil
                    }

                    while i < initialSections.count {
                        if initialSectionData[i].event == .untouched {
                            return i
                        }

                        i += 1
                    }

                    return nil
                }

                // inserted and moved sections {
                // this should fix all sections and move them into correct places
                // 2nd stage
                for i in 0 ..< finalSections.count {
                    untouchedOldIndex = findNextUntouchedOldIndex(untouchedOldIndex)

                    // oh, it did exist
                    if let oldSectionIndex = finalSectionData[i].moveIndex {
                        let moveType = oldSectionIndex != untouchedOldIndex ? OWEditEvent.moved : OWEditEvent.movedAutomatically

                        finalSectionData[i].event = moveType
                        initialSectionData[oldSectionIndex].event = moveType
                    } else {
                        finalSectionData[i].event = .inserted
                    }
                }

                // inserted sections
                for (i, section) in finalSectionData.enumerated() where  section.moveIndex == nil {
                    _ = finalSectionData[i].event == .inserted
                }

                return (initialSectionData, finalSectionData)
        }

        mutating func generateDeleteSectionsDeletedItemsAndUpdatedItems() throws -> [OWChangeset<Section>] {
            var deletedSections = [Int]()

            var deletedItems = [OWItemPath]()
            var updatedItems = [OWItemPath]()

            var afterDeleteState = [Section]()

            // mark deleted items {
            // 1rst stage again (I know, I know ...)
            for (i, initialItems) in initialItemCache.enumerated() {
                let event = initialSectionData[i].event

                // Deleted section will take care of deleting child items.
                // In case of moving an item from deleted section, tableview will
                // crash anyway, so this is not limiting anything.
                if event == .deleted {
                    deletedSections.append(i)
                    continue
                }

                var afterDeleteItems: [Section.Item] = []
                for j in 0 ..< initialItems.count {
                    let event = initialItemData[i][j].event
                    switch event {
                    case .deleted:
                        deletedItems.append(OWItemPath(sectionIndex: i, itemIndex: j))
                    case .moved, .movedAutomatically:
                        let finalItemIndex = try initialItemData[i][j].moveIndex.unwrap()
                        let finalItem = finalItemCache[finalItemIndex.sectionIndex][finalItemIndex.itemIndex]
                        if finalItem != initialSections[i].items[j] {
                            updatedItems.append(OWItemPath(sectionIndex: i, itemIndex: j))
                            afterDeleteItems.append(finalItem)
                        } else {
                            afterDeleteItems.append(initialSections[i].items[j])
                        }
                    default:
                        try differentiatorPrecondition(false, "Unhandled case")
                    }
                }

                afterDeleteState.append(try Section(safeOriginal: initialSections[i], safeItems: afterDeleteItems))
            }

            if deletedItems.isEmpty && deletedSections.isEmpty && updatedItems.isEmpty {
                return []
            }

            return [OWChangeset(
                finalSections: afterDeleteState,
                deletedSections: deletedSections,
                deletedItems: deletedItems,
                updatedItems: updatedItems
                )]
        }

        func generateInsertAndMoveSections() throws -> [OWChangeset<Section>] {

            var movedSections = [(from: Int, to: Int)]()
            var insertedSections = [Int]()

            for i in 0 ..< initialSections.count {
                switch initialSectionData[i].event {
                case .deleted:
                    break
                case .moved:
                    movedSections.append((from: try initialSectionData[i].indexAfterDelete.unwrap(), to: try initialSectionData[i].moveIndex.unwrap()))
                case .movedAutomatically:
                    break
                default:
                    try differentiatorPrecondition(false, "Unhandled case in initial sections")
                }
            }

            for i in 0 ..< finalSections.count {
                switch finalSectionData[i].event {
                case .inserted:
                    insertedSections.append(i)
                default:
                    break
                }
            }

            if insertedSections.isEmpty && movedSections.isEmpty {
                return []
            }

            // sections should be in place, but items should be original without deleted ones
            let sectionsAfterChange: [Section] = try self.finalSections.enumerated().map { i, s -> Section in
                let event = self.finalSectionData[i].event

                if event == .inserted {
                    // it's already set up
                    return s
                } else if event == .moved || event == .movedAutomatically {
                    let originalSectionIndex = try finalSectionData[i].moveIndex.unwrap()
                    let originalSection = initialSections[originalSectionIndex]

                    var items: [Section.Item] = []
                    items.reserveCapacity(originalSection.items.count)
                    let itemAssociatedData = self.initialItemData[originalSectionIndex]
                    for j in 0 ..< originalSection.items.count {
                        let initialData = itemAssociatedData[j]

                        guard initialData.event != .deleted else {
                            continue
                        }

                        guard let finalIndex = initialData.moveIndex else {
                            try differentiatorPrecondition(false, "Item was moved, but no final location.")
                            continue
                        }

                        items.append(finalItemCache[finalIndex.sectionIndex][finalIndex.itemIndex])
                    }

                    let modifiedSection = try Section(safeOriginal: s, safeItems: items)

                    return modifiedSection
                } else {
                    try differentiatorPrecondition(false, "This is weird, this shouldn't happen")
                    return s
                }
            }

            return [OWChangeset(
                finalSections: sectionsAfterChange,
                insertedSections: insertedSections,
                movedSections: movedSections
                )]
        }

        mutating func generateInsertAndMovedItems() throws -> [OWChangeset<Section>] {
            var insertedItems = [OWItemPath]()
            var movedItems = [(from: OWItemPath, to: OWItemPath)]()

            // mark new and moved items {
            // 3rd stage
            for i in 0 ..< finalSections.count {
                let finalSection = finalSections[i]

                let sectionEvent = finalSectionData[i].event
                // new and deleted sections cause reload automatically
                if sectionEvent != .moved && sectionEvent != .movedAutomatically {
                    continue
                }

                for j in 0 ..< finalSection.items.count {
                    let currentItemEvent = finalItemData[i][j].event

                    try differentiatorPrecondition(currentItemEvent != .untouched, "Current event is not untouched")

                    let event = finalItemData[i][j].event

                    switch event {
                    case .inserted:
                        insertedItems.append(OWItemPath(sectionIndex: i, itemIndex: j))
                    case .moved:
                        let originalIndex = try finalItemData[i][j].moveIndex.unwrap()
                        let finalSectionIndex = try initialSectionData[originalIndex.sectionIndex].moveIndex.unwrap()
                        let moveFromItemWithIndex = try initialItemData[originalIndex.sectionIndex][originalIndex.itemIndex].indexAfterDelete.unwrap()

                        let moveCommand = (
                            from: OWItemPath(sectionIndex: finalSectionIndex, itemIndex: moveFromItemWithIndex),
                            to: OWItemPath(sectionIndex: i, itemIndex: j)
                        )
                        movedItems.append(moveCommand)
                    default:
                        break
                    }
                }
            }

            if insertedItems.isEmpty && movedItems.isEmpty {
                return []
            }
            return [OWChangeset(
                finalSections: finalSections,
                insertedItems: insertedItems,
                movedItems: movedItems
                )]
        }
    }
}
