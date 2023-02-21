//
//  AdsInterface.swift
//  Spot.IM-Core
//
//  Created by Eugene on 25.10.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

public protocol AdsProviderBannerDelegate: AnyObject {
    func bannerLoaded(bannerView: UIView, adBannerSize: CGSize, adUnitID: String)
    func bannerFailedToLoad(error: Error)
}

public protocol AdsProviderInterstitialDelegate: AnyObject {
    func interstitialLoaded()
    func interstitialWillBeShown()
    func interstitialDidDismiss()
    func interstitialFailedToLoad(error: Error)
}

internal struct AdsABGroup {
    let abGroup: OWABGroup
    let isUserRegistered: Bool
    let disableInterstitialOnLogin: Bool

    init(abGroup: OWABGroup = OWABGroup.fourth, isUserRegistered: Bool = false, disableInterstitialOnLogin: Bool = false) {
        self.abGroup = abGroup
        self.isUserRegistered = isUserRegistered
        self.disableInterstitialOnLogin = disableInterstitialOnLogin
    }

    func interstitialEnabled() -> Bool {
        if isUserRegistered && disableInterstitialOnLogin {
            return false
        } else {
            return self.abGroup == .second
        }
    }

    func preConversatioBannerEnabled() -> Bool {
        return self.abGroup == .first || self.abGroup == .second || self.abGroup == .third
    }

    func mainConversationBannerEnabled() -> Bool {
        return self.abGroup == .first || self.abGroup == .second || self.abGroup == .third
    }

    func mainConversationBannerInFooterEnabled() -> Bool {
        return false
    }
}

public enum AdSize {
    case small
    case medium
    case large
}

public protocol AdsProvider: AnyObject {

    func version() -> String
    func setSpotId(spotId: String)
    func setupAdsBanner(with adId: String, in controller: UIViewController, validSizes: Set<AdSize>)
    func setupInterstitial(with adId: String)

    /// Return` true` or `false` if interstitial ready or not
    func showInterstitial(in controller: UIViewController) -> Bool

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
        if let googleAdsProvider = SpotIm.googleAdsProvider {
            googleAdsProvider.setSpotId(spotId: self.spotId)
            return googleAdsProvider
        }
        return DefaultAdsProvider()
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
