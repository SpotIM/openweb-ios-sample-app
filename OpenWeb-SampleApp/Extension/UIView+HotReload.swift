//
//  UIView+HotReload.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 06/03/2025.
//  Copyright © 2025 OpenWeb. All rights reserved.
//

import UIKit

#if canImport(InjectHotReload)
extension UIView {
    static func setupSwizzlingForHotReload() {
        if let method = class_getInstanceMethod(self, #selector(UIView.init(frame:))),
           let newMethod = class_getInstanceMethod(self, #selector(UIView.initHotReload(frame:))) {
            method_exchangeImplementations(method, newMethod)
        }
    }

    @objc func initHotReload(frame: CGRect) {
            // Call the original implementation (which is now pointing to this method due to swizzling)
            self.initHotReload(frame: frame)

            // Listen to hot reload notifications
            setupHotReload()
    }

    func setupHotReload() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleHotReloadNotification), name: Notification.Name("INJECTION_BUNDLE_NOTIFICATION"), object: nil)
    }

    @objc func handleHotReloadNotification(_ notification: Notification) {
        let setupViewsSelector = NSSelectorFromString("setupViews")
        if self.responds(to: setupViewsSelector) {
            let subviewsHiddenStates: [UIView: Bool] = self.subviews.reduce(into: [:]) { partialResult, subview in
                partialResult[subview] = subview.isHidden
            }
            self.perform(setupViewsSelector)
            for (subview, isHidden) in subviewsHiddenStates {
                subview.isHidden = isHidden
            }
        }
    }
}
#endif
