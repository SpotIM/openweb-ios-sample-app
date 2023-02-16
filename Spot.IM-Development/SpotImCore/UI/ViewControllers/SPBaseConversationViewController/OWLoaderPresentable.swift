//
//  LoaderPresentable.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/27/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

protocol OWLoaderPresentable {
    var activityIndicator: SPLoaderView { get }
}

extension OWLoaderPresentable where Self: UIViewController {

    func showLoader() {
        view.addSubview(activityIndicator)
        activityIndicator.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        activityIndicator.startLoader()
    }

    func hideLoader() {
        activityIndicator.stopLoader()
        activityIndicator.removeFromSuperview()
    }
}
