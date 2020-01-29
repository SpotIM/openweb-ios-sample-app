//
//  AdsInterface.swift
//  Spot.IM-Core
//
//  Created by Eugene on 25.10.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal protocol AdsProviderBannerDelegate: class {
    func bannerLoaded(adBannerSize: CGSize)
    func bannerFailedToLoad()
}

internal protocol AdsProviderInterstitialDelegate: class {
    func interstitialLoaded()
    func interstitialWillBeShown()
    func interstitialDidDismiss()
    func interstitialFailedToLoad()
}

internal enum ABGroup: String, CaseIterable {
    /// Banner on preconversation screen
    case first = "A"
    /// Banner on preconversation screen + interstitial on "show more comments" transition
    case second = "B"
    /// Banner on preconversation screen + sticky banner on main conversation screen
    case third = "C"
    /// No banners should be shown
    case fourth = "D"
}

internal protocol AdsProvider: class {
    
    func setupAdsBanner(with adId: String, in controller: UIViewController)
    func setupInterstitial(with adId: String)
    
    ///Return` true` or `false` if interstitial ready or not
    func showInterstitial(in controller: UIViewController) -> Bool
    
    var bannerView: BaseView { get }
    var bannerDelegate: AdsProviderBannerDelegate? { get set }
    var interstitialDelegate: AdsProviderInterstitialDelegate? { get set }
}

internal final class AdsManager {

    private static var adsViewTracker: SPAdsViewTracker = .init()
    private let spotId: String
    
    init(spotId: String) {
        self.spotId = spotId
    }
    
    static func shouldShowInterstitial(for conversationId: String?) -> Bool {
        return !adsViewTracker.isViewedConversation(with: conversationId)
    }

    static func willShowInterstitial(for conversationId: String?) {
        adsViewTracker.trackView(conversation: conversationId)
    }

    func adsProvider() -> AdsProvider {
        #if canImport(GoogleMobileAds)
        return GoogleAdsProvider(spotId: self.spotId)
        #else
        return DefaultAdsProvider()
        #endif
    }
}

internal final class SPAdsViewTracker {

    var viewedConversations: Set<String> = .init()

    func trackView(conversation id: String?) {
        guard let id = id else { return }
        viewedConversations.insert(id)
    }

    func isViewedConversation(with id: String?) -> Bool {
        guard let id = id else { return false }
        return id.isEmpty == false && viewedConversations.contains(id)
    }
}
