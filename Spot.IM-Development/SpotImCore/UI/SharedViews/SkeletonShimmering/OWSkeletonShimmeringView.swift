//
//  OWSkeletonShimmeringView.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

class OWSkeletonShimmeringView: UIView, OWSkeletonShimmeringProtocol {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateSkeletonShimmeringFrame()
    }
    
    deinit {
        // Stop shimmering effect
        self.removeSkeletonShimmering()
    }
}
