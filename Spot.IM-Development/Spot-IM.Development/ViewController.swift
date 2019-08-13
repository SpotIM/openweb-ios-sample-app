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

    var spotIMCoordinator: SpotImSDKFlowCoordinator?
    
    @IBOutlet weak var logo: UIImageView!
    @IBAction func showMainConversation(_ sender: UIButton) {
        // TODO: (Fedin) remove SPClientSettings.setup from here
        // when everything working with single key in AppDelegate
        spotIMCoordinator = SpotImSDKFlowCoordinator(spotId: .demoGenericSpotKeyForSSO,
                                                     postId: conversationId,
                                                     container: navigationController)
        spotIMCoordinator?.startFlow()
    }
    
    @IBAction func showFoxMainConversation(_ sender: UIButton) {
        spotIMCoordinator = SpotImSDKFlowCoordinator(spotId: .demoFoxSpotKeyForSSO,
                                                     postId: foxArticleId,
                                                     container: navigationController)
        spotIMCoordinator?.startFlow()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
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

