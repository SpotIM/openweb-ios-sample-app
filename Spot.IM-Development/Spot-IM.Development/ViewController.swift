//
//  ViewController.swift
//  Spot-IM.Development
//
//  Created by Andriy Fedin on 16/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import SpotImCore

class ViewController: UIViewController {

    let authProvider = SPDefaultAuthProvider()

    @IBOutlet weak var appInfoLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    var loadingButtonTitleBackup: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        fillVersionAndBuildNumber()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let articleVC = segue.destination as? ArticleViewController {
            articleVC.spotId = .demoMainSpotKey
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

        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.1882352941, green: 0.4980392157, blue: 0.8862745098, alpha: 1)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1882352941, green: 0.4980392157, blue: 0.8862745098, alpha: 1)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
            NSAttributedString.Key.foregroundColor: UIColor.white
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
    
    @IBAction private func showMainConversation(_ sender: UIButton) {
        setup(with: .demoGenericSpotKeyForSSO, from: sender)
        showArticles(with: .demoGenericSpotKeyForSSO, authenticationControllerId: .defaultAuthenticationControllerId)
    }
    
    @IBAction private func showDemoSpotConversation(_ sender: UIButton) {
        setup(with: .demoMainSpotKey, from: sender)
        showArticles(with: .demoMainSpotKey, authenticationControllerId: .defaultAuthenticationControllerId)
    }

    
    @IBAction private func showPreConversation(_ sender: UIButton) {
        SPPublicSessionInterface.resetUser()
        setup(with: .demoMainSpotKey, from: sender)
        performSegue(withIdentifier: "showPreConversationSegue", sender: self)
    }
    
    @IBAction private func showFoxMainConversation(_ sender: UIButton) {
        setSpotId(spotId: .demoFoxSpotKeyForSSO)
        self.showArticles(with: .demoFoxSpotKeyForSSO, authenticationControllerId: .foxAuthenticationControllerId, showArticleOnTableView: sender.accessibilityIdentifier == "table")
    }

    @IBAction private func crashButtonTapped(_ sender: AnyObject) {
        //Crashlytics.sharedInstance().crash()
    }

    private func showArticles(with spotId: String, authenticationControllerId: String, showArticleOnTableView: Bool = false) {
        let controller = ArticlesListViewController(spotId: spotId, authenticationControllerId: authenticationControllerId, addToTableView: showArticleOnTableView)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func setSpotId(spotId:String) {
        let key = "spotIdKey"
        if let lastSpot = UserDefaults.standard.value(forKey: key) as? String, lastSpot != spotId {
            SPPublicSessionInterface.resetUser()
        }
        
        UserDefaults.standard.setValue(spotId, forKey: key)
        SPClientSettings.setup(spotKey: spotId)
        SPClientSettings.darkModeBackgroundColor = #colorLiteral(red: 0.06274509804, green: 0.07058823529, blue: 0.2117647059, alpha: 1) 
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
    static var demoMainSpotKey:                     String { return "sp_ly3RvXf6" }
}

