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
    let bannerView: SPBaseView = .init()
    weak var bannerDelegate: AdsProviderBannerDelegate?
    weak var interstitialDelegate: AdsProviderInterstitialDelegate?

    func version() -> String { return "1.0" }
    func setSpotId(spotId: String) { }
    func setupAdsBanner(with adId: String, in controller: UIViewController, validSizes: Set<AdSize>) {}
    func setupInterstitial(with adId: String) {}
    func showInterstitial(in controller: UIViewController) -> Bool { return false }
}
