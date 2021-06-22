//
//  ArticleWebViewController.swift
//  Spot-IM.Development
//
//  Created by Itay Dressler on 15/08/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import SpotImCore
import WebKit

let kSpotImDemo = "spotim.name"
let kDemoArticleToUse = "https://pix11.com/2014/08/07/is-steve-jobs-alive-and-secretly-living-in-brazil-reddit-selfie-sparks-conspiracy-theories/"

internal final class ArticleWebViewController: UIViewController {
    
    private lazy var scrollView = UIScrollView()
    private lazy var webView = WKWebView()
    private lazy var containerView = UIView()

    private var containerHeightConstraint: NSLayoutConstraint?

    private lazy var loadingIndicator = UIActivityIndicatorView(style: .gray)
    
    let spotId: String
    let postId: String
    let url: String
    let authenticationControllerId: String
    let metadata: SpotImArticleMetadata
    let shouldShowOpenFullConversationButton:Bool
    let shouldPresentFullConInNewNavStack:Bool
    var spotIMCoordinator: SpotImSDKFlowCoordinator?
    
    init(spotId: String, postId: String, metadata: SpotImArticleMetadata , url: String, authenticationControllerId: String) {
        self.spotId = spotId
        self.postId = postId
        self.metadata = metadata
        self.url = url
        self.authenticationControllerId = authenticationControllerId
        self.shouldShowOpenFullConversationButton = UserDefaults.standard.bool(forKey: "shouldShowOpenFullConversation")
        self.shouldPresentFullConInNewNavStack = UserDefaults.standard.bool(forKey: "shouldPresentInNewNavStack")
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .groupTableViewBackground
        title = "Article"
        setup()
//        SpotIm.setCustomSortByOptionText(option: .best, text: "Top")
        SpotIm.createSpotImFlowCoordinator(loginDelegate: self) { result in
            switch result {
            case .success(let coordinator):
                self.spotIMCoordinator = coordinator
                coordinator.setLayoutDelegate(delegate: self)
                coordinator.setCustomUIDelegate(delegate: self)
                if self.shouldShowOpenFullConversationButton {
                    self.showOpenFullConversationButton()
                }
                else {
                    self.setupSpotPreConversationView()
                }
            case .failure(let error):
                print("Failed to get flow coordinator: \(error)")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func showOpenFullConversationButton() {
        let button:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        button.backgroundColor = .black
        button.setTitle("Open Full Conversation", for: .normal)
        button.addTarget(self, action:#selector(self.openSpotImFullConversation), for: .touchUpInside)
        self.containerView.addSubview(button)
        button.layout {
            $0.top.equal(to: self.containerView.topAnchor)
            $0.leading.equal(to: self.containerView.leadingAnchor)
            $0.bottom.equal(to: self.containerView.bottomAnchor)
            $0.trailing.equal(to: self.containerView.trailingAnchor)
       }
    }

    private func setupSpotPreConversationView() {
        spotIMCoordinator?.preConversationController(withPostId: postId, articleMetadata: metadata, navigationController: navigationController!) {
            [weak self] preConversationVC in
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
        }
    }
    
    @objc private func openSpotImFullConversation() {
        guard let coordinator = self.spotIMCoordinator else {
            return
        }
        if (self.shouldPresentFullConInNewNavStack) {
            coordinator.presentFullConversationViewController(inViewController: self, withPostId: self.postId, articleMetadata: self.metadata, selectedCommentId: nil)
        }
        else {
            coordinator.pushFullConversationViewController(navigationController: self.navigationController!, withPostId: self.postId, articleMetadata: self.metadata)
        }
    }
}

extension ArticleWebViewController {
    
    private func setup() {
        setupScrollView()
        setupWebView()
        setupContainerView()
        setupLoadingIndicator()
    }

    private func setupLoadingIndicator() {
        webView.addSubview(loadingIndicator)
        loadingIndicator.layout {
            $0.centerX.equal(to: view.centerXAnchor)
            $0.centerY.equal(to: view.centerYAnchor)
        }
        loadingIndicator.startAnimating()
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

        webView.navigationDelegate = self
        
        webView.layout {
            $0.top.equal(to: scrollView.topAnchor)
            $0.leading.equal(to: scrollView.leadingAnchor)
            $0.trailing.equal(to: scrollView.trailingAnchor)
            $0.height.equal(to: 1500)
            $0.width.equal(to: scrollView.widthAnchor)
        }
        
        let isBadUrl = url.contains(kSpotImDemo)
        let urlToUse = isBadUrl ? kDemoArticleToUse : url
        if let url = URL(string: urlToUse) {
            self.webView.load(URLRequest(url: url))
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
            containerHeightConstraint = $0.height.greaterThanOrEqual(to: 0)
        }
    }
}

extension ArticleWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
    }
}


extension ArticleWebViewController: SpotImLoginDelegate {
    func startLoginFlow() {
        if (self.shouldPresentFullConInNewNavStack == false) {
            let authViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: authenticationControllerId)
            authViewController.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(authViewController, animated: true)
        }
        else {
            print("SDK notify that we started the Login flow - navigation is handled by the SDK")
        }
    }
    
    
    func presentControllerForSSOFlow(with spotNavController: UIViewController) {
        let authViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: authenticationControllerId)
        spotNavController.present(authViewController, animated: true, completion: nil)
    }
    
    func shouldDisplayLoginPromptForGuests() -> Bool {
        return true
    }
}

extension ArticleWebViewController: SpotImCustomUIDelegate {    
    func customizeView(view: CustomizableView, isDarkMode: Bool) {
        switch view {
        case .loginPrompt(let textView):
            customizeLoginPromptTextView(textView: textView)
            break
//        case .conversationFooter(let view):
//            break
//        case .navigationItemTitle(let textView):
//            break
//        case .communityGuidelines(let textView):
//            break
//        case .communityQuestion(let textView):
//            customizeCommunityQuestionTextView(textView: textView, isDarkMode: isDarkMode)
//        case .sayControlInPreConversation(let labelContainer, let label):
//            break
//        case .sayControlInMainConversation(let labelContainer, let label):
//            break
        default:
            break
        }
    }
    
    private func customizeLoginPromptTextView(textView: UITextView) {
        var multipleAttributes = [NSAttributedString.Key : Any]()
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        multipleAttributes[.underlineStyle] =       NSUnderlineStyle.single.rawValue
        multipleAttributes[.foregroundColor] =      UIColor.red
        multipleAttributes[.font] =                 UIFont.systemFont(ofSize: 18)
        multipleAttributes[.paragraphStyle] =       paragraph

        let attributedString = NSMutableAttributedString(string: "Register or Login to comment.", attributes: multipleAttributes)
        textView.attributedText = attributedString
    }
    
    private func customizeCommunityQuestionTextView(textView: UITextView, isDarkMode: Bool) {
        var multipleAttributes = [NSAttributedString.Key : Any]()
        
        multipleAttributes[.underlineStyle] =       NSUnderlineStyle.single.rawValue
        multipleAttributes[.foregroundColor] =      UIColor.red
        multipleAttributes[.font] =                 UIFont.systemFont(ofSize: 35)

        let attributedString = NSMutableAttributedString(string: "Custom community question with very very long text", attributes: multipleAttributes)
        textView.attributedText = attributedString
        if (isDarkMode) {
            textView.textColor = .white
        }
    }
}

extension ArticleWebViewController: SpotImLayoutDelegate {
    func viewHeightDidChange(to newValue: CGFloat) {
        containerHeightConstraint?.constant = newValue
    }
}
