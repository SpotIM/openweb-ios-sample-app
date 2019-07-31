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

    @IBOutlet weak var logo: UIImageView!
    @IBAction func showMainConversation(_ sender: UIButton) {
        // TODO: (Fedin) remove SPClientSettings.setup from here
        // when everything working with single key in AppDelegate
        SPClientSettings.setup(spotKey: .demoMainSpotKey)

        showMainConversation(with: conversationId)
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

