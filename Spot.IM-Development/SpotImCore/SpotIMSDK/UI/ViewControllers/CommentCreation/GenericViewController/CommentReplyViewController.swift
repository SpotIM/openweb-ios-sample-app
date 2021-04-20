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
    let topContainerStack: BaseStackView = .init()
    var textInputViewContainer: SPCommentTextInputView = .init(
        hasAvatar: SPUserSessionHolder.session.user?.registered ?? false
    )
    lazy var usernameView: SPNameInputView = SPNameInputView()

    let activityIndicator: SPLoaderView = SPLoaderView()
    var showsUserAvatarInTextInput: Bool { !showsUsernameInput }
    
    private let mainContainerView: BaseView = .init()
    private let postButton: BaseButton = .init()
    private let scrollView: BaseScrollView = .init()
    private let commentLabelsContainer: SPCommentLabelsContainerView = .init()
    
    private var mainContainerBottomConstraint: NSLayoutConstraint?
    private var topContainerTopConstraint: NSLayoutConstraint?
    
    private var shouldBeAutoPosted: Bool = true
    private var showsUsernameInput: Bool {

        guard let config = SPConfigsDataSource.appConfig else { return true }
        let session = SPUserSessionHolder.session

        let shoudEnterName = config.initialization?.policyForceRegister == false && session.user?.registered == false
        let didEnterName = session.displayNameFrozen

        return shoudEnterName && !didEnterName

    }
    
    private var inputViews = [SPTextInputView]()
    
    deinit {
        unregisterFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupUserIconHandler()
        registerForKeyboardNotifications()
        inputViews.append(textInputViewContainer)
        if showsUsernameInput {
            inputViews.append(usernameView)
        }
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
            if self.showsUsernameInput {
                self.usernameView.makeFirstResponder()
            } else {
                self.textInputViewContainer.makeFirstResponder()
            }
        }
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        self.view.backgroundColor = .spBackground0
        mainContainerView.backgroundColor = .spBackground0
        textInputViewContainer.backgroundColor = .spBackground0
        topContainerView.backgroundColor = .spBackground0
        topContainerStack.backgroundColor = .spBackground0
        textInputViewContainer.updateColorsAccordingToStyle()
        postButton.setBackgroundColor(color: .spInactiveButtonBG, forState: .disabled)
        postButton.backgroundColor = .brandColor
        userIcon.backgroundColor = .spBackground0
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
        Logger.verbose("FirstComment: Dismissing creation view controller")
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
            self.updateAvatar()
            
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
    
    func updateModelData() {}

    func updateTextInputContainer(with type: SPCommentTextInputView.CommentType) {
        textInputViewContainer.configureCommentType(type)
        textInputViewContainer.updateText(model?.commentText ?? "")
    }

    func updateAvatar() {
        model?.fetchNavigationAvatar { [weak self] image, _ in
            guard
                let self = self,
                let image = image
                else { return }

            self.setAvatar(image: image)
        }
    }

    private func setAvatar(image: UIImage) {
        self.updateUserIcon(image: image)
        if self.showsUserAvatarInTextInput {
            self.textInputViewContainer.updateAvatar(image)
        } else {
            self.usernameView.updateAvatar(image)
        }
    }

    @objc
    private func showProfile() {
        showProfileActions(sender: userIcon)
    }

    @objc
    private func post() {
        view.endEditing(true)
        Logger.verbose("FirstComment: Post clicked")
        showLoader()
        model?.post()
    }

    @objc
    private func presentAuth() {
        view.endEditing(true)
        Logger.verbose("FirstComment: Signup to post clicked")
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
        mainContainerView.addSubviews(topContainerView, textInputViewContainer, postButton, commentLabelsContainer)
        topContainerView.addSubview(topContainerStack)
        
        configureMainContainer()
        configureTopContainerStack()
        configureTopContainer()
        configureUsernameView()
        configureInputContainerView()
        configurePostButton()
        configureCommentLabelsContainer()
        updateColorsAccordingToStyle()
    }
    
    private func configureMainContainer() {
        mainContainerView.layout {
            $0.top.equal(to: scrollView.topAnchor)
            $0.bottom.equal(to: scrollView.bottomAnchor)
            $0.leading.equal(to: scrollView.leadingAnchor)
            $0.trailing.equal(to: scrollView.trailingAnchor)
            $0.height.equal(to: scrollView.heightAnchor)
            $0.width.equal(to: scrollView.widthAnchor)
        }
    }

    private func configureUsernameView() {
        guard showsUsernameInput else { return }

        topContainerStack.addArrangedSubview(usernameView)
        usernameView.delegate = self
        usernameView.layout {
            $0.height.equal(to: 78)
            $0.width.equal(to: topContainerStack.widthAnchor)
        }
    }
    
    private func configureInputContainerView() {
        textInputViewContainer.delegate = self

        textInputViewContainer.layout {
            $0.top.equal(to: topContainerView.bottomAnchor, offsetBy: Theme.mainOffset)
            $0.leading.equal(to: mainContainerView.leadingAnchor, offsetBy: Theme.inputViewLeadingInset)
            $0.trailing.equal(to: mainContainerView.trailingAnchor, offsetBy: -Theme.inputViewEdgeInset)
            $0.bottom.equal(to: commentLabelsContainer.topAnchor, offsetBy: -Theme.inputViewEdgeInset)
            $0.height.greaterThanOrEqual(to: 40.0)
        }
    }
    
    private func configureTopContainer() {
        topContainerView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        topContainerView.layout {
            $0.top.equal(to: mainContainerView.topAnchor)
            $0.leading.equal(to: mainContainerView.leadingAnchor)
            $0.trailing.equal(to: mainContainerView.trailingAnchor)
            $0.height.greaterThanOrEqual(to: 40.0)
        }
    }

    private func configureTopContainerStack() {
        topContainerStack.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        topContainerStack.layout {
            $0.top.equal(to: topContainerView.topAnchor)
            $0.leading.equal(to: topContainerView.leadingAnchor)
            $0.bottom.equal(to: topContainerView.bottomAnchor)
            $0.trailing.equal(to: topContainerView.trailingAnchor)
        }
        topContainerStack.alignment = .leading
        topContainerStack.distribution = .equalSpacing
        topContainerStack.axis = .vertical
    }

    private func updatePostButton() {
        var postButtonTitle: String = LocalizationManager.localizedString(key: "Post")
        if let config = SPConfigsDataSource.appConfig,
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
        
        postButton.isEnabled = false
        postButton.titleLabel?.font = UIFont.preferred(style: .regular, of: Theme.postButtonFontSize)
        postButton.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: Theme.postButtonHorizontalInset,
            bottom: 0.0,
            right: Theme.postButtonHorizontalInset
        )
        
        postButton.addCornerRadius(Theme.postButtonRadius)
        postButton.layout {
            if UIDevice.current.hasNotch {
                mainContainerBottomConstraint = $0.bottom.equal(to: mainContainerView.layoutMarginsGuide.bottomAnchor,
                                                                offsetBy: -Theme.postButtonBottom)
            } else {
                mainContainerBottomConstraint = $0.bottom.equal(to: mainContainerView.bottomAnchor,
                offsetBy: -Theme.postButtonBottom)
            }
            $0.trailing.equal(to: mainContainerView.trailingAnchor, offsetBy: -Theme.postButtonTrailing)
            $0.height.equal(to: Theme.postButtonHeight)
        }
    }
    
    private func configureCommentLabelsContainer() {
        commentLabelsContainer.layout {
            $0.bottom.equal(to: postButton.topAnchor, offsetBy: -35.0)
            $0.leading.equal(to: usernameView.leadingAnchor, offsetBy: 10.0)
            $0.trailing.equal(to: usernameView.trailingAnchor, offsetBy: -10.0)
        }
    }
}

// MARK: - Extensions

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
        
        updateBottomConstraint(constant: Theme.postButtonBottom, animationDuration: animationDuration)
    }
    
    private func updateBottomConstraint(constant: CGFloat, animationDuration: Double) {
        Logger.verbose("Current constraints is \(mainContainerBottomConstraint!.constant)")
        Logger.verbose("Updating constraints to \(-constant)")

        mainContainerBottomConstraint?.constant = -constant
        UIView.animate(
            withDuration: animationDuration,
            animations: {
                self.view.layoutIfNeeded()
            })
    }
}

extension CommentReplyViewController: SPTextInputViewDelegate {

    func tooLongTextWasPassed() {
        // handle too long text passing
    }
    
    func input(_ view: SPTextInputView, didChange text: String) {
        print(text)

        if view === textInputViewContainer {
            model?.updateCommentText(text)
        } else if showsUsernameInput, view === usernameView {
            SPUserSessionHolder.update(displayName: text)
        }

        var postEnabled = true
        for aView in inputViews {
            if aView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? false {
                postEnabled = false
                break
            }
        }

        postButton.isEnabled = postEnabled
    }
}

extension CommentReplyViewController: AuthenticationViewDelegate {
    func authenticationStarted() {
        showLoader()
    }
}

// MARK: - Theme

private enum Theme {
    static let postButtonBottom: CGFloat = 20.0
    static let mainOffset: CGFloat = 16.0
    static let postButtonHeight: CGFloat = 32.0
    static let postButtonRadius: CGFloat = 5.0
    static let postButtonHorizontalInset: CGFloat = 32.0
    static let postButtonFontSize: CGFloat = 15.0
    static let postButtonTrailing: CGFloat = 16.0
    static let inputViewEdgeInset: CGFloat = 25.0
    static let inputViewLeadingInset: CGFloat = 10.0
}
