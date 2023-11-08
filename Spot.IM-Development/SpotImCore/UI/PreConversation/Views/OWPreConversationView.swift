//
//  OWPreConversationView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 29/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWPreConversationView: UIView, OWThemeStyleInjectorProtocol, OWToastNotificationDisplayerProtocol {
    internal struct Metrics {
        static let commentingCTATopPadding: CGFloat = 20
        static let commentingCTAHeight: CGFloat = 72
        static let horizontalOffset: CGFloat = 16.0
        static let btnFullConversationCornerRadius: CGFloat = 6
        static let btnFullConversationTextPadding: CGFloat = 12
        static let btnFullConversationTopPadding: CGFloat = 24
        static let bottomPadding: CGFloat = 24
        static let compactModePadding: CGFloat = 16
        static let communityQuestionTopPadding: CGFloat = 8
        static let separatorHeight: CGFloat = 1.0
        static let summaryTopPadding: CGFloat = 24
        static let footerTopPadding: CGFloat = 24
        static let compactSummaryTopPadding: CGFloat = 16
        static let compactCornerRadius: CGFloat = 8
        static let tableDeviderTopPadding: CGFloat = 64
        static let communityQuestionDeviderPadding: CGFloat = 12
        static let readOnlyTopPadding: CGFloat = 40
        static let tableViewAnimationDuration: Double = 0.25
        static let compactContentTopPedding: CGFloat = 8
        static let tableViewTopPedding: CGFloat = 16
        static let realtimeIndicationAnimationViewHeight: CGFloat = 150
        static let tableViewHeightAnimationDuration: CGFloat = 0.2
        static let loginPromptTopPadding: CGFloat = 20
        static let loginPromptDividerTopPadding: CGFloat = 16

        static let moreCommentsButtonIdentifier = "pre_conversation_more_comments_button_id"
    }
    // TODO: fileprivate lazy var adBannerView: SPAdBannerView

    var toastView: OWToastView? = nil
    var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()

    fileprivate lazy var preConversationSummary: OWPreConversationSummaryView = {
        return OWPreConversationSummaryView(viewModel: self.viewModel.outputs.preConversationSummaryVM)
    }()

    fileprivate lazy var loginPromptView: OWLoginPromptView = {
        return OWLoginPromptView(with: self.viewModel.outputs.loginPromptVM)
    }()

    fileprivate lazy var loginPromptBottomDivider: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor3, themeStyle: .light))
    }()

    fileprivate lazy var communityGuidelinesView: OWCommunityGuidelinesView = {
        return OWCommunityGuidelinesView(with: self.viewModel.outputs.communityGuidelinesViewModel)
    }()

    fileprivate lazy var communityQuestionBottomDevider: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor3, themeStyle: .light))
    }()

    fileprivate lazy var communityQuestionView: OWCommunityQuestionView = {
        return OWCommunityQuestionView(with: self.viewModel.outputs.communityQuestionViewModel)
    }()

    fileprivate lazy var realtimeIndicationAnimationView: OWRealtimeIndicationAnimationView = {
        return OWRealtimeIndicationAnimationView(viewModel: self.viewModel.outputs.realtimeIndicationAnimationViewModel)
    }()

    fileprivate lazy var commentingCTAView: OWCommentingCTAView = {
        return OWCommentingCTAView(with: self.viewModel.outputs.commentingCTAViewModel)
            .wrapContent()
    }()

    fileprivate var commentingCTAZeroHeightConstraint: OWConstraint? = nil

    fileprivate lazy var errorStateView: OWErrorStateView = {
        return OWErrorStateView(with: viewModel.outputs.errorStateViewModel)
    }()
    fileprivate var errorStateZeroHeightConstraint: OWConstraint? = nil

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
            .enforceSemanticAttribute()
            .backgroundColor(UIColor.clear)
            .separatorStyle(.none)
        tableView.isScrollEnabled = false
        tableView.allowsSelection = true
        // Register cells
        for option in OWPreConversationCellOption.allCases {
            tableView.register(cellClass: option.cellClass)
        }

        return tableView
    }()

    fileprivate lazy var tableBottomDivider: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor2, themeStyle: .light))
    }()

    fileprivate lazy var btnCTAConversation: UIButton = {
        return UIButton()
            .backgroundColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
            .textColor(.white)
            .corner(radius: Metrics.btnFullConversationCornerRadius)
            .withPadding(Metrics.btnFullConversationTextPadding)
            .font(OWFontBook.shared.font(typography: .bodyContext))
    }()

    fileprivate var ctaZeroHeightConstraint: OWConstraint? = nil

    fileprivate lazy var footerTopDevider: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor2, themeStyle: .light))
    }()

    fileprivate lazy var footerView: OWPreConversationFooterView = {
        return OWPreConversationFooterView(with: self.viewModel.outputs.footerViewViewModel)
    }()

    fileprivate lazy var preConversationDataSource: OWRxTableViewSectionedAnimatedDataSource<PreConversationDataSourceModel> = {
        let dataSource = OWRxTableViewSectionedAnimatedDataSource<PreConversationDataSourceModel>(decideViewTransition: { [weak self] _, _, _ in
            guard let self = self else { return .reload }
            return self.viewModel.outputs.dataSourceTransition
        }, configureCell: { [weak self] _, tableView, indexPath, item -> UITableViewCell in
            guard let self = self else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCellAndReigsterIfNeeded(cellClass: item.cellClass, for: indexPath)
            cell.configure(with: item.viewModel)

            return cell
        })

        let animationConfiguration = OWAnimationConfiguration(insertAnimation: .top, reloadAnimation: .none, deleteAnimation: .fade)
        dataSource.animationConfiguration = animationConfiguration
        return dataSource
    }()

    fileprivate lazy var compactContentView: OWPreConversationCompactContentView = {
        return OWPreConversationCompactContentView(viewModel: viewModel.outputs.compactCommentVM)
    }()

    fileprivate lazy var compactTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        if (viewModel.outputs.shouldAddContentTapRecognizer) {
            self.addGestureRecognizer(tap)
            self.isUserInteractionEnabled = true
        }
        return tap
    }()

    private var tableViewHeightConstraint: OWConstraint?
    private var commentingCTAHeightConstraint: OWConstraint?
    fileprivate let viewModel: OWPreConversationViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWPreConversationViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        viewModel.inputs.viewInitialized.onNext()
        setupViews()
        setupObservers()
        applyAccessibility()
    }
}

fileprivate extension OWPreConversationView {
    func applyAccessibility() {
        self.accessibilityIdentifier = viewModel.outputs.viewAccessibilityIdentifier
        btnCTAConversation.accessibilityIdentifier = Metrics.moreCommentsButtonIdentifier
    }

    func setupViews() {
        self.enforceSemanticAttribute()
        self.useAsThemeStyleInjector()

        self.addSubviews(preConversationSummary)
        preConversationSummary.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.compactSummaryTopPadding)
            make.leading.trailing.equalToSuperview()
        }

        if (viewModel.outputs.shouldShowComapactView) {
            self.addSubview(compactContentView)
            compactContentView.OWSnp.makeConstraints { make in
                make.top.equalTo(preConversationSummary.OWSnp.bottom).offset(Metrics.compactContentTopPedding)
                make.leading.equalToSuperview().offset(Metrics.compactModePadding)
                make.trailing.equalToSuperview().offset(-Metrics.compactModePadding)
                make.bottom.equalToSuperview().offset(-Metrics.compactModePadding)
            }

            self.addCornerRadius(Metrics.compactCornerRadius)
            return
        }

        // TODO: Adjust UI correctly according to the style
        // Each component should be added separately
        // DO NOT pass style in the VM, use `shouldShowCommunityGuidelinesAndQuestion` and etc.

        self.addSubview(loginPromptView)
        loginPromptView.OWSnp.makeConstraints { make in
            make.top.equalTo(preConversationSummary.OWSnp.bottom).offset(Metrics.loginPromptTopPadding)
            make.leading.equalToSuperview().inset(Metrics.horizontalOffset)
            make.trailing.lessThanOrEqualToSuperview().inset(Metrics.horizontalOffset)
        }

        self.addSubview(loginPromptBottomDivider)
        loginPromptBottomDivider.OWSnp.makeConstraints { make in
            make.top.equalTo(loginPromptView.OWSnp.bottom).offset(Metrics.loginPromptDividerTopPadding)
            make.height.equalTo(Metrics.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
        }

        self.addSubview(communityQuestionView)
        communityQuestionView.OWSnp.makeConstraints { make in
            make.top.equalTo(loginPromptBottomDivider.OWSnp.bottom).offset(Metrics.communityQuestionTopPadding)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
        }

        self.addSubview(communityQuestionBottomDevider)
        communityQuestionBottomDevider.OWSnp.makeConstraints { make in
            make.top.equalTo(communityQuestionView.OWSnp.bottom).offset(Metrics.communityQuestionDeviderPadding)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
            make.height.equalTo(Metrics.separatorHeight)
        }

        self.addSubview(communityGuidelinesView)
        communityGuidelinesView.OWSnp.makeConstraints { make in
            make.top.equalTo(communityQuestionBottomDevider.OWSnp.bottom).offset(Metrics.communityQuestionDeviderPadding)
            make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(Metrics.horizontalOffset)
        }

        self.addSubview(commentingCTAView)
        commentingCTAView.OWSnp.makeConstraints { make in
            make.top.equalTo(communityGuidelinesView.OWSnp.bottom).offset(Metrics.commentingCTATopPadding)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
            commentingCTAHeightConstraint = make.height.equalTo(0).constraint
        }

        self.addSubview(errorStateView)
        errorStateView.OWSnp.makeConstraints { make in
            make.top.equalTo(commentingCTAView.OWSnp.bottom).offset(Metrics.tableViewTopPedding)
            make.leading.trailing.equalToSuperview()
            errorStateZeroHeightConstraint = make.height.equalTo(0).constraint
        }
        errorStateZeroHeightConstraint?.isActive = true

        self.addSubview(tableView)
        tableView.OWSnp.makeConstraints { make in
            make.top.equalTo(errorStateView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
            tableViewHeightConstraint = make.height.equalTo(0).constraint
        }

        self.addSubview(tableBottomDivider)
        tableBottomDivider.OWSnp.makeConstraints { make in
            make.height.equalTo(Metrics.separatorHeight)
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(tableView.OWSnp.bottom)
        }

        self.addSubview(self.realtimeIndicationAnimationView)
        realtimeIndicationAnimationView.OWSnp.makeConstraints { make in
            make.bottom.equalTo(self.tableView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.realtimeIndicationAnimationViewHeight)
        }

        self.addSubview(btnCTAConversation)
        btnCTAConversation.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
            make.top.equalTo(tableBottomDivider.OWSnp.bottom).offset(Metrics.btnFullConversationTopPadding)
            ctaZeroHeightConstraint = make.height.equalTo(0).constraint
        }

        self.addSubview(footerTopDevider)
        footerTopDevider.OWSnp.makeConstraints { make in
            make.height.equalTo(Metrics.separatorHeight)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
            make.top.equalTo(btnCTAConversation.OWSnp.bottom).offset(Metrics.btnFullConversationTopPadding)
        }

        self.addSubview(footerView)
        footerView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
            make.top.equalTo(footerTopDevider.OWSnp.bottom).offset(Metrics.footerTopPadding)
            make.bottom.equalToSuperview().offset(-Metrics.bottomPadding)
        }
    }

    // swiftlint:disable function_body_length
    func setupObservers() {
        compactTapGesture.rx.event
            .voidify()
            .bind(to: viewModel.inputs.fullConversationTap)
            .disposed(by: disposeBag)

        viewModel.outputs.displayToast
            .subscribe(onNext: { [weak self] (data, action) in
                self?.displayToast(requiredData: data.data, actionCompletion: action)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.hideToast
            .subscribe(onNext: { [weak self] in
                self?.dismissToast()
            })
            .disposed(by: disposeBag)

        setupToastObservers(disposeBag: disposeBag)


        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: self.viewModel.outputs.isCompactBackground ? .backgroundColor5 : .backgroundColor2, themeStyle: currentStyle)
                self.tableBottomDivider.backgroundColor = OWColorPalette.shared.color(type: .separatorColor2, themeStyle: currentStyle)
                self.footerTopDevider.backgroundColor = OWColorPalette.shared.color(type: .separatorColor2, themeStyle: currentStyle)
                self.communityQuestionBottomDevider.backgroundColor = OWColorPalette.shared.color(type: .separatorColor3, themeStyle: currentStyle)
                self.loginPromptBottomDivider.backgroundColor = OWColorPalette.shared.color(type: .separatorColor3, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        viewModel.outputs
            .summaryTopPadding
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] padding in
                guard let self = self else { return }
                self.preConversationSummary.OWSnp.updateConstraints { make in
                    make.top.equalToSuperview().offset(padding)
                }
            })
            .disposed(by: disposeBag)

        guard !viewModel.outputs.shouldShowComapactView else { return }

        let shouldShowLoginPrompt = viewModel
            .outputs.loginPromptVM
            .outputs.shouldShowView

        shouldShowLoginPrompt
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldShow in
                guard let self = self else { return }
                self.loginPromptView.OWSnp.updateConstraints { make in
                    make.top.equalTo(self.preConversationSummary.OWSnp.bottom).offset(shouldShow ? Metrics.loginPromptTopPadding : 0)
                }

                self.loginPromptBottomDivider.OWSnp.updateConstraints { make in
                    make.top.equalTo(self.loginPromptView.OWSnp.bottom).offset(shouldShow ? Metrics.loginPromptDividerTopPadding : 0)
                    make.height.equalTo(shouldShow ? Metrics.separatorHeight : 0)
                }
                self.loginPromptBottomDivider.isHidden(!shouldShow)
            })
            .disposed(by: disposeBag)

        let shouldShowQuestion = viewModel
            .outputs.communityQuestionViewModel
            .outputs.shouldShowView

        let shouldShowGuidelines = viewModel
            .outputs.communityGuidelinesViewModel
            .outputs.shouldShowView

        Observable.combineLatest(shouldShowQuestion, shouldShowGuidelines)
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] (shouldShowQuestion, shouldShowGuidelines) in
                // Update Question and Guidelines constraints
                guard let self = self else { return }
                self.communityQuestionView.OWSnp.updateConstraints { make in
                    make.top.equalTo(self.loginPromptBottomDivider.OWSnp.bottom).offset(shouldShowQuestion ? Metrics.communityQuestionTopPadding : 0)
                }
                self.communityGuidelinesView.OWSnp.updateConstraints { make in
                    make.top.equalTo(self.communityQuestionBottomDevider.OWSnp.bottom).offset(shouldShowGuidelines ? Metrics.communityQuestionDeviderPadding : 0)
                }
            })
            .flatMap { (shouldShowQuestion, shouldShowGuidelines) -> Observable<Bool> in
                // Return devider Obsevable
                return Observable.just(shouldShowQuestion && shouldShowGuidelines)
            }
            .do(onNext: { [weak self] shouldShowDevider in
                // Update devider constraints
                guard let self = self else { return }
                self.communityQuestionBottomDevider.OWSnp.updateConstraints { make in
                    make.top.equalTo(self.communityQuestionView.OWSnp.bottom).offset(shouldShowDevider ? Metrics.communityQuestionDeviderPadding : 0)
                    make.height.equalTo(shouldShowDevider ? Metrics.separatorHeight : 0)
                }
                self.communityQuestionBottomDevider.isHidden = !shouldShowDevider
            })
            .subscribe()
            .disposed(by: disposeBag)

        viewModel.outputs.conversationCTAButtonTitle
            .bind(to: btnCTAConversation.rx.title())
            .disposed(by: disposeBag)

        viewModel.outputs.preConversationDataSourceSections
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(dataSource: preConversationDataSource))
            .disposed(by: disposeBag)

        viewModel.outputs.performTableViewAnimation
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    UIView.animate(withDuration: Metrics.tableViewAnimationDuration) {
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                    }
                })
                .disposed(by: disposeBag)

        btnCTAConversation.rx.tap
            .voidify()
            .bind(to: viewModel.inputs.fullConversationCTATap)
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowCommentingCTAView
            .map { !$0 }
            .bind(to: commentingCTAView.rx.isHidden)
            .disposed(by: disposeBag)

        if let constraint = commentingCTAHeightConstraint {
            viewModel.outputs.shouldShowCommentingCTAView
                .map { !$0 }
                .bind(to: constraint.rx.isActive)
                .disposed(by: disposeBag)
        }

        viewModel.outputs.shouldShowCommentingCTAView
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldShow in
                guard let self = self else { return }
                self.commentingCTAView.OWSnp.updateConstraints { make in
                    make.top.equalTo(self.communityGuidelinesView.OWSnp.bottom).offset(shouldShow ? Metrics.commentingCTATopPadding : 0)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowErrorLoadingComments
            .map { !$0 }
            .bind(to: errorStateView.rx.isHidden)
            .disposed(by: disposeBag)

        if let constraint = errorStateZeroHeightConstraint {
            viewModel.outputs.shouldShowErrorLoadingComments
                .map { !$0 }
                .bind(to: constraint.rx.isActive)
                .disposed(by: disposeBag)
        }

        viewModel.outputs.shouldShowComments
            .map { !$0 }
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)

        Observable.combineLatest(viewModel.outputs.shouldShowCTAButton,
                                 viewModel.outputs.shouldShowComments) { shouldShowCTAButton, shouldShowComments in
            guard shouldShowCTAButton else { return true }
            return !shouldShowComments
        }
            .bind(to: tableBottomDivider.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowCTAButton
            .map { !$0 }
            .bind(to: btnCTAConversation.rx.isHidden)
            .disposed(by: disposeBag)

        if let ctaZeroHeightConstraint = ctaZeroHeightConstraint {
            viewModel.outputs.shouldShowCTAButton
                .map { !$0 }
                .bind(to: ctaZeroHeightConstraint.rx.isActive)
                .disposed(by: disposeBag)
        }

        viewModel.outputs.shouldShowCTAButton
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isVisible in
                guard let self = self else { return }
                self.btnCTAConversation.OWSnp.updateConstraints { make in
                    make.top.equalTo(self.tableBottomDivider.OWSnp.bottom).offset(isVisible ? Metrics.btnFullConversationTopPadding : 0)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowFooter
            .map { !$0 }
            .bind(to: footerView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowFooter
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isVisible in
                guard let self = self else { return }
                self.footerView.OWSnp.updateConstraints { make in
                    make.top.equalTo(self.footerTopDevider.OWSnp.bottom).offset(isVisible ? Metrics.footerTopPadding : 0)
                    make.bottom.equalToSuperview().offset(isVisible ? -Metrics.bottomPadding : 0)
                }
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(OWSharedServicesProvider.shared.themeStyleService().style, OWColorPalette.shared.colorDriver)
            .subscribe(onNext: { [weak self] (style, colorMapper) -> Void in
                guard let self = self else { return }

                if let owBrandColor = colorMapper[.brandColor] {
                    let brandColor = owBrandColor.color(forThemeStyle: style)
                    self.btnCTAConversation.backgroundColor = brandColor
                }
            })
            .disposed(by: disposeBag)

        let tableViewContentSizeObservable = tableView.rx.observe(CGSize.self, #keyPath(UITableView.contentSize))
            .unwrap()

        let isRealtimeIndicationShownObservable = viewModel.outputs.realtimeIndicationAnimationViewModel
            .outputs.shouldShow

        let tableViewHeightChangeObservable = Observable.combineLatest(tableViewContentSizeObservable,
                                                                       isRealtimeIndicationShownObservable,
                                                                       viewModel.outputs.shouldShowComments) { size, realtimeIsShown, isCommentsVisible -> (CGFloat?, Bool) in

            let extraHeight = realtimeIsShown ? Metrics.tableDeviderTopPadding : 0
            guard isCommentsVisible == true else { return (extraHeight, realtimeIsShown) }

            let height = size.height + extraHeight

            return (height, realtimeIsShown)
        }

        tableViewHeightChangeObservable
            .subscribe(onNext: { [weak self] result in
                guard let self = self,
                      let height = result.0 else { return }
                let realtimeIsShown = result.1

                if realtimeIsShown {
                    // Only when we shown the realtime indicator we should animate the table view height change
                    self.tableViewHeightConstraint?.update(offset: height)
                    UIView.animate(withDuration: Metrics.tableViewHeightAnimationDuration) {
                        self.layoutIfNeeded()
                    }
                } else {
                    self.tableView.OWSnp.updateConstraints { make in
                        make.height.equalTo(height)
                    }
                }
            })
            .disposed(by: disposeBag)

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.inputs.fullConversationTap.onNext()
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.btnCTAConversation.titleLabel?.font = OWFontBook.shared.font(typography: .bodyContext)
            })
            .disposed(by: disposeBag)
    }
    // swiftlint:enable function_body_length
}
