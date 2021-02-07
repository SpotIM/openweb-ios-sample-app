//
//  ViewController.swift
//  Spot-IM.Development
//
//  Created by Andriy Fedin on 16/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import SpotImCore
import GoogleMobileAds

class ViewController: UIViewController {

    @IBOutlet weak var appInfoLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    var loadingButtonTitleBackup: String?
    var currentSpotId: String = ""

    var adLoader:GADAdLoader!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        currentSpotId = UserDefaults.standard.string(forKey: "spotIdKey") ?? ""
        setupUI()
        fillVersionAndBuildNumber()
        
        print("Google Mobile Ads SDK version: \(GADMobileAds.sharedInstance().sdkVersion)")
        self.adLoader = GADAdLoader(adUnitID: "/282897603/elnuevodia.com/home/app_scroll", rootViewController: self, adTypes: [.nativeCustomTemplate], options: nil)
        self.adLoader?.delegate = self
        self.adLoader?.load(GADRequest())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let articleVC = segue.destination as? ArticleViewController {
            articleVC.spotId = .demoGenericSpotKeyForSSO
            articleVC.postId = "social-reviews"
        }
    }

    private func setupUI() {
        setupNavigationBar()
        logo.clipsToBounds = true
        logo.layer.cornerRadius = 8
    }

    private func setupNavigationBar() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)

        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
    }

    private func fillVersionAndBuildNumber() {
        var resultString = ""
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            resultString = "Version: \(version)\n"
        }
        if let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            resultString.append("Build: \(buildNumber)")
        }
        appInfoLabel.text = resultString
    }
    
    @IBAction private func showDemoSpotConversation(_ sender: UIButton) {
        setup(with: .demoGenericSpotKeyForSSO, from: sender)
        showArticles(with: .demoGenericSpotKeyForSSO, authenticationControllerId: .defaultAuthenticationControllerId)
    }

    @IBAction func showsp_mobileSSO(_ sender: UIButton) {
        setup(with: .demoSpotKeyForMobileSSO, from: sender)
        showArticles(with: .demoSpotKeyForMobileSSO, authenticationControllerId: .defaultAuthenticationControllerId)
    }
    
    @IBAction func showsp_mobileGuest(_ sender: UIButton) {
        setup(with: .demoSpotKeyForMobileGuest, from: sender)
        showArticles(with: .demoSpotKeyForMobileGuest, authenticationControllerId: .defaultAuthenticationControllerId)
    }
    
    @IBAction func showsp_mobileSocial(_ sender: UIButton) {
        setup(with: .demoSpotKeyForMobileSocial, from: sender)
        showArticles(with: .demoSpotKeyForMobileSocial, authenticationControllerId: .defaultAuthenticationControllerId)
    }
    
    @IBAction func show_spmobileSocialGuest(_ sender: UIButton) {
        setup(with: .demoSpotKeyForMobileSocialGuest, from: sender)
        showArticles(with: .demoSpotKeyForMobileSocialGuest, authenticationControllerId: .defaultAuthenticationControllerId)
    }
    
    @IBAction private func showFoxMainConversation(_ sender: UIButton) {
        setSpotId(spotId: .demoFoxSpotKeyForSSO)
        showArticles(with: .demoFoxSpotKeyForSSO, authenticationControllerId: .foxAuthenticationControllerId, showArticleOnTableView: sender.accessibilityIdentifier == "table")
    }

    private func showArticles(with spotId: String, authenticationControllerId: String, showArticleOnTableView: Bool = false) {
        let shouldReinit = spotId != currentSpotId
        currentSpotId = spotId
        let controller = ArticlesListViewController(spotId: spotId, authenticationControllerId: authenticationControllerId, addToTableView: showArticleOnTableView, shouldReinint: shouldReinit)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func setSpotId(spotId:String) {
        UserDefaults.standard.setValue(spotId, forKey: "spotIdKey")
        SpotIm.darkModeBackgroundColor = #colorLiteral(red: 0.06274509804, green: 0.07058823529, blue: 0.2117647059, alpha: 1)
    }

    private func setup(with spotId: String, from sender: UIButton) {
        loadingButtonTitleBackup = sender.titleLabel?.text
        setSpotId(spotId: spotId)
        sender.setTitle(self.loadingButtonTitleBackup, for: .normal)
    }
}

/// demo constants
private extension String {
    static var defaultAuthenticationControllerId:   String { return "AuthenticstionViewController" }
    static var foxAuthenticationControllerId:       String { return "FoxAuthenticationViewController" }
    static var demoGenericSpotKeyForSSO:            String { return "sp_eCIlROSD" }
    static var demoFoxSpotKeyForSSO:                String { return "sp_ANQXRpqH" }
    static var demoSpotKeyForMobileSSO:             String { return "sp_mobileSSO" }
    static var demoSpotKeyForMobileGuest:           String { return "sp_mobileGuest" }
    static var demoSpotKeyForMobileSocial:          String { return "sp_mobileSocial" }
    static var demoSpotKeyForMobileSocialGuest:     String { return "sp_mobileSocialGuest" }
}

extension ViewController: GADAdLoaderDelegate, GADNativeCustomTemplateAdLoaderDelegate {


    // MARK: - GADAdLoaderDelegate Methods
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("adLoader - didFailToReceiveAdWithError: \(error)")

    }

    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        print("adLoaderDidFinishLoading")
    }


    func nativeCustomTemplateIDs(for adLoader: GADAdLoader) -> [String] {
        return ["10067603"]
    }

    func adLoader(
        _ adLoader: GADAdLoader,
        didReceive nativeCustomTemplateAd: GADNativeCustomTemplateAd
    ) {
        print("Received custom native ad: \(nativeCustomTemplateAd)")

    }
}
