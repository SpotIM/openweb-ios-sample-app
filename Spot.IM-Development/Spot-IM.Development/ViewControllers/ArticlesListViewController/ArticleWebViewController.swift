//
//  ArticleWebViewController.swift
//  Spot-IM.Development
//
//  Created by Itay Dressler on 15/08/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import Spot_IM_Core
import WebKit

let kSpotImDemo = "spotim.name"

internal final class ArticleWebViewController: UIViewController {
    
    private lazy var scrollView = UIScrollView()
    private lazy var webView = WKWebView()
    private lazy var containerView = UIView()
    
    let spotId : String
    let postId: String
    let url: String
    
    var spotIMCoordinator: SpotImSDKFlowCoordinator?
    
    init(spotId:String, postId: String, url:String) {
        self.spotId = spotId
        self.postId = postId
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .groupTableViewBackground
        setup()
        setupSpotView()
    }
    
    private func setupSpotView() {

        SPClientSettings.setup(spotKey: spotId)
        spotIMCoordinator = SpotImSDKFlowCoordinator(postId: postId,
                                                     container: navigationController)
        guard let preConversationVC = spotIMCoordinator?.preConversationController() else { return }
        
        addChild(preConversationVC)
        containerView.addSubview(preConversationVC.view)
        preConversationVC.view.layout {
            $0.top.equal(to: containerView.topAnchor)
            $0.leading.equal(to: containerView.leadingAnchor)
            $0.bottom.equal(to: containerView.bottomAnchor)
            $0.trailing.equal(to: containerView.trailingAnchor)
        }
        
        preConversationVC.didMove(toParent: self)
    }
}

extension ArticleWebViewController {
    private func setup() {
        setupScrollView()
        setupWebView()
        setupContainerView()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
       
        scrollView.layout {
            $0.top.equal(to: view.topAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.bottom.equal(to: view.bottomAnchor)
        }
    }
    
    private func setupWebView() {
        
        scrollView.addSubview(webView)
        
        let height : CGFloat = url.contains(kSpotImDemo) ? 0.0 : 1200.0
      
        webView.layout {
            $0.top.equal(to: scrollView.topAnchor)
            $0.leading.equal(to: scrollView.leadingAnchor)
            $0.trailing.equal(to: scrollView.trailingAnchor)
            $0.height.equal(to: height)
            $0.width.equal(to: scrollView.widthAnchor)
        }
        
        if let Url =  URL(string: url) {
            self.webView.load(URLRequest(url:Url))
        }
        
        self.webView.scrollView.isScrollEnabled = false
        webView.isUserInteractionEnabled = false
    }
    
    private func setupContainerView() {
        scrollView.addSubview(containerView)
  
        containerView.layout {
            $0.top.equal(to: webView.bottomAnchor)
            $0.bottom.equal(to: scrollView.bottomAnchor)
            $0.leading.equal(to: scrollView.leadingAnchor)
            $0.trailing.equal(to: scrollView.trailingAnchor)
            $0.height.greaterThanOrEqual(to: 400)
        }
    }
}

