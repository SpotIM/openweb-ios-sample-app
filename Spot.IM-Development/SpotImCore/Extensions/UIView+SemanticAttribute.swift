//
//  UIView+SemanticAttribute.swift
//  SpotImCore
//
//  Created by Alon Haiut on 01/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

extension UIView {
    @objc @discardableResult func enforceSemanticAttribute() -> Self {
        self.semanticContentAttribute = OWLocalizationManager.shared.semanticAttribute

        return self
    }

    @discardableResult func enforceSemanticAttributeOldAPI() -> Self {
        self.semanticContentAttribute = LocalizationManager.currentLanguage?.customSemanticAttribute
        ?? self.semanticContentAttribute

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

extension UIButton {

    @objc @discardableResult override func enforceSemanticAttribute() -> Self {
        super.enforceSemanticAttribute()
        self.semanticContentAttribute = LocalizationManager.currentLanguage?.customSemanticAttribute ?? self.semanticContentAttribute
        self.titleLabel?.semanticContentAttribute = LocalizationManager.currentLanguage?.customSemanticAttribute ?? self.semanticContentAttribute
        self.titleLabel?.textAlignment = OWLocalizationManager.shared.textAlignment

        return self
    }
}
