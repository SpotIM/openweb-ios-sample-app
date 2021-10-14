//
//  SPBaseCommentCreationViewController.swift
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

class SPBaseCommentCreationViewController<T: SPBaseCommentCreationModel>: SPBaseViewController, AlertPresentable,
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
    let commentContentScrollView: BaseScrollView = .init()
    var textInputViewContainer: SPCommentTextInputView = .init(
        hasAvatar: SPUserSessionHolder.session.user?.registered ?? false
    )
    private let imagePreviewView: CommentImagePreview = .init()
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
    private var commentLabelsContainerBottomConstraint: NSLayoutConstraint?
    private var commentContentScrollViewBottomConstraint: NSLayoutConstraint?
    private var mainContainerBottomConstraint: NSLayoutConstraint?
    private var topContainerTopConstraint: NSLayoutConstraint?
    
    private var imagePicker: ImagePicker!
    
    private var shouldBeAutoPosted: Bool = true
    var showsUsernameInput: Bool {
        guard let config = SPConfigsDataSource.appConfig else { return true }
        let session = SPUserSessionHolder.session

        let shoudEnterName = config.initialization?.policyForceRegister == false && session.user?.registered == false
        let didEnterName = session.displayNameFrozen

        return shoudEnterName && !didEnterName
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
    
    deinit {
        unregisterFromKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupUserIconHandler()
        registerForKeyboardNotifications()
        
        // remove keyboard when tapping outside of textView
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        mainContainerView.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        mainContainerView.endEditing(true)
    }
    
    private func setupCommentLabelsContainer() {
        guard showCommentLabels == true, let sectionLabelsConfig = model?.sectionCommentLabelsConfig else {
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
        commentLabelsContainerBottomConstraint?.constant = 0
        commentContentScrollViewBottomConstraint?.constant = 0
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

    private func post() {
        view.endEditing(true)
        Logger.verbose("FirstComment: Post clicked")
        showLoader()
        if commentLabelsContainer.selectedLabelsIds.count > 0 {
            model?.updateCommentLabels(labelsIds: commentLabelsContainer.selectedLabelsIds)
        }
        model?.post()
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
        guard let model = self.model else { return false }
        var isValidInput = true
        
        // check user name input text
        if showsUsernameInput {
            if usernameView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? false {
                isValidInput = false
            }
        }
        
        if !model.isValidContent() {
            isValidInput = false
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

extension SPBaseCommentCreationViewController {
    
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
        mainContainerView.addSubviews(topContainerView, commentContentScrollView, commentLabelsContainer, footerView)
        topContainerView.addSubview(topContainerStack)
        
        configureMainContainer()
        configureTopContainerStack()
        configureTopContainer()
        configureUsernameView()
        configureContentScrollView()
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
    }
    
    private func configureContentScrollView() {
        commentContentScrollView.layout {
            $0.top.equal(to: topContainerView.bottomAnchor)
            $0.leading.equal(to: mainContainerView.leadingAnchor, offsetBy: Theme.inputViewLeadingInset)
            $0.trailing.equal(to: mainContainerView.trailingAnchor, offsetBy: -Theme.inputViewTrailingInset)
            commentContentScrollViewBottomConstraint = $0.bottom.equal(to: commentLabelsContainer.topAnchor, offsetBy: -15)
            $0.height.greaterThanOrEqual(to: 40.0)
        }
        
        commentContentScrollView.addSubviews(textInputViewContainer, imagePreviewView)
        self.configureInputContainerView()
        self.configureImagePreviewView()
    }
    
    private func configureInputContainerView() {
        textInputViewContainer.delegate = self
        textInputViewContainer.layout {
            $0.top.equal(to: commentContentScrollView.topAnchor, offsetBy: Theme.mainOffset)
            $0.bottom.equal(to: imagePreviewView.topAnchor, offsetBy: -Theme.mainOffset)
            $0.leading.equal(to: commentContentScrollView.layoutMarginsGuide.leadingAnchor)
            $0.trailing.equal(to: commentContentScrollView.layoutMarginsGuide.trailingAnchor)
        }
    }
    
    private func configureImagePreviewView() {
        imagePreviewView.layout {
            $0.bottom.equal(to: commentContentScrollView.bottomAnchor, offsetBy: -Theme.mainOffset)
            $0.leading.equal(to: commentContentScrollView.layoutMarginsGuide.leadingAnchor)
            $0.trailing.equal(to: commentContentScrollView.layoutMarginsGuide.trailingAnchor)
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
        self.imagePicker = ImagePicker(presentationController: self)
        footerView.setImagePicker(self.imagePicker)
        footerView.delegate = self
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
            commentLabelsContainerBottomConstraint = $0.bottom.equal(to: footerView.topAnchor, offsetBy: -15.0)
            $0.leading.equal(to: topContainerView.leadingAnchor, offsetBy: 15.0)
            $0.trailing.equal(to: topContainerView.trailingAnchor, offsetBy: -15.0)
            commentLabelsContainerHeightConstraint = $0.height.equal(to: 56.0)
        }
    }
    
    private func uploadImageToCloudinary(imageData: String) {
        model?.uploadImageToCloudinary(imageData: imageData) { isUploaded in
            self.updatePostButtonEnabledState()
        }
    }
}

// MARK: - Extensions

extension SPBaseCommentCreationViewController: KeyboardHandable {
    
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

extension SPBaseCommentCreationViewController: SPTextInputViewDelegate {

    func tooLongTextWasPassed() {
        // handle too long text passing
    }
    
    func input(_ view: SPTextInputView, didChange text: String) {
        if view === textInputViewContainer {
            model?.updateCommentText(text)
        } else if showsUsernameInput, view === usernameView {
            SPUserSessionHolder.update(displayName: text)
        }

        self.updatePostButtonEnabledState()
    }
}

extension SPBaseCommentCreationViewController: AuthenticationViewDelegate {
    func authenticationStarted() {
        if (isValidInput()) {
            showLoader()
        }
    }
}

extension SPBaseCommentCreationViewController: SPCommentLabelsContainerViewDelegate {
    func didSelectionChanged() {
        self.updatePostButtonEnabledState()
    }
}

extension SPBaseCommentCreationViewController: SPCommentCreationNewHeaderViewDelegate {
    func customizeHeaderTitle(textView: UITextView) {
        customUIDelegate?.customizeNavigationItemTitle(textView: textView)
    }
}

extension SPBaseCommentCreationViewController: SPCommentFooterViewDelegate {
    func imageSelected(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 1.0)?.base64EncodedString() else { return }
        imagePreviewView.image = image
        uploadImageToCloudinary(imageData: imageData)
    }
}

// MARK: - Theme

private enum Theme {
    static let mainOffset: CGFloat = 16.0
    static let inputViewEdgeInset: CGFloat = 25.0
    static let inputViewLeadingInset: CGFloat = 10.0
    static let inputViewTrailingInset: CGFloat = 10.0
    static let footerViewHeight: CGFloat = 54.0
}
