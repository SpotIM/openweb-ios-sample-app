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
    func getSkeletonLayer() -> CALayer?
    func getShimmeringLayer() -> CAGradientLayer?
}

extension OWSkeletonShimmeringProtocol where Self: UIView {
    func addSkeletonShimmering() {
        // Creating layers for skeletone and shimmering
        let skeletonLayer: CALayer = createLayer(forIdentifier: OWAssociatedSkeletonShimmering.skeletonLayerIdentifier, type: CALayer.self)
        let shimmeringLayer: CAGradientLayer = createLayer(forIdentifier: OWAssociatedSkeletonShimmering.shimmeringLayerIdentifier, type: CAGradientLayer.self)
        
        skeletonLayer.anchorPoint = .zero
        skeletonLayer.frame = self.frame
        shimmeringLayer.frame = self.frame
        self.layer.mask = skeletonLayer
        self.layer.addSublayer(skeletonLayer)
        self.layer.addSublayer(shimmeringLayer)
        self.clipsToBounds = true
        
        let skeletonShimmeringService = OWSharedServicesProvider.shared.skeletonShimmeringService()
        skeletonShimmeringService.addSkeleton(to: self)
    }
    
    func removeSkeletonShimmering() {
        guard let skeletonLayer = getSkeletonLayer(),
              let shimmeringLayer = getShimmeringLayer() else {
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
        
        let skeletonShimmeringService = OWSharedServicesProvider.shared.skeletonShimmeringService()
        skeletonShimmeringService.removeSkeleton(from: self)
    }
    
    func getSkeletonLayer() -> CALayer? {
        let skeletonLayer: CALayer? = getLayer(forIdentifier: OWAssociatedSkeletonShimmering.skeletonLayerIdentifier)
        
        return skeletonLayer
    }
        
    func getShimmeringLayer() -> CAGradientLayer? {
        let shimmeringLayer: CAGradientLayer? = getLayer(forIdentifier: OWAssociatedSkeletonShimmering.shimmeringLayerIdentifier)
        
        return shimmeringLayer
    }

    fileprivate func createLayer<T: OWInitializable>(forIdentifier identifier: String, type: T.Type) -> T {
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
