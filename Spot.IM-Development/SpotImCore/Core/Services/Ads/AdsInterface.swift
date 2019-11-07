//
//  AdsInterface.swift
//  Spot.IM-Core
//
//  Created by Eugene on 25.10.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

protocol AdsProviderDelegate: class {
    
    func bannerAdDidLoad(adBannerSize: CGSize)
    
    func interstitialWillBeShown()
    func interstitialDidDismiss()
}

enum ABGroup: String, CaseIterable {
    /// Banner on preconversation screen
    case first = "A"
    /// Banner on preconversation screen + interstitial on "show more comments" transition
    case second = "B"
    /// Banner on preconversation screen + sticky banner on main conversation screen
    case third = "C"
}

protocol AdsProvider: class {
    
    func setupAdsBanner(with adId: String, in controller: UIViewController)
    func setupInterstitial(with adId: String)
    
    ///Return` true` or `false` if interstitial ready or not
    func showInterstitial(in controller: UIViewController) -> Bool
    
    var bannerView: BaseView { get }
    var delegate: AdsProviderDelegate? { get set }
}

final class AdsManager {
    
    static var shouldShowInterstitial: Bool = true
    
    func adsProvider() -> AdsProvider {
        #if canImport(GoogleMobileAds)
        return GoogleAdsProvider()
        #else
        return DefaultAdsProvider()
        #endif
    }
}
