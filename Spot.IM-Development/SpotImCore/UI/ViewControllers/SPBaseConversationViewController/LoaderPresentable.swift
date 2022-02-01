//
//  LoaderPresentable.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/27/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

protocol LoaderPresentable {
    var activityIndicator: SPLoaderView { get }
}

extension LoaderPresentable where Self: UIViewController {
    
    func showLoader() {
        view.addSubview(activityIndicator)
        activityIndicator.pinEdges(to: view)
        activityIndicator.startLoader()
    }
    
    func hideLoader() {
        activityIndicator.stopLoader()
        activityIndicator.removeFromSuperview()
    }
}
