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
    func commentReplyDidEdit(with comment: SPComment)
    
}

class SPCommentCreationViewController: SPBaseViewController,
                                       OWAlertPresentable,
                                       OWLoaderPresentable,
                                       OWUserAuthFlowDelegateContainable,
                                       OWUserPresentable {
    fileprivate struct Metrics {
        static let identifier = "comment_reply_view_id"
        static let activityIndicatorIdentifier = "comment_reply_view_activity_indicator_id"
        static let closeButtonIdentifier = "comment_reply_view_close_button_id"
        static let commentingOnLabelIdentifier = "comment_reply_view_commenting_on_label_id"
        static let replyCounterFontSize = 13.0
        static let replyCounterTopBottomOffset = -10.0
        static let replyCounterTrailingOffset = -16.0
        static let replyCounterHeight = 24.0
    }
    weak var userAuthFlowDelegate: OWUserAuthFlowDelegate?
    weak var delegate: CommentReplyViewControllerDelegate?
    private var authHandler: OWAuthenticationHandler?
    private var model: SPCommentCreationModel

    let topContainerView: OWBaseView = .init()
    let topContainerStack: OWBaseStackView = .init()
    let commentContentScrollView: OWBaseScrollView = .init()
    var textInputViewContainer: SPCommentTextInputView = .init()
    private let imagePreviewView: OWCommentImagePreview = .init()
    lazy var usernameView: SPNameInputView = SPNameInputView()

    let activityIndicator: SPLoaderView = SPLoaderView()
    var showsUserAvatarInTextInput: Bool { !showsUsernameInput }
    
    private let mainContainerView: OWBaseView = .init()
    
    private let footerView: SPCommentFooterView = .init()
    
    private let replyCounter: Int
    private lazy var commentReplyCounterLabel: UILabel = {
        let txt = "0/\(replyCounter)"
        
        return txt
            .label
            .font(UIFont.preferred(style: .regular, of: Metrics.replyCounterFontSize))
            .textColor(OWColorPalette.shared.color(type: .foreground2Color, themeStyle: .light))
    }()
    
    private let scrollView: OWBaseScrollView = .init()
    private var commentLabelsContainer: SPCommentLabelsContainerView = .init()
    private var commentLabelsSection: String?
    private var sectionLabels: SPCommentLabelsSectionConfiguration?
    
    private var commentReplyCounterBottomConstraint: OWConstraint?
    private var commentLabelsContainerBottomConstraint: OWConstraint?
    private var commentContentScrollViewBottomConstraint: OWConstraint?
    private var mainContainerBottomConstraint: OWConstraint?
    
    private let closeButton: OWBaseButton = .init()
    
    private lazy var commentHeaderView = SPCommentReplyHeaderView()
    private lazy var commentNewHeaderView = SPCommentCreationNewHeaderView()
    private let commentingContainer: UIView = .init()
    private let commentingOnLabel: OWBaseLabel = .init()
    private lazy var articleView: OWArticleHeader = OWArticleHeader()
    
    private var imagePicker: OWImagePicker?
    
    private var shouldBeAutoPosted: Bool = true
    
    fileprivate let servicesProvider: OWSharedServicesProviding
    
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
    
    deinit {
        unregisterFromKeyboardNotifications()
    }
    
    init(customUIDelegate: OWCustomUIDelegate?, model: SPCommentCreationModel,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         replyCounter: Int) {
        self.model = model
        self.servicesProvider = servicesProvider
        self.replyCounter = replyCounter
        textInputViewContainer.configureAvatarViewModel(with: model.avatarViewVM)
        super.init(customUIDelegate: customUIDelegate)
        self.updateModelData()
        articleView.configure(with: model.articleHeaderVM)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupUserIconHandler()
        registerForKeyboardNotifications()
        
        // remove keyboard when tapping outside of textView
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        mainContainerView.addGestureRecognizer(tap)
        
        if model.isCommentAReply() == false {
            topContainerView.bringSubviewToFront(closeButton)
        }
        usernameView.configureAvatarViewModel(with: model.avatarViewVM)
        applyAccessibility()
    }
    
    private func applyAccessibility() {
        self.view.accessibilityIdentifier = Metrics.identifier
        activityIndicator.accessibilityIdentifier = Metrics.activityIndicatorIdentifier
        closeButton.accessibilityIdentifier = Metrics.closeButtonIdentifier
        commentingOnLabel.accessibilityIdentifier = Metrics.commentingOnLabelIdentifier
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
        commentLabelsContainer.setLabelsContainer(labels: commentLabels,
                                                  guidelineText: sectionLabelsConfig.guidelineText, maxLabels: sectionLabelsConfig.maxSelected)
        commentLabelsContainer.setSelectedLabels(selectedLabelIdsInEditedComment: self.model.dataModel.editModel?.commentLabelIds)
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
    
    private func setupCommentReplyCounter() {
        if let shouldShow = SPConfigsDataSource.appConfig?.mobileSdk.shouldShowCommentCounter, !shouldShow {
            hideCommentReplyCounter()
        }
    }
    
    private func hideCommentReplyCounter() {
        commentReplyCounterLabel.isHidden = true
        commentReplyCounterBottomConstraint?.update(offset: 0)
        commentReplyCounterLabel.OWSnp.updateConstraints { make in
            make.height.equalTo(0)
        }
        
    }
    
    private func hideCommentLabelsContainer() {
        commentLabelsContainer.isHidden = true
        commentLabelsContainerBottomConstraint?.update(offset: 0)
        commentContentScrollViewBottomConstraint?.update(offset: 0)
        commentLabelsContainer.OWSnp.updateConstraints { make in
            make.height.equalTo(0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updatePostButton()
        setupCommentReplyCounter()
        setupCommentLabelsContainer()
        setFooterViewContentButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // delay added for keyboard not to appear earlier than the screen
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            guard !self.imagePreviewView.isUploadingImage else { return }
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
        servicesProvider.logger().log(level: .verbose, "FirstComment: Dismissing creation view controller")
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .reveal
        transition.subtype = .fromBottom
        navigationController?.view.layer.add(transition, forKey: nil)
        
        
        guard let navController = navigationController,
              let currentVCIndex = navController.viewControllers.firstIndex(where: { $0 == self }) else {
                  servicesProvider.logger().log(level: .medium, "Couldn't find the VC before the comment creation VC, recovering by popping the last VC in the navigation controller")
                  navigationController?.popViewController(animated: false) // Just pop the last VC
                  return
              }
        
        let indexOfPreviuosVS = currentVCIndex - 1
        let navigationVCs = navController.viewControllers
        
        guard indexOfPreviuosVS >= 0 else {
            servicesProvider.logger().log(level: .medium, "Couldn't find the VC before the comment creation VC, recovering by popping the last VC in the navigation controller")
            navController.popViewController(animated: false) // Just pop the last VC
            return
        }
        
        let previousVC = navigationVCs[indexOfPreviuosVS]
        servicesProvider.logger().log(level: .verbose, "Popping to the VC before comment creation VC")
        navController.popToViewController(previousVC, animated: false)
    }
    
    func userDidSignInHandler() -> OWAuthenticationHandler? {
        authHandler = OWAuthenticationHandler()
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
            
            if responseData.edited {
                self.delegate?.commentReplyDidEdit(with: responseData)
            } else {
                self.delegate?.commentReplyDidCreate(responseData)
                SPAnalyticsHolder.default.log(event: .createMessageSuccessfully, source: .conversation)
            }
            self.hideLoader()
            self.dismissController()
        }
        
        model.errorHandler = { [weak self] error in
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
        updateImageContainer()
        updateAvatar()
    }
    
    private func setupNewHeader() {
        guard commentNewHeaderView.superview == nil else {
            return
        }
        topContainerStack.insertArrangedSubview(commentNewHeaderView, at: 0)
        
        commentNewHeaderView.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        commentNewHeaderView.delegate = self
        commentNewHeaderView.configure()
        commentNewHeaderView.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        commentNewHeaderView.setupHeader(for: self.model.isInEditMode() ? HeaderMode.edit : HeaderMode.add)
    }
    
    private func setupHeader() {
        setupHeaderComponentsIfNeeded()
        if shouldDisplayArticleHeader(), #available(iOS 11.0, *) {
            topContainerStack.insertArrangedSubview(articleView, at: 1)

            articleView.OWSnp.makeConstraints { make in
                make.height.equalTo(85.0)
                make.width.equalToSuperview()
            }
            
            topContainerStack.setCustomSpacing(16, after: commentingOnLabel)
            commentingOnLabel.text = LocalizationManager.localizedString(key: "Commenting on")
        } else {
            let commentHeaderText = getHeaderTitleBasedOnUserFlow()
            commentingOnLabel.text = commentHeaderText
        }
    }
    
    private func getHeaderTitleBasedOnUserFlow() -> String {
        return self.model.isInEditMode() ?
        LocalizationManager.localizedString(key: "Edit a Comment") :
        LocalizationManager.localizedString(key: "Add a Comment")
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
        
        commentingContainer.OWSnp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(commentingOnLabel.frame.height + 41)
        }
        
        commentingOnLabel.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)

        }
        
        closeButton.setImage(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), for: .normal)
        closeButton.OWSnp.makeConstraints { make in
            make.centerY.equalTo(topContainerView.OWSnp.top).offset(35.0)
            make.trailing.equalToSuperview().offset(-5.0)
            make.size.equalTo(40.0)
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
            commentNewHeaderView.setupHeader(for: self.model.isInEditMode() ? HeaderMode.edit : HeaderMode.add)
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

        headerView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(shouldHideCommentText ? heightWithoutCommentText : heightWithCommentText)
            make.width.equalToSuperview()
        }

        updateTextInputContainer(with: .reply)
        updateImageContainer()
        updateAvatar()
    }


    func updateTextInputContainer(with type: SPCommentTextInputView.CommentType) {
        textInputViewContainer.configureCommentType(type, showAvatar: SPUserSessionHolder.session.user?.registered ?? false)
        textInputViewContainer.updateText(model.commentText)
    }
    
    func updateImageContainer() {
        guard let imageId = model.imageContent?.imageId else { return }
        let imageUrl = self.model.imageProvider.imageURL(with: imageId, size: nil)
        model.imageProvider.image(from: imageUrl,
                                       size: nil,
                                       completion:{ image, _ in
            self.imagePreviewView.image = image
        })
    }

    func updateAvatar() {
        model.fetchNavigationAvatar { [weak self] image, _ in
            guard
                let self = self,
                let image = image
                else { return }

            self.setAvatar(image: image)
        }
        if let user = SPUserSessionHolder.session.user {
            model.avatarViewVM.inputs.configureUser(user: user)
        }
        textInputViewContainer.setShowAvatar(showAvatar: SPUserSessionHolder.session.user?.registered ?? false)
    }

    private func setAvatar(image: UIImage) {
        self.updateUserIcon(image: image)
    }

    @objc
    private func showProfile() {
        showProfileActions(sender: userIcon)
    }

    private func post() {
        view.endEditing(true)
        servicesProvider.logger().log(level: .verbose, "FirstComment: Post clicked")

        showLoader()
        if commentLabelsContainer.selectedLabelsIds.count > 0 {
            model.updateCommentLabels(labelsIds: commentLabelsContainer.selectedLabelsIds)
        }
        model.post()
        SPAnalyticsHolder.default.log(event: .commentPostClicked, source: .conversation)
    }

    private func presentAuth() {
        view.endEditing(true)
        servicesProvider.logger().log(level: .verbose, "FirstComment: Signup to post clicked")
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
        
        // check user name input text
        if showsUsernameInput {
            if usernameView.text == nil || usernameView.text?.hasContent == false {
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

extension SPCommentCreationViewController {
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.OWSnp.makeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide)
            if #available(iOS 11.0, *) {
                make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.leading.trailing.bottom.equalTo(view)
            }
        }
        scrollView.addSubview(mainContainerView)
        mainContainerView.addSubviews(topContainerView, commentContentScrollView, commentReplyCounterLabel, commentLabelsContainer, footerView)
        topContainerView.addSubview(topContainerStack)
        
        configureMainContainer()
        configureTopContainerStack()
        configureTopContainer()
        configureUsernameView()
        configureContentScrollView()
        configureFooterView()
        configureCommentLabelsContainer()
        configureCommentReplyCounter()
        updateColorsAccordingToStyle()
    }
    
    private func configureMainContainer() {
        mainContainerView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.width.equalToSuperview()
        }
    }

    private func configureUsernameView() {
        guard showsUsernameInput else { return }

        topContainerStack.addArrangedSubview(usernameView)
        usernameView.delegate = self
        usernameView.OWSnp.makeConstraints { make in
            make.height.equalTo(78)
            make.width.equalToSuperview()
        }
        // put existing nickname if exist
        if (SPUserSessionHolder.session.displayNameFrozen) {
            usernameView.text = SPUserSessionHolder.session.user?.displayName
            usernameView.setTextAccess(isEditable: false)
        }
    }
    
    private func configureContentScrollView() {
        commentContentScrollView.OWSnp.makeConstraints { make in
            make.top.equalTo(topContainerView.OWSnp.bottom)
            make.leading.equalToSuperview().offset(Theme.inputViewHorizontalOffset)
            make.trailing.equalToSuperview().offset(-Theme.inputViewHorizontalOffset)
            commentContentScrollViewBottomConstraint = make.bottom.equalTo(commentReplyCounterLabel.OWSnp.top).offset(Metrics.replyCounterTopBottomOffset).constraint
            make.height.greaterThanOrEqualTo(40.0)

        }
        
        commentContentScrollView.addSubviews(textInputViewContainer, imagePreviewView)
        self.configureInputContainerView()
        self.configureImagePreviewView()
    }
    
    private func configureInputContainerView() {
        textInputViewContainer.delegate = self
        textInputViewContainer.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Theme.mainOffset)
            make.bottom.equalTo(imagePreviewView.OWSnp.top).offset(-Theme.mainOffset)
            make.leading.trailing.equalTo(commentContentScrollView.layoutMarginsGuide)
        }
    }
    
    private func configureImagePreviewView() {
        imagePreviewView.delegate = self
        imagePreviewView.OWSnp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-Theme.mainOffset)
            make.leading.trailing.equalTo(commentContentScrollView.layoutMarginsGuide)
        }
    }
    
    private func configureTopContainer() {
        topContainerView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        topContainerView.OWSnp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.greaterThanOrEqualTo(40.0)
        }
    }

    private func configureTopContainerStack() {
        topContainerStack.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        topContainerStack.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
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
        } else if self.model.isInEditMode() {
            postButtonTitle = LocalizationManager.localizedString(key: "Edit")
            action = post
        } else {
            postButtonTitle = LocalizationManager.localizedString(key: "Post")
            action = post
        }
        footerView.configurePostButton(title: postButtonTitle, action: action)
    }
    
    private func configureFooterView() {
        footerView.delegate = self
        footerView.OWSnp.makeConstraints { make in
            mainContainerBottomConstraint = make.bottom.equalTo(scrollView).constraint
            make.trailing.leading.equalToSuperview()
            make.height.equalTo(Theme.footerViewHeight)
        }
    }
    
    private func configureCommentReplyCounter() {
        commentReplyCounterLabel.OWSnp.makeConstraints { make in
            commentReplyCounterBottomConstraint = make.bottom.equalTo(commentLabelsContainer.OWSnp.top).offset(Metrics.replyCounterTopBottomOffset).constraint
            make.trailing.equalTo(topContainerView).offset(Metrics.replyCounterTrailingOffset)
            make.leading.greaterThanOrEqualToSuperview().offset(-Metrics.replyCounterTrailingOffset)
            make.height.equalTo(Metrics.replyCounterHeight)
        }
    }
    
    private func configureCommentLabelsContainer() {
        commentLabelsContainer.delegate = self
        commentLabelsContainer.OWSnp.makeConstraints { make in
            commentLabelsContainerBottomConstraint = make.bottom.equalTo(footerView.OWSnp.top).offset(-15.0).constraint
            make.leading.equalTo(topContainerView).offset(15.0)
            make.trailing.equalTo(topContainerView).offset(-15.0)
            make.height.equalTo(56.0)

        }
    }
    
    private func setFooterViewContentButtons() {
        var contentButtonTypes: [SPCommentFooterContentButtonType] = []
        
        if model.shouldDisplayImageUploadButton() {
            self.setImagePicker()
            contentButtonTypes.append(.image)
        }
        
        footerView.setContentButtonTypes(contentButtonTypes)
    }
    
    private func setImagePicker() {
        self.imagePicker = OWImagePicker(presentationController: self)
        self.imagePicker?.delegate = self
    }
    
    private func uploadImageToCloudinary(imageData: String) {
        imagePreviewView.isUploadingImage = true
        self.dismissKeyboard()
        model.uploadImageToCloudinary(imageData: imageData) { isUploaded in
            self.imagePreviewView.isUploadingImage = false
            self.updatePostButtonEnabledState()
            if !isUploaded {
                self.imagePreviewView.image = nil
            }
        }
    }
    
    private func setImage(image: UIImage?) {
        // clean previous image in the model
        model.removeImage()
        self.updatePostButtonEnabledState()
        if let image = image,
           let imageData = image.jpegData(compressionQuality: 1.0)?.base64EncodedString() {
            imagePreviewView.image = image
            uploadImageToCloudinary(imageData: imageData)
        } else {
            self.imagePreviewView.image = nil
            self.imagePreviewView.isUploadingImage = false
        }
    }
}

// MARK: - Extensions

extension SPCommentCreationViewController: OWKeyboardHandable {
    
    func keyboardWillShow(_ notification: Notification) {
        guard
            let expandedKeyboardHeight = notification.keyboardSize?.height,
            let animationDuration = notification.keyboardAnimationDuration
            else { return }
        let bottomPadding: CGFloat
        if #available(iOS 11.0, *) {
            bottomPadding = tabBarController?.tabBar.frame.height ?? UIApplication.shared.windows[0].safeAreaInsets.bottom 
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
        
        // set bottom margin according to orientations
        if !UIDevice.current.isPortrait() {
            // landscape - keep content behind keyboard and scroll to selected textView
            mainContainerBottomConstraint?.update(offset: 0)
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: constant, right: 0)
            servicesProvider.logger().log(level: .verbose, "Updating \"mainContainerBottomConstraint\" constraints to \(0)")

            setScrollView(
                toView: usernameView.isSelected ? usernameView : textInputViewContainer,
                toTop: constant == 0)
        } else {
            // portrait - push content on top of keyboard
            mainContainerBottomConstraint?.update(offset: -constant)
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            servicesProvider.logger().log(level: .verbose, "Updating \"mainContainerBottomConstraint\" constraints to \(-constant)")
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
    
    func validateInputLenght(_ lenght: Int) -> Bool {
        return lenght <= replyCounter
    }
    
    func input(_ view: SPTextInputView, didChange text: String) {
        if view === textInputViewContainer {
            commentReplyCounterLabel.text = "\(text.count)/\(replyCounter)"
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
    func customizeHeaderTitle(label: UILabel) {
        customUIDelegate?.customizeView(.navigationItemTitle(label: label), source: .createComment)
    }
}

extension SPCommentCreationViewController: SPCommentFooterViewDelegate {
    func clickedOnAddContentButton(type: SPCommentFooterContentButtonType) {
        self.imagePicker?.present(from: self.view)
    }
    
    func updatePostCommentButtonCustomUI(button: OWBaseButton) {
        customUIDelegate?.customizeView(.commentCreationActionButton(button: button), source: .createComment)
    }
}

extension SPCommentCreationViewController: OWCommentImagePreviewDelegate {
    func clickedOnRemoveButton() {
        self.setImage(image: nil)
    }
}

extension SPCommentCreationViewController: OWImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard image != nil else { return }
        self.setImage(image: image)
    }
}

// MARK: - Theme

private enum Theme {
    static let mainOffset: CGFloat = 16.0
    static let inputViewEdgeInset: CGFloat = 25.0
    static let inputViewHorizontalOffset: CGFloat = 10.0
    static let footerViewHeight: CGFloat = 54.0
}
