//
//  OWThemeStyleInjectorProtocol.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 11/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit

private struct Metrics {
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
            return self.getObjectiveCAssociatedObject(key: &Metrics.dummyViewKey) ?? false
        } set {
            self.setObjectiveCAssociatedObject(key: &Metrics.dummyViewKey, value: newValue)
        }
    }
}
