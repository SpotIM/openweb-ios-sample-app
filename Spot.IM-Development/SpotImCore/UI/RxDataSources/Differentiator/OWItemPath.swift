//
//  OWItemPath.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

struct OWItemPath {
    let sectionIndex: Int
    let itemIndex: Int

    init(sectionIndex: Int, itemIndex: Int) {
        self.sectionIndex = sectionIndex
        self.itemIndex = itemIndex
    }
}

extension OWItemPath : Equatable {}

func == (lhs: OWItemPath, rhs: OWItemPath) -> Bool {
    return lhs.sectionIndex == rhs.sectionIndex && lhs.itemIndex == rhs.itemIndex
}

extension OWItemPath: Hashable {
    func hash(into hasher: inout Hasher) {
      hasher.combine(sectionIndex.byteSwapped.hashValue)
      hasher.combine(itemIndex.hashValue)
    }
}
