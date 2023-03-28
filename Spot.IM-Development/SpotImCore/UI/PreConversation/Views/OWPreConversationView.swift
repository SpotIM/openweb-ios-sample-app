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

class OWPreConversationView: UIView, OWThemeStyleInjectorProtocol {
    internal struct Metrics {
        static let commentCreationTopPadding: CGFloat = 28
        static let commentCreationBottomPadding: CGFloat = 24
        static let horizontalOffset: CGFloat = 16.0
        static let btnFullConversationCornerRadius: CGFloat = 6
        static let btnFullConversationFontSize: CGFloat = 15
        static let btnFullConversationTextPadding: CGFloat = 12
        static let btnFullConversationTopPadding: CGFloat = 24
        static let bottomPadding: CGFloat = 24
        static let compactModePadding: CGFloat = 16
        static let communityQuestionTopPadding: CGFloat = 8
        static let separatorHeight: CGFloat = 1.0
        static let summaryTopPadding: CGFloat = 24
        static let footerTopPadding: CGFloat = 24
        static let compactSummaryTopPadding: CGFloat = 16
        static let tableDeviderTopPadding: CGFloat = 64
        static let communityQuestionDeviderPadding: CGFloat = 12
    }
    // TODO: fileprivate lazy var adBannerView: SPAdBannerView

    fileprivate lazy var preConversationSummary: OWPreConversationSummeryView = {
        return OWPreConversationSummeryView(viewModel: self.viewModel.outputs.preConversationSummaryVM)
    }()
    fileprivate lazy var communityGuidelinesView: OWCommunityGuidelinesView = {
        return OWCommunityGuidelinesView(with: self.viewModel.outputs.communityGuidelinesViewModel)
    }()
    fileprivate lazy var communityQuestionBottomDevider: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor2, themeStyle: .light))
    }()
    fileprivate lazy var communityQuestionView: OWCommunityQuestionView = {
        return OWCommunityQuestionView(with: self.viewModel.outputs.communityQuestionViewModel)
    }()
    fileprivate lazy var commentCreationEntryView: OWCommentCreationEntryView = {
        let view = OWCommentCreationEntryView(with: self.viewModel.outputs.commentCreationEntryViewModel)
        return view
    }()
    fileprivate var commentCreationZeroHeightConstraint: OWConstraint? = nil
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
            .enforceSemanticAttribute()
            .backgroundColor(UIColor.clear)
            .separatorStyle(.none)
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
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
        return LocalizationManager.localizedString(key: "Show more comments")
            .button
            .backgroundColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
            .textColor(.white)
            .corner(radius: Metrics.btnFullConversationCornerRadius)
            .withPadding(Metrics.btnFullConversationTextPadding)
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.btnFullConversationFontSize))
    }()
    fileprivate lazy var footerTopDevider: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor2, themeStyle: .light))
    }()
    fileprivate lazy var footerView: OWPreConversationFooterView = {
        return OWPreConversationFooterView(with: self.viewModel.outputs.footerViewViewModel)
    }()

    fileprivate lazy var preConversationDataSource: OWRxTableViewSectionedAnimatedDataSource<PreConversationDataSourceModel> = {
        let dataSource = OWRxTableViewSectionedAnimatedDataSource<PreConversationDataSourceModel>(configureCell: { [weak self] _, tableView, indexPath, item -> UITableViewCell in
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
    }
}

fileprivate extension OWPreConversationView {
    func setupViews() {
        self.useAsThemeStyleInjector()

        self.addSubviews(preConversationSummary)
        preConversationSummary.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.compactSummaryTopPadding)
            make.leading.trailing.equalToSuperview()
        }

        if (viewModel.outputs.shouldShowComapactView) {
            self.addSubview(compactContentView)
            compactContentView.OWSnp.makeConstraints { make in
                make.top.equalTo(preConversationSummary.OWSnp.bottom).offset(8)
                make.leading.equalToSuperview().offset(Metrics.compactModePadding)
                make.trailing.equalToSuperview().offset(-Metrics.compactModePadding)
                make.bottom.equalToSuperview().offset(-Metrics.compactModePadding)
            }
            return
        }

        // TODO: Adjust UI correctly according to the style
        // Each component should be added separately
        // DO NOT pass style in the VM, use `shouldShowCommunityGuidelinesAndQuestion` and etc.

        self.addSubview(communityQuestionView)
        communityQuestionView.OWSnp.makeConstraints { make in
            make.top.equalTo(preConversationSummary.OWSnp.bottom).offset(Metrics.communityQuestionTopPadding)
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
        }

        self.addSubview(communityQuestionBottomDevider)
        communityQuestionBottomDevider.OWSnp.makeConstraints { make in
            make.top.equalTo(communityQuestionView.OWSnp.bottom).offset(Metrics.communityQuestionDeviderPadding)
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            make.height.equalTo(Metrics.separatorHeight)
        }

        self.addSubview(communityGuidelinesView)
        communityGuidelinesView.OWSnp.makeConstraints { make in
            make.top.equalTo(communityQuestionBottomDevider.OWSnp.bottom).offset(Metrics.communityQuestionDeviderPadding)
            make.leading.trailing.equalToSuperview()
        }

        self.addSubview(commentCreationEntryView)
        commentCreationEntryView.OWSnp.makeConstraints { make in
            make.top.equalTo(communityGuidelinesView.OWSnp.bottom).offset(Metrics.commentCreationTopPadding)
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview()
            commentCreationZeroHeightConstraint = make.height.equalTo(0).constraint
        }

        self.addSubview(tableView)
        tableView.OWSnp.makeConstraints { make in
            make.top.equalTo(commentCreationEntryView.OWSnp.bottom).offset(Metrics.commentCreationBottomPadding)
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            make.height.equalTo(0)
        }

        self.addSubview(tableBottomDivider)
        tableBottomDivider.OWSnp.makeConstraints { make in
            make.height.equalTo(Metrics.separatorHeight)
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(tableView.OWSnp.bottom).offset(Metrics.tableDeviderTopPadding)
        }

        self.addSubview(btnCTAConversation)
        btnCTAConversation.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            make.top.equalTo(tableBottomDivider.OWSnp.bottom).offset(Metrics.btnFullConversationTopPadding)
        }

        self.addSubview(footerTopDevider)
        footerTopDevider.OWSnp.makeConstraints { make in
            make.height.equalTo(Metrics.separatorHeight)
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            make.top.equalTo(btnCTAConversation.OWSnp.bottom).offset(Metrics.btnFullConversationTopPadding)
        }

        self.addSubview(footerView)
        footerView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
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

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: self.viewModel.outputs.isCompactBackground ? .backgroundColor3 : .backgroundColor2, themeStyle: currentStyle)
                self.tableBottomDivider.backgroundColor = OWColorPalette.shared.color(type: .separatorColor2, themeStyle: currentStyle)
                self.footerTopDevider.backgroundColor = OWColorPalette.shared.color(type: .separatorColor2, themeStyle: currentStyle)
                self.communityQuestionBottomDevider.backgroundColor = OWColorPalette.shared.color(type: .separatorColor2, themeStyle: currentStyle)
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

        viewModel.outputs
            .communityQuestionViewModel.outputs
            .shouldShowView
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isVisible in
                guard let self = self else { return }
                self.communityQuestionView.OWSnp.updateConstraints { make in
                    make.top.equalTo(self.preConversationSummary.OWSnp.bottom).offset(isVisible ? Metrics.communityQuestionTopPadding : 0)
                }
                self.communityQuestionBottomDevider.OWSnp.updateConstraints { make in
                    make.top.equalTo(self.communityQuestionView.OWSnp.bottom).offset(isVisible ? Metrics.communityQuestionDeviderPadding : 0)
                    make.height.equalTo(isVisible ? Metrics.separatorHeight : 0)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs
            .communityQuestionViewModel.outputs
            .shouldShowView
            .map { !$0 }
            .bind(to: communityQuestionBottomDevider.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs
            .communityGuidelinesViewModel
            .outputs
            .shouldBeHidden
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isHidden in
                guard let self = self else { return }
                self.communityGuidelinesView.OWSnp.updateConstraints { make in
                    make.top.equalTo(self.communityQuestionBottomDevider.OWSnp.bottom).offset(isHidden ? 0 : Metrics.communityQuestionDeviderPadding)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.conversationCTAButtonTitle
            .bind(to: btnCTAConversation.rx.title())
            .disposed(by: disposeBag)

        viewModel.outputs.preConversationDataSourceSections
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(dataSource: preConversationDataSource))
            .disposed(by: disposeBag)

        viewModel.outputs.updateCellSizeAtIndex
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] index in
                    guard let self = self else { return }
                    UIView.performWithoutAnimation {
                        self.tableView.reloadItemsAtIndexPaths([IndexPath(row: index, section: 0)], animationStyle: .none)
                    }
                })
                .disposed(by: disposeBag)

        btnCTAConversation.rx.tap
            .voidify()
            .bind(to: viewModel.inputs.fullConversationTap)
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowCommentCreationEntryView
            .map { !$0 }
            .bind(to: commentCreationEntryView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowCommentCreationEntryView
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldShow in
                guard let self = self else { return }
                if (shouldShow) {
                    self.commentCreationZeroHeightConstraint?.deactivate()
                } else {
                    self.commentCreationZeroHeightConstraint?.activate()
                }
                self.commentCreationEntryView.OWSnp.updateConstraints { make in
                    make.top.equalTo(self.communityGuidelinesView.OWSnp.bottom).offset(shouldShow ? Metrics.commentCreationTopPadding : 0)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowComments
            .map { !$0 }
            .bind(to: tableView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowComments
            .map { !$0 }
            .bind(to: tableBottomDivider.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowComments
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isVisible in
                guard let self = self else { return }
                self.tableView.OWSnp.updateConstraints { make in
                    make.top.equalTo(self.commentCreationEntryView.OWSnp.bottom).offset(isVisible ? Metrics.commentCreationBottomPadding : 0)
                }
                self.tableBottomDivider.OWSnp.updateConstraints { make in
                    make.top.equalTo(self.tableView.OWSnp.bottom).offset(isVisible ? Metrics.tableDeviderTopPadding : 0)
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowCTA
            .map { !$0 }
            .bind(to: btnCTAConversation.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowCTA
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

        tableView.rx.observe(CGSize.self, #keyPath(UITableView.contentSize))
            .unwrap()
            .withLatestFrom(viewModel.outputs.shouldShowComments) { size, showComments -> CGFloat? in
                guard showComments == true else { return 0 }
                return size.height
            }
            .unwrap()
            .subscribe(onNext: { [weak self] height in
                guard let self = self else { return }
                self.tableView.OWSnp.updateConstraints { make in
                    make.height.equalTo(height)
                }
            })
            .disposed(by: disposeBag)
    }
    // swiftlint:enable function_body_length
}
