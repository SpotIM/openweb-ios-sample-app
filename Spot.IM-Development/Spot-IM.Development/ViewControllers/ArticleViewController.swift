//
//  ArticleViewController.swift
//  Spot-IM.Development
//
//  Created by Andriy Fedin on 13/08/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import SpotImCore

internal final class ArticleViewController: UIViewController {

    @IBOutlet weak var stubImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    var spotId : String?
    var postId: String?

    let foxArticleId = "urn:uri:base64:11ed1e55-b77b-505b-9ef5-5e42fbd9daed"

    var spotIMCoordinator: SpotImSDKFlowCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

        spotIMCoordinator = SpotImSDKFlowCoordinator(delegate: self)

        spotIMCoordinator?.preConversationController(
            withPostId: postId ?? foxArticleId,
            container: navigationController,
            completion: { [weak self] preConversationVC in

                guard let self = self else { return }

                self.addChild(preConversationVC)
                self.containerView.addSubview(preConversationVC.view)

                preConversationVC.view.layout {
                    $0.top.equal(to: self.containerView.topAnchor)
                    $0.leading.equal(to: self.containerView.leadingAnchor)
                    $0.bottom.equal(to: self.containerView.bottomAnchor)
                    $0.trailing.equal(to: self.containerView.trailingAnchor)
                }
                preConversationVC.didMove(toParent: self)
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

}

extension ArticleViewController: SpotImSDKNavigationDelegate {
    
    func controllerForSSOFlow() -> UIViewController & SSOAuthenticatable {
        let controller: AuthenticstionViewController = UIStoryboard(
            name: "Main",
            bundle: nil
        ).instantiateViewController(withIdentifier: "AuthenticstionViewController")
            as! AuthenticstionViewController
        
        return controller
    }
    
}

private extension String {
    static var demoGenericSpotKeyForSSO: String { return "sp_eCIlROSD" }
    static var demoFoxSpotKeyForSSO: String { return "sp_ANQXRpqH" }
    static var demoMainSpotKey: String { return "sp_ly3RvXf6" }
}
