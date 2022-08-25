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
import SnapKit

let kSpotImDemo = "spotim.name"
let kDemoArticleToUse = "https://pix11.com/2014/08/07/is-steve-jobs-alive-and-secretly-living-in-brazil-reddit-selfie-sparks-conspiracy-theories/"

internal final class ArticleWebViewController: UIViewController {
    
    fileprivate struct Metrics {
        static let modeButtonHeight: CGFloat = 50
        static let webViewHeight: CGFloat = 1500
    }
    
    private lazy var scrollView = UIScrollView()
    private lazy var webView = WKWebView()
    private lazy var containerView = UIView()

    private var containerHeightConstraint: Constraint?

    private lazy var loadingIndicator = UIActivityIndicatorView(style: .gray)
    
    fileprivate let silentSSOAuthentication: SilentSSOAuthenticationProtocol = SilentSSOAuthentication()
    
    let spotId: String
    let postId: String
    let url: String
    let authenticationControllerId: String
    let metadata: SpotImArticleMetadata
    let shouldShowOpenFullConversationButton:Bool
    let shouldShowOpenCommentButton:Bool
    let shouldPresentFullConInNewNavStack:Bool
    var spotIMCoordinator: SpotImSDKFlowCoordinator?
    let callbacks: SPViewActionsCallbacks = { type, source, postId in
        switch type {
        case .articleHeaderPressed:
            print("[" + source.description + "] header tapped for postId: " + postId)
        case .openUserProfile(let userId, let navController):
            print("[" + source.description + "]) user profile tapped for userId: " + userId)
            // here the publisher will navigate to the internal user profile
        default:
            break
        }
    }
    
    init(spotId: String, postId: String, metadata: SpotImArticleMetadata , url: String, authenticationControllerId: String) {
        self.spotId = spotId
        self.postId = postId
        self.metadata = metadata
        self.url = url
        self.authenticationControllerId = authenticationControllerId
        self.shouldShowOpenFullConversationButton = UserDefaults.standard.bool(forKey: "shouldShowOpenFullConversation")
        self.shouldShowOpenCommentButton = UserDefaults.standard.bool(forKey: "shouldOpenComment")
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
        if (spotId == "sp_mobileGuest") {
            SpotIm.setCustomSortByOptionText(option: .best, text: "Top")
        }
        SpotIm.createSpotImFlowCoordinator(loginDelegate: self) { result in
            switch result {
            case .success(let coordinator):
                self.spotIMCoordinator = coordinator
                coordinator.setLayoutDelegate(delegate: self)
                coordinator.setCustomUIDelegate(delegate: self)
                if self.shouldShowOpenFullConversationButton {
                    self.showOpenFullConversationButton()
                } else if self.shouldShowOpenCommentButton {
                    self.showOpenCoomentButton()
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
        setupModeButton(text: "Open Full Conversation", selector: #selector(self.openSpotImFullConversation))
    }
    
    private func showOpenCoomentButton() {
        setupModeButton(text: "Create Comment", selector: #selector(self.openSpotImCreateComment))
    }
    
    private func setupModeButton(text: String, selector: Selector) {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle(text, for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        self.containerView.addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(Metrics.modeButtonHeight)
        }
    }

    private func setupSpotPreConversationView() {
        spotIMCoordinator?.preConversationController(withPostId: postId, articleMetadata: metadata, navigationController: navigationController!, callbacks: callbacks) {
            [weak self] preConversationVC in
            guard let self = self else { return }
            self.addChild(preConversationVC)
            self.containerView.addSubview(preConversationVC.view)
            preConversationVC.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            preConversationVC.didMove(toParent: self)
        }
    }
    
    @objc private func openSpotImFullConversation() {
        guard let coordinator = self.spotIMCoordinator else {
            return
        }
        let completionHandler: SPShowFullConversationCompletionHandler = { success, error in
            if success {
                print("Successfully show full conversation")
            } else if let error = error {
                print("Error show full conversation - \(error.localizedDescription)")
            }
        }
        
        let mode: SPViewControllerPresentationalMode
        if (self.shouldPresentFullConInNewNavStack) {
            mode = .present(viewController: self)
        }
        else {
            mode = .push(navigationController: self.navigationController!)
        }
        
        coordinator.openFullConversationViewController(postId: self.postId, articleMetadata: self.metadata, presentationalMode: mode, callbacks: callbacks, completion: completionHandler)
    }
    
    
    @objc private func openSpotImCreateComment() {
        guard let coordinator = self.spotIMCoordinator else {
            return
        }
        let completionHandler: SPOpenNewCommentCompletionHandler = { success, error in
            if success {
                print("Successfully show create comment")
            } else if let error = error {
                print("Error show create comment - \(error.localizedDescription)")
            }
        }
        
        let mode: SPViewControllerPresentationalMode
        if (self.shouldPresentFullConInNewNavStack) {
            mode = .present(viewController: self)
        }
        else {
            mode = .push(navigationController: self.navigationController!)
        }
        
        coordinator.openNewCommentViewController(postId: postId, articleMetadata: metadata, fullConversationPresentationalMode: mode, callbacks: callbacks, completion: completionHandler)
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
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(view.center)
        }
        loadingIndicator.startAnimating()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
       
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupWebView() {
        
        scrollView.addSubview(webView)

        webView.navigationDelegate = self
        
        webView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(Metrics.webViewHeight)
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
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(webView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            containerHeightConstraint = make.height.greaterThanOrEqualTo(0).constraint
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
    func startLoginUIFlow(navigationController: UINavigationController) {
        let authVC: UIViewController
        if (authenticationControllerId == AuthenticationMetrics.defaultAuthenticationPlaygroundId) {
            authVC = AuthenticationPlaygroundVC()
        } else {
            authVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: authenticationControllerId)
        }
        navigationController.pushViewController(authVC, animated: true)
    }
    
    func renewSSOAuthentication(userId: String) {
        let spotIdWithTestLoginUser = "sp_eCIlROSD"
        if self.spotId == spotIdWithTestLoginUser,
           let genericSSO = GenericSSOAuthentication.mockModels.first(where: { $0.spotId == spotIdWithTestLoginUser }) {
            _ = silentSSOAuthentication.silentGenericSSO(for: genericSSO, ignoreLoginStatus: true)
                .take(1) // No need to disposed since we only take 1
                .subscribe(onNext: { userId in
                    DLog("Silent generic SSO completed successfully with userId: \(userId)")
                }, onError: { error in
                    DLog("Silent generic SSO failed with error: \(error)")
                })
        }
    }
    
    func shouldDisplayLoginPromptForGuests() -> Bool {
        return spotId == "sp_mobileGuest"
    }
}

extension ArticleWebViewController: SpotImCustomUIDelegate {    
    func customizeView(view: CustomizableView, isDarkMode: Bool, postId: String) {
        print("SpotImCustomUIDelegate customizeView callback receive with postId: \(postId)")
        guard spotId == "sp_mobileGuest" else { return }
        switch view {
        case .loginPrompt(let textView):
            customizeLoginPromptTextView(textView: textView)
            break
        case .conversationFooter(let view):
            view.backgroundColor = isDarkMode ? #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1) : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            break
        case .navigationItemTitle(let label):
            customizeNavigationItemTitle(label: label)
            break
        case .communityGuidelines(let textView):
            customizeComunityGuidelines(textView: textView, isDarkMode: isDarkMode)
            break
        case .communityQuestion(let textView):
            customizeCommunityQuestionTextView(textView: textView, isDarkMode: isDarkMode)
            break
        case .sayControlInPreConversation(let labelContainer, let label):
            label.textColor = isDarkMode ? UIColor.blue : UIColor.red
            break
        case .sayControlInMainConversation(let labelContainer, let label):
            label.textColor = isDarkMode ? UIColor.blue : UIColor.red
            break
        case .showCommentsButton(let button):
            button.setTitleColor(isDarkMode ? UIColor.blue : UIColor.red, for: .normal)
            button.setTitle("comments " + (button.getCommentsCount() ?? ""), for: .normal)
            break
        case .preConversationHeader(let titleLabel, let counterLabel):
            titleLabel.text = "Comments"
            counterLabel.isHidden = true
            break
        case .commentCreationActionButton(let button):
            button.backgroundColor = isDarkMode ? .black : .red
            button.setTitleColor(.white, for: .normal)
            break
        case .emptyStateReadOnlyLabel(let label):
            label.text = "custom empty read only"
            break
        case .readOnlyLabel(let label):
            label.text = "custom read only"
            break
        default:
            break
        }
    }
    
    private func customizeNavigationItemTitle(label: UILabel) {
        if let attributedString = label.attributedText?.mutableCopy() as? NSMutableAttributedString {
            attributedString.addAttribute(
                .font,
                value: UIFont.systemFont(ofSize: 18, weight: .bold),
                range: NSMakeRange(0,attributedString.length)
            )
            attributedString.addAttribute(
                .foregroundColor,
                value: UIColor.red,
                range: NSMakeRange(0,attributedString.length)
            )
            label.attributedText = attributedString
        }
    }
    
    private func customizeComunityGuidelines(textView: UITextView, isDarkMode: Bool) {
        textView.linkTextAttributes = [NSAttributedString.Key.foregroundColor: isDarkMode ? UIColor.red : UIColor.green]
        if let textViewAttributedString = textView.attributedText.mutableCopy() as? NSMutableAttributedString {
            textViewAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 22, weight: .heavy), range: NSMakeRange(0,
            textViewAttributedString.length))
            textView.attributedText = textViewAttributedString
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

        let attributedString = NSMutableAttributedString(string: textView.text, attributes: multipleAttributes)
        textView.attributedText = attributedString
        if (isDarkMode) {
            textView.textColor = .white
        }
    }
}

extension ArticleWebViewController: SpotImLayoutDelegate {
    func viewHeightDidChange(to newValue: CGFloat) {
        containerHeightConstraint?.update(offset: newValue)
    }
}
