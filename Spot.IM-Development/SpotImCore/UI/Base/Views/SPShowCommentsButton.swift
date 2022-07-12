//
//  SPShowCommentsButton.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 22/07/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

public class SPShowCommentsButton: OWBaseButton {
    private var commentsCount: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    internal func setCommentsCount(commentsCount: String?) {
        self.commentsCount = commentsCount
    }
    
    public func getCommentsCount() -> String? {
        return commentsCount
    }
}
