//
//  OWSkeletonShimmeringProtocol.swift
//  SpotImCore
//
//  Created by Alon Haiut on 18/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

protocol OWSkeletonShimmeringProtocol {
    func addSkeletonShimmering()
    func removeSkeletonShimmering()
}

extension OWSkeletonShimmeringProtocol where Self: UIView {
    func addSkeletonShimmering() {
        
    }
    
    func removeSkeletonShimmering() {
        guard let skeletonLayer: CALayer = getLayer(forIdentifier: OWAssociatedSkeletonShimmering.skeletonLayerIdentifier),
              let shimmeringLayer: CAGradientLayer = getLayer(forIdentifier: OWAssociatedSkeletonShimmering.shimmeringLayerIdentifier) else {
            let logger = OWSharedServicesProvider.shared.logger()
            logger.log(level: .medium, "Failed retriving skeleton shimmering layers when trying to remove them")
            return
        }
        // Cleanups
        self.mask = nil
        self.clipsToBounds = false
        skeletonLayer.removeFromSuperlayer()
        shimmeringLayer.removeFromSuperlayer()
        removeLayer(forIdentifier: OWAssociatedSkeletonShimmering.skeletonLayerIdentifier)
        removeLayer(forIdentifier: OWAssociatedSkeletonShimmering.shimmeringLayerIdentifier)
    }
    
    fileprivate func createLayer<T: OWInitializable>(forIdentifier identifier: String) -> T? {
        var id = identifier
        let layer = T()
        objc_setAssociatedObject(self, &id,
                                   layer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return layer
    }
    
    fileprivate func getLayer<T>(forIdentifier identifier: String) -> T? {
        var id = identifier
        if let layer = objc_getAssociatedObject(self, &id) as? T {
            return layer
        } else {
            return nil
        }
    }
    
    fileprivate func removeLayer(forIdentifier identifier: String) {
        var id = identifier
        objc_setAssociatedObject(self, &id,
                                   nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
