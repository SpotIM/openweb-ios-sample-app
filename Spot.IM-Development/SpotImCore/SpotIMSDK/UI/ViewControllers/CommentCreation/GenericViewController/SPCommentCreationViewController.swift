//
//  SPCommentCreationViewController.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/1/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

protocol CommentReplyViewControllerDelegate: AnyObject {
    
    func commentReplyDidCreate(_ comment: SPComment)
    func commentReplyDidBlock(with commentText: String?)
    
}

class SPCommentCreationViewController: SPBaseViewController,
                                       AlertPresentable,
                                       LoaderPresentable,
                                       UserAuthFlowDelegateContainable,
                                       UserPresentable {
    
    weak var userAuthFlowDelegate: UserAuthFlowDelegate?
    weak var delegate: CommentReplyViewControllerDelegate?
    private var authHandler: AuthenticationHandler?
    private var model: SPCommentCreationModel

    let topContainerView: BaseView = .init()
    let topContainerStack: BaseStackView = .init()
    var textInputViewContainer: SPCommentTextInputView = .init(
        hasAvatar: SPUserSessionHolder.session.user?.registered ?? false
    )
    lazy var usernameView: SPNameInputView = SPNameInputView()

    let activityIndicator: SPLoaderView = SPLoaderView()
    var showsUserAvatarInTextInput: Bool { !showsUsernameInput }
    
    private let mainContainerView: BaseView = .init()
    
    private let footerView: SPCommentFooterView = .init()
    
    private let scrollView: BaseScrollView = .init()
    private var commentLabelsContainer: SPCommentLabelsContainerView = .init()
    private var commentLabelsSection: String?
    private var sectionLabels: SPCommentLabelsSectionConfiguration?
    
    private var commentLabelsContainerHeightConstraint: NSLayoutConstraint?
    private var mainContainerBottomConstraint: NSLayoutConstraint?
    private var topContainerTopConstraint: NSLayoutConstraint?
    private var emptyArticleBottomConstraint: NSLayoutConstraint?

    
    private let closeButton: BaseButton = .init()
    
    private lazy var commentHeaderView = SPCommentReplyHeaderView()
    private lazy var commentNewHeaderView = SPCommentCreationNewHeaderView()
    private let commentingContainer: UIView = .init()
    private let commentingOnLabel: BaseLabel = .init()
    private lazy var articleView: SPArticleHeader = SPArticleHeader()
    
    private var shouldBeAutoPosted: Bool = true
    
    // user name input ("nickname") is visible only when commenting as a guest
    // (if user entered nickname in the past it will not be editable)
    var showsUsernameInput: Bool {
        guard let config = SPConfigsDataSource.appConfig else { return true }
        let session = SPUserSessionHolder.session

        return config.initialization?.policyForceRegister == false && session.user?.registered == false
    }
    var showCommentLabels: Bool {
        if let sharedConfig = SPConfigsDataSource.appConfig?.shared,
           sharedConfig.enableCommentLabels == true,
           let commentLabels = sharedConfig.commentLabels,
           !commentLabels.isEmpty {
            return true
        }
        return false
    }
    
    private var inputViews = [SPTextInputView]()
    
    deinit {
        unregisterFromKeyboardNotifications()
    }
    
    init(customUIDelegate: CustomUIDelegate?, model: SPCommentCreationModel) {
        self.model = model
        super.init(customUIDelegate: customUIDelegate)
        self.updateModelData()
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
        
        // remove keyboard when tapping outside of textView
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        mainContainerView.addGestureRecognizer(tap)
        
        if model.isCommentAReply() == false {
            topContainerView.bringSubviewToFront(closeButton)
        }
    }
    
    @objc override func overrideUserInterfaceStyleDidChange() {
        super.overrideUserInterfaceStyleDidChange()
        self.updateColorsAccordingToStyle()
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        mainContainerView.endEditing(true)
    }
    
    private func setupCommentLabelsContainer() {
        guard showCommentLabels == true, let sectionLabelsConfig = model.sectionCommentLabelsConfig else {
            hideCommentLabelsContainer()
            return
        }
        // set relevant comment labels to container
        let commentLabels = getCommentLabelsFromSectionConfig(sectionConfig: sectionLabelsConfig)
        commentLabelsContainer.setLabelsContainer(labels: commentLabels, guidelineText: sectionLabelsConfig.guidelineText, maxLabels: sectionLabelsConfig.maxSelected)
    }
    
    private func getCommentLabelsFromSectionConfig(sectionConfig: SPCommentLabelsSectionConfiguration) -> [CommentLabel] {
        var commentLabels: [CommentLabel] = []
        sectionConfig.labels.forEach { labelConfig in
            if let url = labelConfig.getIconUrl(),
               let color = UIColor.color(rgb: labelConfig.color) {
                commentLabels.append(CommentLabel(id: labelConfig.id, text: labelConfig.text, iconUrl: url, color: color))
            }
        }
        return commentLabels
    }
    
    private func hideCommentLabelsContainer() {
        commentLabelsContainer.isHidden = true
        commentLabelsContainerHeightConstraint?.constant = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updatePostButton()
        setupCommentLabelsContainer()
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
    override func updateColorsAccordingToStyle() {
        super.updateColorsAccordingToStyle()
        self.view.backgroundColor = .spBackground0
        mainContainerView.backgroundColor = .spBackground0
        textInputViewContainer.backgroundColor = .spBackground0
        topContainerView.backgroundColor = .spBackground0
        topContainerStack.backgroundColor = .spBackground0
        textInputViewContainer.updateColorsAccordingToStyle()
        userIcon.backgroundColor = .spBackground0
        commentLabelsContainer.updateColorsAccordingToStyle()
        usernameView.updateColorsAccordingToStyle()
        footerView.updateColorsAccordingToStyle()
        
        configureCommentDesign(SpotIm.enableCreateCommentNewDesign)
        
        if model.isCommentAReply() == false {
            articleView.updateColorsAccordingToStyle()
        }
        
        updateAvatar() // placeholder is adjusted to theme
    }
    
    private func configureCommentDesign(_ shouldEnableCreateCommentNewDesign: Bool) {
        
        if shouldEnableCreateCommentNewDesign {
            commentNewHeaderView.updateColorsAccordingToStyle()
        } else {
            configureCommentOldDesign()
        }
    }
    
    private func configureCommentOldDesign() {
        if model.isCommentAReply() == true {
            commentHeaderView.updateColorsAccordingToStyle()
        } else {
            commentingContainer.backgroundColor = .spBackground0
            commentingOnLabel.textColor = .spForeground4
            commentingOnLabel.backgroundColor = .spBackground0
            closeButton.backgroundColor = .spBackground0
            closeButton.setImage(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), for: .normal)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let state = UIApplication.shared.applicationState
        if #available(iOS 12.0, *) {
            if previousTraitCollection?.userInterfaceStyle != self.traitCollection.userInterfaceStyle {
                // traitCollectionDidChange() is called multiple times, see: https://stackoverflow.com/a/63380259/583425
                if state != .background {
                    self.updateColorsAccordingToStyle()
                }
            }
        } else {
            if state != .background {
                self.updateColorsAccordingToStyle()
            }
        }
    }
    
    @objc
    func close() {
        if (model.commentText.count) >= commentCacheMinCount {
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
            self.updatePostButtonEnabledState()
            self.updateAvatar()
            
            if isAuthenticated && !self.shouldBeAutoPosted {
                if (self.isValidInput()) {
                    self.post()
                }
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
    
    func updateModelData() {
        configureModelHandlers()
        if model.isCommentAReply() == true {
            updateModelDataForReply()
        } else {
            updateModelDataForComment()
        }
    }
    
    func configureModelHandlers() {
        model.postCompletionHandler = {
            [weak self] responseData in
            guard let self = self else { return }

            if responseData.status == .block || !responseData.published {
                switch responseData.content?.first {
                case .text(let text):
                    self.delegate?.commentReplyDidBlock(with: text.text)
                default: break
                }
                
            } else {
                self.delegate?.commentReplyDidCreate(responseData)
            }
            self.dismissController()
        }
        
        model.postErrorHandler = { [weak self] error in
            guard let self = self else { return }

            self.hideLoader()
            self.showAlert(
                title: LocalizationManager.localizedString(key: "Oops..."),
                message: error.localizedDescription
            )
        }
    }
    
    
    // MARK: - Comment Related Logic
    func updateModelDataForComment() {
        if SpotIm.enableCreateCommentNewDesign {
            setupNewHeader()
        } else {
            setupHeader()
        }

        updateTextInputContainer(with: .comment)
        updateAvatar()
    }
    
    private func setupNewHeader() {
        guard commentNewHeaderView.superview == nil else {
            return
        }
        topContainerStack.insertArrangedSubview(commentNewHeaderView, at: 0)
        
        commentNewHeaderView.layout {
            $0.top.equal(to: topContainerStack.topAnchor)
            $0.leading.equal(to: topContainerStack.leadingAnchor)
            $0.trailing.equal(to: topContainerStack.trailingAnchor)
            $0.height.equal(to: 60)
        }
        
        commentNewHeaderView.delegate = self
        commentNewHeaderView.configure()
        commentNewHeaderView.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    private func setupHeader() {
        setupHeaderComponentsIfNeeded()
        if shouldDisplayArticleHeader(), #available(iOS 11.0, *) {
            topContainerStack.insertArrangedSubview(articleView, at: 1)
            articleView.setTitle(model.dataModel.articleMetadata.title)
            articleView.setImage(with: URL(string: model.dataModel.articleMetadata.thumbnailUrl))
            articleView.setAuthor(model.dataModel.articleMetadata.subtitle)

            articleView.layout {
                $0.height.equal(to: 85.0)
                $0.width.equal(to: topContainerStack.widthAnchor)
            }
            
            topContainerStack.setCustomSpacing(16, after: commentingOnLabel)
            commentingOnLabel.text = LocalizationManager.localizedString(key: "Commenting on")
        } else {
            emptyArticleBottomConstraint?.isActive = true
            commentingOnLabel.text = LocalizationManager.localizedString(key: "Add a Comment")
        }
    }
    
    private func setupHeaderComponentsIfNeeded() {
        guard commentingOnLabel.superview == nil, closeButton.superview == nil else {
            return
        }

        commentingContainer.addSubview(commentingOnLabel)

        topContainerStack.insertArrangedSubview(commentingContainer, at: 0)

        topContainerView.addSubview(closeButton)
        
        commentingOnLabel.font = UIFont.preferred(style: .regular, of: 16.0)
        commentingOnLabel.text = LocalizationManager.localizedString(key: "Commenting on")
        commentingOnLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        commentingOnLabel.sizeToFit()
        
        commentingContainer.layout {
            $0.top.equal(to: topContainerStack.topAnchor)
            $0.leading.equal(to: topContainerStack.leadingAnchor)
            $0.trailing.equal(to: topContainerStack.trailingAnchor)
            $0.height.equal(to: commentingOnLabel.frame.height + 41)
        }
        
        commentingOnLabel.layout {
            $0.top.equal(to: commentingContainer.topAnchor, offsetBy: 25)
            $0.leading.equal(to: commentingContainer.leadingAnchor, offsetBy: 16)
            $0.trailing.equal(to: commentingContainer.trailingAnchor, offsetBy: -16)
            $0.bottom.equal(to: commentingContainer.bottomAnchor, offsetBy: -16)
        }
        
        closeButton.setImage(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), for: .normal)
        closeButton.layout {
            $0.centerY.equal(to: topContainerView.topAnchor, offsetBy: 35)
            $0.trailing.equal(to: topContainerView.trailingAnchor, offsetBy: -5.0)
            $0.width.equal(to: 40.0)
            $0.height.equal(to: 40.0)
        }
        
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }

    private func shouldDisplayArticleHeader() -> Bool {
        if UIDevice.current.screenType != .iPhones_5_5s_5c_SE,
           SpotIm.displayArticleHeader,
           !(showCommentLabels && showsUsernameInput) {
            return true
        } else {
            return false
        }
    }


    // MARK: - Reply Related Logic
    func updateModelDataForReply() {
        
        let shouldHideCommentText = showCommentLabels && showsUsernameInput
        let commentReplyDataModel = CommentReplyDataModel(
            author: model.dataModel.replyModel?.authorName,
            comment: model.dataModel.replyModel?.commentText
        )
        
        let headerView: UIView
        if SpotIm.enableCreateCommentNewDesign {
            commentNewHeaderView.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
            commentNewHeaderView.delegate = self
            commentNewHeaderView.configure(with: commentReplyDataModel)
            if shouldHideCommentText {
                commentNewHeaderView.hideCommentText()
            }
            headerView = commentNewHeaderView
        } else {
            commentHeaderView.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
            commentHeaderView.configure(with: commentReplyDataModel)
            if shouldHideCommentText {
                commentHeaderView.hideCommentText()
            }
            headerView = commentHeaderView
        }
        
        topContainerStack.insertArrangedSubview(headerView, at: 0)
        
        let heightWithCommentText: CGFloat = SpotIm.enableCreateCommentNewDesign ? 135 : 111
        let heightWithoutCommentText: CGFloat = SpotIm.enableCreateCommentNewDesign ? 115 : 68

        headerView.layout {
            $0.top.equal(to: topContainerStack.topAnchor)
            $0.height.equal(to: shouldHideCommentText ? heightWithoutCommentText : heightWithCommentText)
            $0.width.equal(to: topContainerStack.widthAnchor)
        }

        updateTextInputContainer(with: .reply)
        updateAvatar()
    }


    func updateTextInputContainer(with type: SPCommentTextInputView.CommentType) {
        textInputViewContainer.configureCommentType(type)
        textInputViewContainer.updateText(model.commentText)
    }

    func updateAvatar() {
        model.fetchNavigationAvatar { [weak self] image, _ in
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

    private func post() {
        view.endEditing(true)
        Logger.verbose("FirstComment: Post clicked")
        showLoader()
        if commentLabelsContainer.selectedLabelsIds.count > 0 {
            model.updateCommentLabels(labelsIds: commentLabelsContainer.selectedLabelsIds)
        }
        model.post()
        SPAnalyticsHolder.default.log(event: .commentPostClicked, source: .conversation)
    }

    private func presentAuth() {
        view.endEditing(true)
        Logger.verbose("FirstComment: Signup to post clicked")
        shouldBeAutoPosted = false
        userAuthFlowDelegate?.presentAuth()

        SPAnalyticsHolder.default.log(event: .loginClicked(.commentSignUp), source: .conversation)
    }
    
    private func updatePostButtonEnabledState() {
        let isEnabled = isValidInput() || self.signupToPostButtonIsActive()
        footerView.setIsPostButtonEnabled(isEnabled)
    }
    
    private func isValidInput() -> Bool {
        var isValidInput = true
        for aView in inputViews {
            if aView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? false {
                isValidInput = false
                break
            }
        }
        
        // check comment labels minSelected
        if let sectionLabelsConfig = self.sectionLabels,
           sectionLabelsConfig.minSelected > commentLabelsContainer.selectedLabelsIds.count {
            isValidInput = false
        }
        
        return isValidInput
    }
    
    private func signupToPostButtonIsActive() -> Bool {
        if let config = SPConfigsDataSource.appConfig,
           config.initialization?.policyForceRegister == true,
           SPUserSessionHolder.session.user?.registered == false {
            return true
        }
        else {
            return false
        }
    }
    
    // on device orientation change
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // set hide/show keyboard suggestions according to landscape/portrait mode
        var isPortrait = true
        if size.width > self.view.frame.size.width {
            // landscape
            isPortrait = false
        }
        textInputViewContainer.setKeyboardAccordingToDeviceOrientation(isPortrait: isPortrait)
        usernameView.setKeyboardAccordingToDeviceOrientation(isPortrait: isPortrait)
    }
}

extension SPCommentCreationViewController {
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.layout {
            $0.top.equal(to: view.layoutMarginsGuide.topAnchor)
            // avoide device notch in landscape
            if #available(iOS 11.0, *) {
                $0.leading.equal(to: view.safeAreaLayoutGuide.leadingAnchor)
                $0.trailing.equal(to: view.safeAreaLayoutGuide.trailingAnchor)
                $0.bottom.equal(to: view.safeAreaLayoutGuide.bottomAnchor)
            } else {
                $0.leading.equal(to: view.leadingAnchor)
                $0.trailing.equal(to: view.trailingAnchor)
                $0.bottom.equal(to: view.bottomAnchor)
            }
        }
        scrollView.addSubview(mainContainerView)
        mainContainerView.addSubviews(topContainerView, textInputViewContainer, commentLabelsContainer, footerView)
        topContainerView.addSubview(topContainerStack)
        
        configureMainContainer()
        configureTopContainerStack()
        configureTopContainer()
        configureUsernameView()
        configureInputContainerView()
        configureFooterView()
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
        // put existing nickname if exist
        if (SPUserSessionHolder.session.displayNameFrozen) {
            usernameView.text = SPUserSessionHolder.session.user?.displayName
            usernameView.setTextAccess(isEditable: false)
        }
    }
    
    private func configureInputContainerView() {
        textInputViewContainer.delegate = self
        textInputViewContainer.layout {
            $0.top.equal(to: topContainerView.bottomAnchor, offsetBy: Theme.mainOffset)
            $0.leading.equal(to: mainContainerView.leadingAnchor, offsetBy: Theme.inputViewLeadingInset)
            $0.trailing.equal(to: mainContainerView.trailingAnchor, offsetBy: -Theme.inputViewEdgeInset)
            $0.bottom.greaterThanOrEqual(to: commentLabelsContainer.topAnchor, offsetBy: -Theme.inputViewEdgeInset)
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
        let postButtonTitle: String
        let action: SPCommentFooterView.PostButtonAction
        if self.signupToPostButtonIsActive() {
            postButtonTitle = LocalizationManager.localizedString(key: "Sign Up to Post")
            action = presentAuth
        } else {
            postButtonTitle = LocalizationManager.localizedString(key: "Post")
            action = post
        }
        footerView.configurePostButton(title: postButtonTitle, action: action)
    }
    
    private func configureFooterView() {        
        footerView.layout {
            mainContainerBottomConstraint = $0.bottom.equal(to: scrollView.bottomAnchor)
            $0.trailing.equal(to: mainContainerView.trailingAnchor)
            $0.leading.equal(to: mainContainerView.leadingAnchor)
            $0.height.equal(to: Theme.footerViewHeight)
        }
    }
    
    private func configureCommentLabelsContainer() {
        commentLabelsContainer.delegate = self
        commentLabelsContainer.layout {
            $0.bottom.equal(to: footerView.topAnchor, offsetBy: -15.0)
            $0.leading.equal(to: topContainerView.leadingAnchor, offsetBy: 15.0)
            $0.trailing.equal(to: topContainerView.trailingAnchor, offsetBy: -15.0)
            commentLabelsContainerHeightConstraint = $0.height.greaterThanOrEqual(to: 56.0)
        }
    }
}

// MARK: - Extensions

extension SPCommentCreationViewController: KeyboardHandable {
    
    func keyboardWillShow(_ notification: Notification) {
        guard
            let expandedKeyboardHeight = notification.keyboardSize?.height,
            let animationDuration = notification.keyboardAnimationDuration
            else { return }
        let bottomPadding: CGFloat
        if #available(iOS 11.0, *) {
            bottomPadding = UIApplication.shared.windows[0].safeAreaInsets.bottom
        } else {
            bottomPadding = 0
        }
        updateBottomConstraint(constant: expandedKeyboardHeight - bottomPadding,
                               animationDuration: animationDuration)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        guard let animationDuration = notification.keyboardAnimationDuration else { return }
        updateBottomConstraint(constant: 0 , animationDuration: animationDuration)
    }
    
    private func updateBottomConstraint(constant: CGFloat, animationDuration: Double) {
        
        Logger.verbose("Current constraints is \(mainContainerBottomConstraint!.constant)")
        // set bottom margin according to orientations
        if !UIDevice.current.isPortrait() {
            // landscape - keep content behind keyboard and scroll to selected textView
            mainContainerBottomConstraint?.constant = 0
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: constant, right: 0)
            Logger.verbose("Updating constraints to \(0)")
            setScrollView(
                toView: usernameView.isSelected ? usernameView : textInputViewContainer,
                toTop: constant == 0)
        } else {
            // portrait - push content on top of keyboard
            mainContainerBottomConstraint?.constant = -constant
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            Logger.verbose("Updating constraints to \(-constant)")
            scrollToTop()
        }

        UIView.animate(
            withDuration: animationDuration,
            animations: {
                self.view.layoutIfNeeded()
            })
    }
    
    // scroll to given view (or to top if toTop is true)
    private func setScrollView(toView: UIView, toTop: Bool) {
        if toTop {
            scrollToTop()
        } else {
            scrollToView(toView: toView)
        }
    }
    
    // Scroll to a specific view so that it's top is at the top our scrollview
    private func scrollToView(toView:UIView) {
        if let origin = toView.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(toView.frame.origin, to: scrollView)
            scrollView.setContentOffset(CGPoint(x: 0, y: childStartPoint.y - Theme.mainOffset), animated: true)
        }
    }
    private func scrollToTop() {
        let scrollPoint = CGPoint.init(x:0, y: 0)
        self.scrollView.setContentOffset(scrollPoint, animated: true)
    }
}

extension SPCommentCreationViewController: SPTextInputViewDelegate {

    func tooLongTextWasPassed() {
        // handle too long text passing
    }
    
    func input(_ view: SPTextInputView, didChange text: String) {
        if view === textInputViewContainer {
            model.updateCommentText(text)
        } else if showsUsernameInput, view === usernameView {
            SPUserSessionHolder.update(displayName: text)
        }

        self.updatePostButtonEnabledState()
    }
}

extension SPCommentCreationViewController: AuthenticationViewDelegate {
    func authenticationStarted() {
        if (isValidInput()) {
            showLoader()
        }
    }
}

extension SPCommentCreationViewController: SPCommentLabelsContainerViewDelegate {
    func didSelectionChanged() {
        self.updatePostButtonEnabledState()
    }
}

extension SPCommentCreationViewController: SPCommentCreationNewHeaderViewDelegate {
    func customizeHeaderTitle(textView: UITextView) {
        customUIDelegate?.customizeNavigationItemTitle(textView: textView)
    }
}

// MARK: - Theme

private enum Theme {
    static let mainOffset: CGFloat = 16.0
    static let inputViewEdgeInset: CGFloat = 25.0
    static let inputViewLeadingInset: CGFloat = 10.0
    static let footerViewHeight: CGFloat = 54.0
}
