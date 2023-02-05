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
import SnapKit

internal final class ArticleViewController: UIViewController {

    @IBOutlet weak var stubImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    var spotId : String?
    var postId: String?

    let foxArticleId = "urn:uri:base64:11ed1e55-b77b-505b-9ef5-5e42fbd9daed"

    var spotIMCoordinator: SpotImSDKFlowCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SpotIm.createSpotImFlowCoordinator(loginDelegate: self) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let coordinator):
                self.spotIMCoordinator = coordinator
                
                coordinator.preConversationController(withPostId: self.postId ?? self.foxArticleId,
                                                      articleMetadata: SpotImArticleMetadata(url: "",
                                                                                             title: "",
                                                                                             subtitle: "",
                                                                                             thumbnailUrl: ""),
                                                      navigationController: self.navigationController!) {
                    [weak self] preConversationVC in
                    
                    guard let self = self else { return }
                    
                    self.addChild(preConversationVC)
                    self.containerView.addSubview(preConversationVC.view)
                    
                    preConversationVC.view.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                    
                    preConversationVC.didMove(toParent: self)
                }
            case .failure(let error):
                print(error)
            }
        }
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

extension ArticleViewController: SpotImLoginDelegate {
    func startLoginUIFlow(navigationController: UINavigationController) {
        let authVC = AuthenticationPlaygroundVC()
        navigationController.pushViewController(authVC, animated: true)
    }
}

extension ArticleViewController: SpotImLayoutDelegate {
    func viewHeightDidChange(to newValue: CGFloat) {
        containerHeightConstraint.constant = newValue
    }
}

