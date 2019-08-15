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

 

    @IBOutlet weak var logo: UIImageView!
    @IBAction func showMainConversation(_ sender: UIButton) {
        navigationController?.pushViewController(ArticlesListViewController(spotId: .demoMainSpotKey), animated: true)
    }
    
    @IBAction func showFoxMainConversation(_ sender: UIButton) {
        navigationController?.pushViewController(ArticlesListViewController(spotId: .demoFoxSpotKeyForSSO), animated: true)
    }

    @IBAction func showDemoSpotConversation(_ sender: Any) {
        navigationController?.pushViewController(ArticlesListViewController(spotId: .demoMainSpotKey), animated: true)
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

