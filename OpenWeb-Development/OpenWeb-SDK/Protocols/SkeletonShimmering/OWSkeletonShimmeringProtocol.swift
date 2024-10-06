//
//  OWSkeletonShimmeringProtocol.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 18/10/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
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
            return self.getObjectiveCAssociatedObject(key: &OWAssociatedSkeletonShimmering.skeletonLayerIdentifier) ?? CALayer()
        } set {
            self.setObjectiveCAssociatedObject(key: &OWAssociatedSkeletonShimmering.skeletonLayerIdentifier, value: newValue)
        }
    }

    var registeredShimmeringLayer: CAGradientLayer? {
        get {
            return self.getObjectiveCAssociatedObject(key: &OWAssociatedSkeletonShimmering.shimmeringLayerIdentifier) ?? CAGradientLayer()
        } set {
            self.setObjectiveCAssociatedObject(key: &OWAssociatedSkeletonShimmering.shimmeringLayerIdentifier, value: newValue)
        }
    }
}
