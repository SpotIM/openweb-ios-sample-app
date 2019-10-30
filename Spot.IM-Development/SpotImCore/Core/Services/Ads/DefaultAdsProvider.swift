//
//  DefaultAdsProvider.swift
//  Spot.IM-Core
//
//  Created by Eugene on 25.10.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

final class DefaultAdsProvider: AdsProvider {
    
    let bannerView: BaseView = .init()
    weak var delegate: AdsProviderDelegate?

    func setupAdsBanner(with adId: String, in controller: UIViewController) {}
    func setupInterstitial(with adId: String) {}
    func showInterstitial(in controller: UIViewController) -> Bool { return false }
}
