//
//  IndexPath+SPExtensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 21/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

extension IndexPath {

    static func indexPaths(forSection section: Int, from lowerBound: Int, pathesCount: Int) -> [IndexPath] {
        guard pathesCount > 0 else { return [IndexPath]() }

        let range = (lowerBound ... lowerBound + pathesCount - 1)
        return range.map { IndexPath(row: $0, section: section) }
    }
}
