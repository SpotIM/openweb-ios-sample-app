//
//  OWThemeStyleInjectorProtocol.swift
//  SpotImCore
//
//  Created by Alon Haiut on 11/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

protocol OWThemeStyleInjectorProtocol {
    func useAsThemeStyleInjector()
}

extension OWThemeStyleInjectorProtocol where Self: UIView {
    func useAsThemeStyleInjector() {
        let dummyThemeStyleViewUpdaterView = OWDummyThemeStyleUpdaterView()
        
        self.addSubview(dummyThemeStyleViewUpdaterView)
        dummyThemeStyleViewUpdaterView.OWSnp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.size.equalTo(OWDummyThemeStyleUpdaterView.Metrics.defaultSize)
        }
    }
}
