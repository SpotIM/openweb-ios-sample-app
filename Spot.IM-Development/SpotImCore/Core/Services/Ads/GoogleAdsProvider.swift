//
//  GoogleAdsProvider.swift
//  Spot.IM-Core
//
//  Created by Eugene on 25.10.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import GoogleMobileAds

final class GoogleAdsProvider: NSObject, AdsProvider {
    let bannerView: BaseView = .init()
    weak var bannerDelegate: AdsProviderBannerDelegate?
    weak var interstitialDelegate: AdsProviderInterstitialDelegate?
    
    private var banner: DFPBannerView?
    private var interstitial: DFPInterstitial?
    private let bannerSize: GADAdSize = kGADAdSizeBanner
    private let spotId: String
    
    init(spotId: String) {
        self.spotId = spotId
        super.init()
    }
    
    func setupAdsBanner(with adId: String = Configuration.testBannerID, in controller: UIViewController) {
        banner = DFPBannerView(adSize: bannerSize)
        banner?.adUnitID = adId
        banner?.delegate = self
        banner?.rootViewController = controller
        let req = DFPRequest()
        req.customTargeting = ["convSdkSpotId":spotId]
        banner?.load(req)
    }
    
    func setupInterstitial(with adId: String = Configuration.testInterstitialID) {
        interstitial = DFPInterstitial(adUnitID: adId)
        interstitial?.delegate = self
        let req = DFPRequest()
        req.customTargeting = ["convSdkSpotId":spotId]
        interstitial?.load(req)
    }
    
    func showInterstitial(in controller: UIViewController) -> Bool {
        guard
            let interstitial = interstitial,
            interstitial.isReady
            else { return false }
        
        interstitial.present(fromRootViewController: controller)
        
        return true
    }
    

}

extension GoogleAdsProvider: GADInterstitialDelegate {
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitialDelegate?.interstitialDidDismiss()
    }
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        interstitialDelegate?.interstitialWillBeShown()
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        interstitialDelegate?.interstitialFailedToLoad()
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        interstitialDelegate?.interstitialDidDismiss()
    }
}

extension GoogleAdsProvider: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.bannerView.addSubview(bannerView)
        bannerView.layout {
            $0.centerX.equal(to: self.bannerView.centerXAnchor)
            $0.centerY.equal(to: self.bannerView.centerYAnchor)
        }
        bannerDelegate?.bannerLoaded(adBannerSize: bannerSize.size)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        Logger.error(error)
        bannerDelegate?.bannerFailedToLoad()
    }
    
}

private extension GoogleAdsProvider {
    
    private enum Configuration {
        static let testInterstitialID: String = "/6499/example/interstitial"
        static let testBannerID: String = "/6499/example/banner"
    }
}
