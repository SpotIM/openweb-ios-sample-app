//
//  UIBarButton+UIImage.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/8/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

extension UIBarButtonItem {

    convenience init(
        image: UIImage,
        highlightedImage: UIImage? = nil,
        imageScale: CGFloat = 1,
        target: Any,
        selector: Selector
        ) {

        let button = UIButton(type: .custom)
        button.setImage(image, for: UIControl.State())
        button.setImage(highlightedImage, for: .highlighted)
        button.addTarget(target, action: selector, for: UIControl.Event.touchUpInside)
        button.frame = CGRect(
            x: 0,
            y: 0,
            width: image.size.width * imageScale,
            height: image.size.height * imageScale
        )

        self.init(customView: button)
    }
}
