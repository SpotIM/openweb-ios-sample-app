//
//  UIImageView+URL.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 09/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

extension UIImageView {
    func image(from url: URL) {
        UIImage.from(url: url) { result in
            if case .success(let image) = result {
                self.image = image
            }
        }
    }
}
