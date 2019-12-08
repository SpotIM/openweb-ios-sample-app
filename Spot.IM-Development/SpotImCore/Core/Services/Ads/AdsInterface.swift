//
//  AdsInterface.swift
//  Spot.IM-Core
//
//  Created by Eugene on 25.10.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal protocol AdsProviderDelegate: class {
    
    func bannerAdDidLoad(adBannerSize: CGSize)
    
    func interstitialWillBeShown()
    func interstitialDidDismiss()
}

internal enum ABGroup: String, CaseIterable {
    /// Banner on preconversation screen
    case first = "A"
    /// Banner on preconversation screen + interstitial on "show more comments" transition
    case second = "B"
    /// Banner on preconversation screen + sticky banner on main conversation screen
    case third = "C"
}

internal protocol AdsProvider: class {
    
    func setupAdsBanner(with adId: String, in controller: UIViewController)
    func setupInterstitial(with adId: String)
    
    ///Return` true` or `false` if interstitial ready or not
    func showInterstitial(in controller: UIViewController) -> Bool
    
    var bannerView: BaseView { get }
    var delegate: AdsProviderDelegate? { get set }
}

internal final class AdsManager {

    private static var adsViewTracker: SPAdsViewTracker = .init()

    static func shouldShowInterstitial(for conversationId: String?) -> Bool {
        return !adsViewTracker.isViewedConversation(with: conversationId)
    }

    static func willShowInterstitial(for conversationId: String?) {
        adsViewTracker.trackView(conversation: conversationId)
    }

    //TODO: Be sure that target is `debugWithAds` `releaseWithAds`
    func adsProvider() -> AdsProvider {
        #if canImport(GoogleMobileAds)
        return GoogleAdsProvider()
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
