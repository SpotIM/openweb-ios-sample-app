//
//  ViewController.swift
//  Spot-IM.Development
//
//  Created by Andriy Fedin on 16/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import Spot_IM_Core
import Crashlytics

class ViewController: UIViewController {

//    let conversationId = "p0st1"
    let conversationId = "fedin001"
    let foxArticleId = "urn:uri:base64:11ed1e55-b77b-505b-9ef5-5e42fbd9daed"

    @IBOutlet weak var logo: UIImageView!
    @IBAction func showMainConversation(_ sender: UIButton) {
        // TODO: (Fedin) remove SPClientSettings.setup from here
        // when everything working with single key in AppDelegate
        SPClientSettings.setup(spotKey: .demoMainSpotKey)
        showMainConversation(with: conversationId)
    }
    
    @IBAction func showFoxMainConversation(_ sender: UIButton) {
        SPClientSettings.setup(spotKey: .demoFoxSpotKeyForSSO)
        showMainConversation(with: foxArticleId)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func showMainConversation(with id: String) {
        let mainConversationVC = SPMainConversationViewController(with: id)
        navigationController?.pushViewController(mainConversationVC, animated: true)
    }

    private func setupUI() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        logo.clipsToBounds = true
        logo.layer.cornerRadius = 8
    }
    
    @IBAction func crashButtonTapped(_ sender: AnyObject) {
        Crashlytics.sharedInstance().crash()
    }
}

/// demo constants
private extension String {
    static var demoGenericSpotKeyForSSO:    String { return "sp_eCIlROSD" }
    static var demoFoxSpotKeyForSSO:        String { return "sp_ANQXRpqH" }
    static var demoMainSpotKey:             String { return "sp_ly3RvXf6" }
}

