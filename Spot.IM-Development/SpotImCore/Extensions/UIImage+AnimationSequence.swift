//
//  UIImage+AnimationSequence.swift
//  SpotImCore
//
//  Created by Eugene on 14.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

extension UIImage {

    /// Will search images with names: `'name'_index`
    static func animationImages(with name: String) -> [UIImage] {
        var index = 0
        var isEmpty = false
        var images = [UIImage]()
        while !isEmpty {
            let image = UIImage(named: name + "_\(index)", in: Bundle.spot, compatibleWith: nil)
            index += 1
            isEmpty = image == nil
            if let image = image {
                images.append(image)
            }
        }

        return images
    }
}
