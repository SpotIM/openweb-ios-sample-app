//
//  UIView+SemanticAttribute.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 01/02/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit

extension UIView {
    @objc @discardableResult func enforceSemanticAttribute() -> Self {
        self.semanticContentAttribute = OWLocalizationManager.shared.semanticAttribute

        return self
    }
}

extension UILabel {
    @objc @discardableResult override func enforceSemanticAttribute() -> Self {
        super.enforceSemanticAttribute()
        self.textAlignment = OWLocalizationManager.shared.textAlignment

        return self
    }
}
