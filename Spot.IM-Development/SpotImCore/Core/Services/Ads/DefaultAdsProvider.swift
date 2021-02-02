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
    weak var bannerDelegate: AdsProviderBannerDelegate?
    weak var interstitialDelegate: AdsProviderInterstitialDelegate?
    
    func setupAdsBanner(with adId: String, in controller: UIViewController, validSizes: Set<AdSize>) {}
    func setupInterstitial(with adId: String) {}
    func showInterstitial(in controller: UIViewController) -> Bool { return false }
}
