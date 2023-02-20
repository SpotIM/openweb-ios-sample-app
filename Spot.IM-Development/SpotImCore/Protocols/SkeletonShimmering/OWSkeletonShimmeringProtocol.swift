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
    func updateSkeletonShimmeringFrame()
}

extension OWSkeletonShimmeringProtocol where Self: UIView {
    func addSkeletonShimmering() {
        for subview in self.subviews {
            // Creating layers for skeletone and shimmering
            let skeletonLayer = CALayer()
            let shimmeringLayer = CAGradientLayer()
            subview.registeredSkeletonLayer = skeletonLayer
            subview.registeredShimmeringLayer = shimmeringLayer

            skeletonLayer.frame = subview.bounds
            shimmeringLayer.frame = subview.bounds

            subview.layer.mask = skeletonLayer
            subview.layer.addSublayer(skeletonLayer)
            subview.layer.addSublayer(shimmeringLayer)
            subview.clipsToBounds = true

            let skeletonShimmeringService = OWSharedServicesProvider.shared.skeletonShimmeringService()
            skeletonShimmeringService.addSkeleton(to: subview)
        }
    }

    func removeSkeletonShimmering() {
        for subview in self.subviews {
            guard let skeletonLayer = subview.getSkeletonLayer(),
                  let shimmeringLayer = subview.getShimmeringLayer() else {
                let logger = OWSharedServicesProvider.shared.logger()
                logger.log(level: .medium, "Failed retriving skeleton shimmering layers when trying to remove them")
                return
            }
            // Cleanups
            subview.mask = nil
            subview.clipsToBounds = false
            skeletonLayer.removeFromSuperlayer()
            shimmeringLayer.removeFromSuperlayer()
            registeredSkeletonLayer = nil
            registeredShimmeringLayer = nil

            let skeletonShimmeringService = OWSharedServicesProvider.shared.skeletonShimmeringService()
            skeletonShimmeringService.removeSkeleton(from: subview)
        }
    }

    func updateSkeletonShimmeringFrame() {
        for subview in self.subviews {
            guard let skeletonLayer = subview.getSkeletonLayer(),
                  let shimmeringLayer = subview.getShimmeringLayer() else {
                let logger = OWSharedServicesProvider.shared.logger()
                logger.log(level: .medium, "Failed retriving skeleton shimmering layers when trying to update their frame")
                return
            }

            skeletonLayer.frame = subview.bounds
            shimmeringLayer.frame = subview.bounds
        }
    }
}

extension UIView {
    func getSkeletonLayer() -> CALayer? {
        return registeredSkeletonLayer
    }

    func getShimmeringLayer() -> CAGradientLayer? {
        return registeredShimmeringLayer
    }

    var registeredSkeletonLayer: CALayer? {
        get {
            // Check if a dictionary(mapper) is already exist
            if let registered = objc_getAssociatedObject(self, &OWAssociatedSkeletonShimmering.skeletonLayerIdentifier) as? CALayer {
                return registered
            }

            // Create a dictionary
            let registered = CALayer()
            return registered
        }
        set {
            objc_setAssociatedObject(self, &OWAssociatedSkeletonShimmering.skeletonLayerIdentifier,
                                       newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var registeredShimmeringLayer: CAGradientLayer? {
        get {
            // Check if a dictionary(mapper) is already exist
            if let registered = objc_getAssociatedObject(self, &OWAssociatedSkeletonShimmering.shimmeringLayerIdentifier) as? CAGradientLayer {
                return registered
            }

            // Create a dictionary
            let registered = CAGradientLayer()
            return registered
        }
        set {
            objc_setAssociatedObject(self, &OWAssociatedSkeletonShimmering.shimmeringLayerIdentifier,
                                       newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
