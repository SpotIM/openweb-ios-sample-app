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
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var appInfoLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    var loadingButtonTitleBackup: String?
    var currentSpotId: String = ""

    var adLoader:GADAdLoader!

    @IBOutlet weak var customSpotTextField: UITextField!
    @IBOutlet weak var optionsScrollView: UIScrollView!
    @IBOutlet weak var autenticationPlaygroundBtn: UIButton!
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currentSpotId = UserDefaults.standard.string(forKey: "spotIdKey") ?? ""
        setupUI()
        fillVersionAndBuildNumber()
        
        print("Google Mobile Ads SDK version: \(GADMobileAds.sharedInstance().sdkVersion)")
        self.adLoader = GADAdLoader(adUnitID: "/282897603/elnuevodia.com/home/app_scroll", rootViewController: self, adTypes: [.customNative], options: nil)
        self.adLoader?.delegate = self
        self.adLoader?.load(GADRequest())
        SpotIm.setAnalyticsEventDelegate(delegate: self)
        
        setupObservers()
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
        customSpotTextField.returnKeyType = .done
    }

    private func setupNavigationBar() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)

        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationController?.navigationBar.isTranslucent = false
        
        let navigationBarBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let navigationTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = navigationBarBackgroundColor
            appearance.titleTextAttributes = navigationTitleTextAttributes

            navigationController?.navigationBar.standardAppearance = appearance;
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        } else {
            navigationController?.navigationBar.backgroundColor = navigationBarBackgroundColor
            navigationController?.navigationBar.titleTextAttributes = navigationTitleTextAttributes
        }
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
        showArticlesWithSettingsAlert(with: .demoGenericSpotKeyForSSO, authenticationControllerId: AuthenticationMetrics.defaultAuthenticationPlaygroundId)
    }

    @IBAction func showsp_mobileSSO(_ sender: UIButton) {
        setup(with: .demoSpotKeyForMobileSSO, from: sender)
        showArticles(with: .demoSpotKeyForMobileSSO, authenticationControllerId: AuthenticationMetrics.defaultAuthenticationPlaygroundId)
    }
    
    @IBAction func showsp_mobileGuest(_ sender: UIButton) {
        setup(with: .demoSpotKeyForMobileGuest, from: sender)
        showArticlesWithSettingsAlert(with: .demoSpotKeyForMobileGuest, authenticationControllerId: AuthenticationMetrics.defaultAuthenticationPlaygroundId)
    }
    
    @IBAction func showsp_mobileSocial(_ sender: UIButton) {
        setup(with: .demoSpotKeyForMobileSocial, from: sender)
        showArticles(with: .demoSpotKeyForMobileSocial, authenticationControllerId: AuthenticationMetrics.defaultAuthenticationPlaygroundId)
    }
    
    @IBAction func show_spmobileSocialGuest(_ sender: UIButton) {
        setup(with: .demoSpotKeyForMobileSocialGuest, from: sender)
        showArticles(with: .demoSpotKeyForMobileSocialGuest, authenticationControllerId: AuthenticationMetrics.defaultAuthenticationPlaygroundId)
    }
    
    @IBAction private func showFoxMainConversation(_ sender: UIButton) {
        setSpotId(spotId: .demoFoxSpotKeyForSSO)
        showArticlesWithSettingsAlert(with: .demoFoxSpotKeyForSSO, authenticationControllerId: AuthenticationMetrics.foxAuthenticationId, showArticleOnTableView: sender.accessibilityIdentifier == "table")
    }
    
    @IBAction func showCustomSpotConversation(_ sender: UIButton) {
        let spotId = customSpotTextField.text ?? ""
        setup(with: spotId, from: sender)
        showArticlesWithSettingsAlert(with: spotId, authenticationControllerId: AuthenticationMetrics.defaultAuthenticationPlaygroundId)
    }
    
    private func showArticlesWithSettingsAlert(with spotId: String, authenticationControllerId: String, showArticleOnTableView: Bool = false) {
        let showArticles = {
            self.showArticles(with: spotId, authenticationControllerId: authenticationControllerId, showArticleOnTableView: showArticleOnTableView)
        }
        
        let alert = UIAlertController(title: "Alert", message: "Please choose in which setting to open an article", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Pre-Conversation", style: .default, handler: { action in
            showArticles()
        }))
        alert.addAction(UIAlertAction(title: "Full-Conversation - Push", style: .default, handler: { action in
            UserDefaults.standard.setValue(true, forKey: "shouldShowOpenFullConversation")
            UserDefaults.standard.setValue(false, forKey: "shouldPresentInNewNavStack")
            showArticles()
        }))
        alert.addAction(UIAlertAction(title: "Full-Conversation - Present", style: .default, handler: { action in
            UserDefaults.standard.setValue(true, forKey: "shouldShowOpenFullConversation")
            UserDefaults.standard.setValue(true, forKey: "shouldPresentInNewNavStack")
            showArticles()
        }))
        
        let readOnlyMode = SpotImReadOnlyMode.parseSampleAppManualConfig()
        
        if (readOnlyMode != .enable) {
            alert.addAction(UIAlertAction(title: "Comment - (Conversation Push)", style: .default, handler: { action in
                UserDefaults.standard.setValue(true, forKey: "shouldOpenComment")
                UserDefaults.standard.setValue(false, forKey: "shouldPresentInNewNavStack")
                showArticles()
            }))
            alert.addAction(UIAlertAction(title: "Comment - (Conversation Present)", style: .default, handler: { action in
                UserDefaults.standard.setValue(true, forKey: "shouldOpenComment")
                UserDefaults.standard.setValue(true, forKey: "shouldPresentInNewNavStack")
                showArticles()
            }))
        }
        
        self.present(alert, animated: true, completion: nil)
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
    static var demoGenericSpotKeyForSSO:            String { return "sp_eCIlROSD" }
    static var demoFoxSpotKeyForSSO:                String { return "sp_ANQXRpqH" }
    static var demoSpotKeyForMobileSSO:             String { return "sp_mobileSSO" }
    static var demoSpotKeyForMobileGuest:           String { return "sp_mobileGuest" }
    static var demoSpotKeyForMobileSocial:          String { return "sp_mobileSocial" }
    static var demoSpotKeyForMobileSocialGuest:     String { return "sp_mobileSocialGuest" }
}

extension ViewController: GADAdLoaderDelegate, GADCustomNativeAdLoaderDelegate {
    // MARK: - GADAdLoaderDelegate Methods
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("adLoader - didFailToReceiveAdWithError: \(error)")
    }

    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        print("adLoaderDidFinishLoading")
    }
    
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        return ["10067603"]
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive customNativeAd: GADCustomNativeAd) {
        print("Received custom native ad: \(customNativeAd)")
    }
}

extension ViewController: SPAnalyticsEventDelegate {
    internal func trackEvent(type: SPEventType, event: SPEventInfo) {
        switch type {
        case .userProfileClicked:
            print("Spot.IM Analytics Event - " + event.eventType)
        // more cases can be handled here ...
        default:
            print("Spot.IM Analytics Event - " + event.eventType)
        }
    }
}


fileprivate extension ViewController {
    func setupObservers() {
        customSpotTextField.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .subscribe(onNext: { [weak self] _ in
                self?.customSpotTextField.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        let keyboardShowHeight = NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                let height = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height
                return height ?? 0
            }
        
        let keyboardHideHeight = NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .map { _ -> CGFloat in
                0
            }
        
        let keyboardHeight = Observable.from([keyboardShowHeight, keyboardHideHeight])
            .merge()
            
        keyboardHeight
            .subscribe(onNext: { [weak self] height in
                guard let self = self else { return }
                self.optionsScrollView.contentOffset = CGPoint(x: 0, y: height/2)
            })
            .disposed(by: disposeBag)
        
        autenticationPlaygroundBtn.rx.tap
            .subscribe(onNext: { [weak self] height in
                guard let self = self else { return }
                let autenticationPlaygroundVC = AuthenticationPlaygroundVC()
                self.navigationController?.pushViewController(autenticationPlaygroundVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
