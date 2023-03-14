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
    fileprivate struct Metrics {
        static let bannerViewMargin: CGFloat = 40
        static let whatYouThinkHeight: CGFloat = 64
        static let commentCreationVerticalPadding: CGFloat = 16
        static let horizontalOffset: CGFloat = 16.0
        static let btnFullConversationCornerRadius: CGFloat = 4
        static let btnFullConversationFontSize: CGFloat = 14
        static let btnFullConversationTextPadding: CGFloat = 13
        static let btnFullConversationTopPadding: CGFloat = 13
        static let bottomPadding: CGFloat = 23
        static let compactModePadding: CGFloat = 16

        static let separatorHeight: CGFloat = 1.0
    }
    // TODO: fileprivate lazy var adBannerView: SPAdBannerView

    fileprivate lazy var preConversationSummary: OWPreConversationSummeryView = {
        return OWPreConversationSummeryView(viewModel: self.viewModel.outputs.preConversationSummaryVM)
    }()
    fileprivate lazy var communityGuidelinesView: OWCommunityGuidelinesView = {
        return OWCommunityGuidelinesView(with: self.viewModel.outputs.communityGuidelinesViewModel)
    }()
    fileprivate lazy var communityQuestionView: OWCommunityQuestionView = {
        return OWCommunityQuestionView(with: self.viewModel.outputs.communityQuestionViewModel)
    }()
    fileprivate lazy var separatorView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor,
                                                           themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()
    fileprivate lazy var commentCreationEntryView: OWCommentCreationEntryView = {
        let view = OWCommentCreationEntryView(with: self.viewModel.outputs.commentCreationEntryViewModel)
        return view
    }()
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
    fileprivate lazy var btnCTAConversation: UIButton = {
        return LocalizationManager.localizedString(key: "Show more comments")
            .button
            .backgroundColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
            .textColor(.white)
            .corner(radius: Metrics.btnFullConversationCornerRadius)
            .withPadding(Metrics.btnFullConversationTextPadding)
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.btnFullConversationFontSize))
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

    fileprivate lazy var compactCommentView: OWCompactCommentView = {
        return OWCompactCommentView()
    }()
    fileprivate lazy var compactTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        if (viewModel.outputs.isCompactMode) {
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

//    func setupCompactModeViews() {
//        self.backgroundColor = OWColorPalette.shared.color(type: .compactBackground, themeStyle: .light)
//        self.addSubview(preConversationSummary)
//        preConversationSummary.OWSnp.makeConstraints { make in
//            make.top.equalToSuperview().offset(Metrics.compactModePadding)
//            make.leading.trailing.equalToSuperview()
//        }
//
//        self.addSubview(compactCommentView)
//        compactCommentView.OWSnp.makeConstraints { make in
//            make.top.equalTo(preConversationSummary.OWSnp.bottom).offset(8)
//            make.leading.equalToSuperview().offset(Metrics.compactModePadding)
//            make.trailing.equalToSuperview().offset(-Metrics.compactModePadding)
//            make.bottom.equalToSuperview().offset(-Metrics.compactModePadding)
//        }
//    }
        self.backgroundColor = OWColorPalette.shared.color(type: .background0Color, themeStyle: .light)
        self.addSubviews(preConversationSummary)
        preConversationSummary.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        if (viewModel.outputs.shouldShowComapctView) {
            self.addSubview(compactCommentView)
            compactCommentView.OWSnp.makeConstraints { make in
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
        self.addSubview(communityGuidelinesView)
        communityGuidelinesView.OWSnp.makeConstraints { make in
            make.top.equalTo(preConversationSummary.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        self.addSubview(communityQuestionView)
        communityQuestionView.OWSnp.makeConstraints { make in
            make.top.equalTo(communityGuidelinesView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        self.addSubview(separatorView)
        separatorView.OWSnp.makeConstraints { make in
            make.top.equalTo(communityQuestionView.OWSnp.bottom)
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            make.height.equalTo(viewModel.outputs.shouldShowSeparatorView ? Metrics.separatorHeight : 0)
        }
        separatorView.isHidden = !viewModel.outputs.shouldShowSeparatorView

        self.addSubview(commentCreationEntryView)
        commentCreationEntryView.OWSnp.makeConstraints { make in
            make.top.equalTo(separatorView.OWSnp.bottom).offset(viewModel.outputs.shouldCommentCreationEntryView ? Metrics.commentCreationVerticalPadding : 0)
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview()
            if(!viewModel.outputs.shouldCommentCreationEntryView) {
                make.height.equalTo(0)
            }
        }
        commentCreationEntryView.isHidden = !viewModel.outputs.shouldCommentCreationEntryView

        // TODO: separate to new component
        self.addSubview(tableView)
        tableView.OWSnp.makeConstraints { make in
            make.top.equalTo(commentCreationEntryView.OWSnp.bottom).offset(viewModel.outputs.shouldShowComments ? Metrics.commentCreationVerticalPadding : 0)
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            make.height.equalTo(0)
        }
        tableView.isHidden = !viewModel.outputs.shouldShowComments

        self.addSubview(btnCTAConversation)
        btnCTAConversation.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            make.top.equalTo(tableView.OWSnp.bottom).offset(viewModel.outputs.shouldShowCTA ? Metrics.btnFullConversationTopPadding : 0)
        }
        btnCTAConversation.isHidden = !viewModel.outputs.shouldShowCTA

        self.addSubview(footerView)
        footerView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            make.top.equalTo(btnCTAConversation.OWSnp.bottom).offset(viewModel.outputs.shouldShowFooter ? Metrics.btnFullConversationTopPadding : 0)
            make.bottom.equalToSuperview().offset(viewModel.outputs.shouldShowFooter ? -Metrics.bottomPadding : 0)
        }
        footerView.isHidden = !viewModel.outputs.shouldShowFooter

//        self.backgroundColor = OWColorPalette.shared.color(type: .compactBackground, themeStyle: .light) // TODO: background on compact/regular
    }

    func setupObservers() {
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

        compactTapGesture.rx.event
            .voidify()
            .bind(to: viewModel.inputs.fullConversationTap)
            .disposed(by: disposeBag)

        viewModel.outputs.compactCommentVM
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] vm in
                guard let self = self else { return }
                self.compactCommentView.configure(with: vm)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: self.viewModel.outputs.isCompactMode ? .compactBackground : .background0Color, themeStyle: currentStyle)
                self.separatorView.backgroundColor = OWColorPalette.shared.color(type: .separatorColor,
                                                                   themeStyle: currentStyle)
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
            .subscribe(onNext: { [weak self] size in
                guard let self = self, self.viewModel.outputs.shouldShowComments else { return }
                self.tableView.OWSnp.updateConstraints { make in
                    make.height.equalTo(size.height)
                }
            })
            .disposed(by: disposeBag)
    }
}
