//
//  OWAnimatableSectionModelType+ItemPath.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

extension Array where Element: OWAnimatableSectionModelType {
    subscript(index: OWItemPath) -> Element.Item {
        return self[index.sectionIndex].items[index.itemIndex]
    }
}
