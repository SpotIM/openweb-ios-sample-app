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
import SnapKit

class ViewController: UIViewController {
    fileprivate struct Metrics {
        static let identifier = "view_controller_id"
        static let betaNewAPIBtnIdentifier = "beta_api_btn_id"
        static let settingsBtnIdentifier = "settings_btn_id"
        static let showDemoTableViewBtnIdentifier = "show_demo_table_view_btn_id"
        static let showDemoSpotArticlesBtnIdentifier = "show_demo_spot_articles_btn_id"
        static let showFoxNewsBtnIdentifier = "show_fox_news_btn_id"
        static let showMobileSSOIdentifier = "show_mobile_sso_btn_id"
        static let showMobileGuestIdentifier = "show_mobile_guest_btn_id"
        static let showMobileSocialIdentifier = "show_mobile_social_btn_id"
        static let authenticationPlaygroundBtnIdentifier = "authentication_playground_btn_id"
        static let customSpotBtnIdentifier = "custom_spot_btn_id"
        static let verticalMarginInScrollView: CGFloat = 8
    }

    @IBOutlet weak var appInfoLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    var loadingButtonTitleBackup: String?
    var currentSpotId: String = ""

    var adLoader: GADAdLoader!

    @IBOutlet weak var customSpotTextField: UITextField!
    @IBOutlet weak var optionsScrollView: UIScrollView!

    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var showDemoTableViewBtn: UIButton!
    @IBOutlet weak var showDemoSpotArticlesBtn: UIButton!
    @IBOutlet weak var showFoxNewsBtn: UIButton!
    @IBOutlet weak var showMobileSSO: UIButton!
    @IBOutlet weak var showMobileGuest: UIButton!
    @IBOutlet weak var showMobileSocial: UIButton!
    @IBOutlet weak var showMobileSocialGuest: UIButton!
    @IBOutlet weak var autenticationPlaygroundBtn: UIButton!
    @IBOutlet weak var customSpotBtn: UIButton!

    fileprivate lazy var betaNewAPIBtn: UIButton = {
        let btn = NSLocalizedString("BetaNewAPI", comment: "")
            .button
            .textColor(ColorPalette.shared.color(type: .text))
            .font(FontBook.paragraph)

        return btn
    }()

    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // swiftlint:disable line_length
        currentSpotId = UserDefaultsProvider.shared.get(key: UserDefaultsProvider.UDKey<String>.spotIdKey, defaultValue: "")
        // swiftlint:enable line_length
        setupUI()
        fillVersionAndBuildNumber()

        print("Google Mobile Ads SDK version: \(GADMobileAds.sharedInstance().sdkVersion)")
        self.adLoader = GADAdLoader(adUnitID: "/282897603/elnuevodia.com/home/app_scroll",
                                    rootViewController: self,
                                    adTypes: [.customNative], options: nil)
        self.adLoader?.delegate = self
        self.adLoader?.load(GADRequest())
        SpotIm.setAnalyticsEventDelegate(delegate: self)

        setupObservers()
    }

    override func loadView() {
        super.loadView()
        applyAccessibility()
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
        setupAppPreset()
        setupColors()
    }

    private func setupColors() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)

        let textColor = ColorPalette.shared.color(type: .text)
        settingsBtn.setTitleColor(textColor, for: .normal)
        showDemoTableViewBtn.setTitleColor(textColor, for: .normal)
        showDemoSpotArticlesBtn.setTitleColor(textColor, for: .normal)
        showFoxNewsBtn.setTitleColor(textColor, for: .normal)
        showMobileSSO.setTitleColor(textColor, for: .normal)
        showMobileGuest.setTitleColor(textColor, for: .normal)
        showMobileSocial.setTitleColor(textColor, for: .normal)
        showMobileSocialGuest.setTitleColor(textColor, for: .normal)
        autenticationPlaygroundBtn.setTitleColor(textColor, for: .normal)
        customSpotBtn.setTitleColor(textColor, for: .normal)
    }

    private func setupAppPreset() {
#if NEW_API
        optionsScrollView.addSubview(betaNewAPIBtn)
        betaNewAPIBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(optionsScrollView.contentLayoutGuide.snp.top).offset(Metrics.verticalMarginInScrollView)
        }

        showDemoTableViewBtn.removeFromSuperview()
        optionsScrollView.addSubview(showDemoTableViewBtn)
        showDemoTableViewBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(betaNewAPIBtn.snp.bottom).offset(Metrics.verticalMarginInScrollView)
            make.bottom.equalTo(showDemoSpotArticlesBtn.snp.top).offset(-Metrics.verticalMarginInScrollView)
        }
#endif

#if PUBLIC_DEMO_APP
        showDemoTableViewBtn.isHidden = true
        showFoxNewsBtn.isHidden = true
        showMobileSSO.isHidden = true
        showMobileGuest.isHidden = true
        showMobileSocial.isHidden = true
        showMobileSocialGuest.isHidden = true
        autenticationPlaygroundBtn.snp.updateConstraints { make in
            make.top.equalTo(showDemoSpotArticlesBtn.snp.bottom).offset(Metrics.verticalMarginInScrollView)
        }
#endif
    }

    private func setupNavigationBar() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = ColorPalette.shared.color(type: .text)
        navigationController?.navigationBar.barTintColor = ColorPalette.shared.color(type: .white)
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
        // swiftlint:disable line_length
        showArticlesWithSettingsAlert(with: .demoGenericSpotKeyForSSO,
                                      authenticationControllerId: AuthenticationMetrics.defaultAuthenticationPlaygroundId)
        // swiftlint:enable line_length
    }

    @IBAction func showsp_mobileSSO(_ sender: UIButton) {
        setup(with: .demoSpotKeyForMobileSSO, from: sender)
        showArticles(with: .demoSpotKeyForMobileSSO,
                     authenticationControllerId: AuthenticationMetrics.defaultAuthenticationPlaygroundId)
    }

    @IBAction func showsp_mobileGuest(_ sender: UIButton) {
        setup(with: .demoSpotKeyForMobileGuest, from: sender)
        // swiftlint:disable line_length
        showArticlesWithSettingsAlert(with: .demoSpotKeyForMobileGuest,
                                      authenticationControllerId: AuthenticationMetrics.defaultAuthenticationPlaygroundId)
        // swiftlint:enable line_length
    }

    @IBAction func showsp_mobileSocial(_ sender: UIButton) {
        setup(with: .demoSpotKeyForMobileSocial, from: sender)
        showArticles(with: .demoSpotKeyForMobileSocial,
                     authenticationControllerId: AuthenticationMetrics.defaultAuthenticationPlaygroundId)
    }

    @IBAction func show_spmobileSocialGuest(_ sender: UIButton) {
        setup(with: .demoSpotKeyForMobileSocialGuest, from: sender)
        showArticles(with: .demoSpotKeyForMobileSocialGuest,
                     authenticationControllerId: AuthenticationMetrics.defaultAuthenticationPlaygroundId)
    }

    @IBAction private func showFoxMainConversation(_ sender: UIButton) {
        setSpotId(spotId: .demoFoxSpotKeyForSSO)
        showArticlesWithSettingsAlert(with: .demoFoxSpotKeyForSSO,
                                      authenticationControllerId: AuthenticationMetrics.foxAuthenticationId,
                                      showArticleOnTableView: sender.accessibilityIdentifier == "table")
    }

    @IBAction func showCustomSpotConversation(_ sender: UIButton) {
        let spotId = customSpotTextField.text ?? ""

        if validate(spotId: spotId) {
            setup(with: spotId, from: sender)
            // swiftlint:disable line_length
            showArticlesWithSettingsAlert(with: spotId,
                                          authenticationControllerId: AuthenticationMetrics.defaultAuthenticationPlaygroundId,
                                          enableConversationCounter: true)
            // swiftlint:enable line_length
        } else {
            showInvalidSpotIdMessage()
        }
    }

    private func validate(spotId: String) -> Bool {
        guard !spotId.contains(" ") else { return false }

        return true
    }

    private func showInvalidSpotIdMessage() {
        let alert = UIAlertController(title: "Alert",
                                      message: "Seems like the spotId is invalid, please enter a valid spotId",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func showArticlesWithSettingsAlert(with spotId: String,
                                               authenticationControllerId: String,
                                               showArticleOnTableView: Bool = false,
                                               enableConversationCounter: Bool = false) {
        let showArticles = {
            self.showArticles(with: spotId,
                              authenticationControllerId: authenticationControllerId,
                              showArticleOnTableView: showArticleOnTableView)
        }

        let alert = UIAlertController(title: "Alert",
                                      message: "Please choose in which setting to open an article",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Pre-Conversation", style: .default, handler: { _ in
            showArticles()
        }))
        alert.addAction(UIAlertAction(title: "Full-Conversation - Push", style: .default, handler: { _ in
            UserDefaultsProvider.shared.save(value: true, forKey: .shouldShowOpenFullConversation)
            UserDefaultsProvider.shared.save(value: false, forKey: .shouldPresentInNewNavStack)
            showArticles()
        }))
        alert.addAction(UIAlertAction(title: "Full-Conversation - Present", style: .default, handler: { _ in
            UserDefaultsProvider.shared.save(value: true, forKey: .shouldShowOpenFullConversation)
            UserDefaultsProvider.shared.save(value: true, forKey: .shouldPresentInNewNavStack)
            showArticles()
        }))

        let readOnlyMode = SpotImReadOnlyMode.parseSampleAppManualConfig()

        if (readOnlyMode != .enable) {
            alert.addAction(UIAlertAction(title: "Comment - (Conversation Push)", style: .default, handler: { _ in
                UserDefaultsProvider.shared.save(value: true, forKey: .shouldOpenComment)
                UserDefaultsProvider.shared.save(value: false, forKey: .shouldPresentInNewNavStack)
                showArticles()
            }))
            alert.addAction(UIAlertAction(title: "Comment - (Conversation Present)", style: .default, handler: { _ in
                UserDefaultsProvider.shared.save(value: true, forKey: .shouldOpenComment)
                UserDefaultsProvider.shared.save(value: true, forKey: .shouldPresentInNewNavStack)
                showArticles()
            }))
        }

        if (enableConversationCounter) {
            alert.addAction(UIAlertAction(title: "Conversation Counter", style: .default, handler: { [weak self] _ in
                self?.showConversationCounter(with: spotId)
            }))
        }

        self.present(alert, animated: true, completion: nil)
    }

    private func showArticles(with spotId: String,
                              authenticationControllerId: String,
                              showArticleOnTableView: Bool = false) {
        let shouldReinit = spotId != currentSpotId
        currentSpotId = spotId
        let controller = ArticlesListViewController(spotId: spotId,
                                                    authenticationControllerId: authenticationControllerId,
                                                    addToTableView: showArticleOnTableView,
                                                    shouldReinint: shouldReinit)

        // This is for testing with a Tabbar
        setNavController(forController: controller, shouldAddTabBar: false)
    }

    private func setNavController(forController controller: UIViewController, shouldAddTabBar: Bool) {
        if shouldAddTabBar {
            let navController = UINavigationController(rootViewController: controller)
            let tabbar = UITabBarController()
            tabbar.viewControllers = [
                navController
            ]
            navigationController?.pushViewController(tabbar, animated: true)
        } else {
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    private func showConversationCounter(with spotId: String) {
        let shouldReinit = spotId != currentSpotId
        currentSpotId = spotId

        let requiredData = ConversationCounterRequiredData(spotId: spotId, shouldReinit: shouldReinit)
        let viewModel: ConversationCounterViewModel = ConversationCounterViewModel(dataModel: requiredData)
        let conversationCounterVC = ConversationCounterVC(viewModel: viewModel)
        navigationController?.pushViewController(conversationCounterVC, animated: true)
    }

    private func setSpotId(spotId: String) {
        UserDefaultsProvider.shared.save(value: spotId, forKey: .spotIdKey)
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
    static var demoGenericSpotKeyForSSO: String { return "sp_eCIlROSD" }
    static var demoFoxSpotKeyForSSO: String { return "sp_ANQXRpqH" }
    static var demoSpotKeyForMobileSSO: String { return "sp_mobileSSO" }
    static var demoSpotKeyForMobileGuest: String { return "sp_mobileGuest" }
    static var demoSpotKeyForMobileSocial: String { return "sp_mobileSocial" }
    static var demoSpotKeyForMobileSocialGuest: String { return "sp_mobileSocialGuest" }
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
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        betaNewAPIBtn.accessibilityIdentifier = Metrics.betaNewAPIBtnIdentifier
        settingsBtn.accessibilityIdentifier = Metrics.settingsBtnIdentifier
        showDemoTableViewBtn.accessibilityIdentifier = Metrics.showDemoTableViewBtnIdentifier
        showDemoSpotArticlesBtn.accessibilityIdentifier = Metrics.showDemoSpotArticlesBtnIdentifier
        showFoxNewsBtn.accessibilityIdentifier = Metrics.showFoxNewsBtnIdentifier
        showMobileSSO.accessibilityIdentifier = Metrics.showMobileSSOIdentifier
        showMobileGuest.accessibilityIdentifier = Metrics.showMobileGuestIdentifier
        showMobileSocial.accessibilityIdentifier = Metrics.showMobileSocialIdentifier
        autenticationPlaygroundBtn.accessibilityIdentifier = Metrics.authenticationPlaygroundBtnIdentifier
        customSpotBtn.accessibilityIdentifier = Metrics.customSpotBtnIdentifier
    }

    func setupObservers() {
        customSpotTextField.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .subscribe(onNext: { [weak self] _ in
                self?.customSpotTextField.endEditing(true)
            })
            .disposed(by: disposeBag)

        let keyboardShowHeight = NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                // swiftlint:disable line_length
                let height = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height
                // swiftlint:enable line_length
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
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let autenticationPlaygroundVC = AuthenticationPlaygroundVC()
                self.navigationController?.pushViewController(autenticationPlaygroundVC, animated: true)
            })
            .disposed(by: disposeBag)

        betaNewAPIBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
#if NEW_API
                let betaAPIVC = BetaNewAPIVC()
                self.navigationController?.pushViewController(betaAPIVC, animated: true)
#endif
            })
            .disposed(by: disposeBag)
    }
}
