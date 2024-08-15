//
//  UIImageView+URL.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 09/06/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
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
