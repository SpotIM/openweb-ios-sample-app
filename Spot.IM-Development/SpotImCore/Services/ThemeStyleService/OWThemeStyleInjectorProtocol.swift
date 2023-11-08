//
//  OWThemeStyleInjectorProtocol.swift
//  SpotImCore
//
//  Created by Alon Haiut on 11/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

fileprivate struct Metrics {
    static var dummyViewKey = "DummyViewKey"
}

protocol OWThemeStyleInjectorProtocol {
    func useAsThemeStyleInjector()
}

extension OWThemeStyleInjectorProtocol where Self: UIView {
    func useAsThemeStyleInjector() {
        guard !self.isDummyUpdaterViewExist else {
            // Dummy view is already exist
            return
        }

        let dummyThemeStyleViewUpdaterView = OWDummyThemeStyleUpdaterView()

        self.addSubview(dummyThemeStyleViewUpdaterView)
        dummyThemeStyleViewUpdaterView.OWSnp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.size.equalTo(OWDummyThemeStyleUpdaterView.Metrics.defaultSize)
        }

        self.isDummyUpdaterViewExist = true
    }
}

extension OWThemeStyleInjectorProtocol where Self: UIView {
    var isDummyUpdaterViewExist: Bool {
        get {
            // Check if it was already set
            if let isExist = objc_getAssociatedObject(self, &Metrics.dummyViewKey) as? Bool {
                return isExist
            }

            return false
        } set {
            objc_setAssociatedObject(self, &Metrics.dummyViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
