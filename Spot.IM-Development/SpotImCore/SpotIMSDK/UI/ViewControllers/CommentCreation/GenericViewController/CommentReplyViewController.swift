//
//  CommentReplyViewController.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/1/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

protocol CommentReplyViewControllerDelegate: class {
    
    func commentReplyDidCreate(_ comment: SPComment)
    func commentReplyDidBlock(with commentText: String?)
    
}

class CommentReplyViewController<T: CommentStateable>: BaseViewController, AlertPresentable,
LoaderPresentable, UserAuthFlowDelegateContainable, UserPresentable {
    
    weak var userAuthFlowDelegate: UserAuthFlowDelegate?
    weak var delegate: CommentReplyViewControllerDelegate?
    private var authHandler: AuthenticationHandler?
    
    var model: T? {
        didSet {
            updateModelData()
        }
    }
    
    let topContainerView: BaseView = .init()
    let textInputViewContainer: SPTextInputView = .init()
    
    let activityIndicator: SPLoaderView = SPLoaderView()
    
    private let mainContainerView: BaseView = .init()
    private let postButton: BaseButton = .init()
    private let scrollView: BaseScrollView = .init()
    
    private var mainContainerBottomConstraint: NSLayoutConstraint?
    private var topContainerTopConstraint: NSLayoutConstraint?
    
    private var shouldBeAutoPosted: Bool = true
    
    deinit {
        unregisterFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupUserIconHandler()
        registerForKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updatePostButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // delay added for keyboard not to appear earlier than the screen
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            self.textInputViewContainer.makeFirstResponder()
        }
    }
    
    @objc
    func close() {
        if (model?.commentText.count ?? 0) >= commentCacheMinCount {
            let actions: [UIAlertAction] = [
                UIAlertAction(title: LocalizationManager.localizedString(key: "Leave Page"),
                              style: .destructive) { _ in
                                self.dismissController()
                },
                UIAlertAction(title: LocalizationManager.localizedString(key: "Continue Writing"),
                              style: .default)
            ]
            showAlert(title: LocalizationManager.localizedString(key: "Leave this page?"),
                      message: LocalizationManager.localizedString(key: "The text you entered might be deleted if not published."),
                      actions: actions)
        } else {
            dismissController()
        }
    }
    
    func dismissController() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .reveal
        transition.subtype = .fromBottom
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.popViewController(animated: false)
    }
    
    func userDidSignInHandler() -> AuthenticationHandler? {
        authHandler = AuthenticationHandler()
        authHandler?.authHandler = { [weak self] isAuthenticated in
            guard let self = self else { return }
            
            if !isAuthenticated {
                self.dismissController()
                return
            }
            
            self.updatePostButton()
            self.model?.fetchNavigationAvatar { [weak self] image, _ in
                guard
                    let self = self,
                    let image = image
                    else { return }
                
                self.textInputViewContainer.updateAvatar(image)
                self.updateUserIcon(image: image)
            }
            
            if isAuthenticated && !self.shouldBeAutoPosted {
                self.post()
                self.shouldBeAutoPosted = true
            }
        }
        
        return authHandler
    }
    
    func setupUserIconHandler() {
        userRightBarItem = UIBarButtonItem(customView: userIcon)
        userIcon.addTarget(self, action: #selector(showProfile), for: .touchUpInside)
        navigationItem.setRightBarButton(userRightBarItem!, animated: true)
    }
    
    @objc
    private func showProfile() {
        showProfileActions(sender: userIcon)
    }
    
    func updateModelData() {}
    
    @objc
    private func post() {
        view.endEditing(true)
        showLoader()
        model?.post()
    }
    
    @objc
    private func presentAuth() {
        view.endEditing(true)
        shouldBeAutoPosted = false
        userAuthFlowDelegate?.presentAuth()
        
        SPAnalyticsHolder.default.log(event: .loginClicked(.commentSignUp), source: .conversation)
    }
}

extension CommentReplyViewController {
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.layout {
            $0.top.equal(to: view.layoutMarginsGuide.topAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.bottom.equal(to: view.bottomAnchor)
        }
        scrollView.addSubview(mainContainerView)
        mainContainerView.addSubviews(topContainerView, textInputViewContainer, postButton)
        configureMainContainer()
        configureTopContainer()
        configureInputContainerView()
        configurePostButton()
    }
    
    private func configureMainContainer() {
        mainContainerView.backgroundColor = .spBackground0
        mainContainerView.layout {
            $0.top.equal(to: scrollView.topAnchor)
            $0.bottom.equal(to: scrollView.bottomAnchor)
            $0.leading.equal(to: scrollView.leadingAnchor)
            $0.trailing.equal(to: scrollView.trailingAnchor)
            $0.height.equal(to: scrollView.heightAnchor)
            $0.width.equal(to: scrollView.widthAnchor)
        }
    }
    
    private func configureInputContainerView() {
        textInputViewContainer.backgroundColor = .spBackground0
        textInputViewContainer.delegate = self
        textInputViewContainer.layout {
            $0.top.equal(to: topContainerView.bottomAnchor, offsetBy: Theme.inputViewEdgeInset)
            $0.leading.equal(to: mainContainerView.leadingAnchor, offsetBy: Theme.inputViewEdgeInset)
            $0.trailing.equal(to: mainContainerView.trailingAnchor, offsetBy: -Theme.inputViewEdgeInset)
            $0.bottom.equal(to: postButton.topAnchor, offsetBy: -Theme.inputViewEdgeInset)
            $0.height.greaterThanOrEqual(to: 80.0)
        }
    }
    
    private func configureTopContainer() {
        topContainerView.backgroundColor = .spBackground0
        topContainerView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        topContainerView.layout {
            $0.top.lessThanOrEqual(to: mainContainerView.topAnchor)
            $0.leading.equal(to: mainContainerView.leadingAnchor)
            $0.trailing.equal(to: mainContainerView.trailingAnchor)
        }
    }
    private func updatePostButton() {
        var postButtonTitle: String = LocalizationManager.localizedString(key: "Post")
        if let config = SPConfigDataSource.config,
            config.initialization?.policyForceRegister == true,
            SPUserSessionHolder.session.user?.registered == false {
            postButtonTitle = LocalizationManager.localizedString(key: "Sign Up to Post")
            postButton.addTarget(self, action: #selector(presentAuth), for: .touchUpInside)
        } else {
            postButton.addTarget(self, action: #selector(post), for: .touchUpInside)
        }
        postButton.setTitle(postButtonTitle, for: .normal)
    }
    
    private func configurePostButton() {
        postButton.setTitleColor(.white, for: .normal)
        postButton.setBackgroundColor(color: .spInactiveButtonBG, forState: .disabled)
        postButton.backgroundColor = .brandColor
        
        postButton.isEnabled = false
        postButton.titleLabel?.font = UIFont.roboto(style: .regular, of: Theme.postButtonFontSize)
        postButton.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: Theme.postButtonHorizontalInset,
            bottom: 0.0,
            right: Theme.postButtonHorizontalInset
        )
        
        postButton.addCornerRadius(Theme.postButtonRadius)
        postButton.layout {
            mainContainerBottomConstraint = $0.bottom.equal(to: mainContainerView.layoutMarginsGuide.bottomAnchor,
                                                            offsetBy: -Theme.postButtonBottom)
            $0.trailing.equal(to: mainContainerView.trailingAnchor, offsetBy: -Theme.postButtonTrailing)
            $0.height.equal(to: Theme.postButtonHeight)
        }
    }
}

extension CommentReplyViewController: KeyboardHandable {
    
    func keyboardWillShow(_ notification: Notification) {
        guard
            let expandedKeyboardHeight = notification.keyboardSize?.height,
            let animationDuration = notification.keyboardAnimationDuration
            else { return }
        updateBottomConstraint(constant: expandedKeyboardHeight + Theme.postButtonBottom,
                               animationDuration: animationDuration)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        guard let animationDuration = notification.keyboardAnimationDuration else { return }
        
        updateBottomConstraint(constant: Theme.mainOffset, animationDuration: animationDuration)
    }
    
    private func updateBottomConstraint(constant: CGFloat, animationDuration: Double) {
        mainContainerBottomConstraint?.constant = -constant
        UIView.animate(
            withDuration: animationDuration,
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: { _ in
                self.scrollView.contentInset.top = -self.topContainerView.frame.origin.y
            }
        )
    }
    
}

extension CommentReplyViewController: SPTextInputViewDelegate {
    
    func tooLongTextWasPassed() {
        // handle too long text passing
    }
    
    func textDidChange(_ text: String) {
        let isEmpty = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        postButton.isEnabled = !isEmpty
        model?.updateCommentText(text)
    }
}

private enum Theme {
    
    static let postButtonBottom: CGFloat = 8.0
    static let mainOffset: CGFloat = 16.0
    static let postButtonHeight: CGFloat = 32.0
    static let postButtonRadius: CGFloat = 5.0
    static let postButtonHorizontalInset: CGFloat = 32.0
    static let postButtonFontSize: CGFloat = 15.0
    static let postButtonTrailing: CGFloat = 16.0
    static let inputViewEdgeInset: CGFloat = 25.0
    
}
