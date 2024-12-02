//
//  UIView+Utils.swift
//  OpenWebSDK
//
//  Created by Eugene on 7/26/19.
//  Copyright © 2019 OpenWeb. All rights reserved.
//

import UIKit

extension UIView {
    var superviews: [UIView] {
        var views = [self]
        var currentView = self
        while let superview = currentView.superview {
            views.append(superview)
            currentView = superview
        }
        return views
    }

    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}
