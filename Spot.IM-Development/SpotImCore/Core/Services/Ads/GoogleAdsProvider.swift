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
    weak var delegate: AdsProviderDelegate?
    
    private var banner: DFPBannerView?
    private var interstitial: DFPInterstitial?
    private let bannerSize: GADAdSize = kGADAdSizeLargeBanner
    
    override init() {
        super.init()
    }
    
    func setupAdsBanner(with adId: String = Configuration.testBannerID, in controller: UIViewController) {
        banner = DFPBannerView(adSize: bannerSize)
        banner?.adUnitID = adId
        banner?.delegate = self
        banner?.rootViewController = controller
        banner?.load(DFPRequest())
    }
    
    func setupInterstitial(with adId: String = Configuration.testInterstitialID) {
        interstitial = DFPInterstitial(adUnitID: adId)
        interstitial?.delegate = self
        interstitial?.load(DFPRequest())
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
        delegate?.interstitialDidDismiss()
    }
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        delegate?.interstitialWillBeShown()
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        //handle error here
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        delegate?.interstitialDidDismiss()
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
        delegate?.bannerAdDidLoad(adBannerSize: bannerSize.size)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        //handle error here
    }
    
}

private extension GoogleAdsProvider {
    
    private enum Configuration {
        static let testInterstitialID: String = "/6499/example/interstitial"
        static let testBannerID: String = "/6499/example/banner"
    }
}
