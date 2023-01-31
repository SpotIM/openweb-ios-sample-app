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

        
        // Usually the publisher will pin the pre conversation view to the leading and trainling of the encapsulation VC/View,
        // However we are using a callback with CGSize so we will return the screen width or 400 in case for some reason we couldn't get a referance to the window.
        // We should later use RX to return a calculated height based on the actual width of the frame
        static let assumedWidth: CGFloat = (UIApplication.shared.delegate?.window??.screen.bounds.width ?? 400)
        // TODO: Testing - remove later
        static let initialHeight: CGFloat = 800
        static let changedHeight: CGFloat = 700
        
        static let separatorHeight: CGFloat = 1.0
    }
    
    // TODO: Testing - remove later (hard coded cause only for testing)
    fileprivate lazy var btnCommentCreation: UIButton = {
        return "Comment Creation - testing"
            .button
            .backgroundColor(.orange)
            .textColor(.white)
            .corner(radius: 12.0)
            .withPadding(20)
            .font(UIFont.preferred(style: .regular, of: 20))
    }()
    
    // TODO: fileprivate lazy var adBannerView: SPAdBannerView
    
    fileprivate lazy var header: OWPreConversationHeaderView = {
        return OWPreConversationHeaderView(viewModel: self.viewModel.outputs.preConversationHeaderVM)
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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 280
        tableView.hugContent()
        tableView.wrapContent()
        // Register cells
        for option in OWPreConversationCellOption.allCases {
            tableView.register(cellClass: option.cellClass)
        }
        
        return tableView
    }()
    fileprivate lazy var btnFullConversation: UIButton = {
        return LocalizationManager.localizedString(key: "SHOW MORE COMMENTS")
            .button
            .backgroundColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
            .textColor(.white)
            .corner(radius: Metrics.btnFullConversationCornerRadius)
            .withPadding(Metrics.btnFullConversationTextPadding)
            .font(UIFont.preferred(style: .medium, of: Metrics.btnFullConversationFontSize))
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
        self.backgroundColor = OWColorPalette.shared.color(type: .background0Color, themeStyle: .light)
        
        self.useAsThemeStyleInjector()

        self.OWSnp.makeConstraints { make in
            make.height.equalTo(Metrics.initialHeight)
        }
        
        self.addSubviews(header)
        header.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        if !viewModel.outputs.isButtonOnlyModeEnabled {
            self.addSubview(communityGuidelinesView)
            communityGuidelinesView.OWSnp.makeConstraints { make in
                make.top.equalTo(header.OWSnp.bottom)
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
                make.height.equalTo(Metrics.separatorHeight)
            }
            
            self.addSubview(commentCreationEntryView)
            commentCreationEntryView.OWSnp.makeConstraints { make in
                make.top.equalTo(separatorView.OWSnp.bottom).offset(Metrics.commentCreationVerticalPadding)
                make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
                make.trailing.equalToSuperview()
            }
            
            self.addSubview(tableView)
            tableView.OWSnp.makeConstraints { make in
                make.top.equalTo(commentCreationEntryView.OWSnp.bottom).offset(Metrics.commentCreationVerticalPadding)
                make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
                make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            }
        }
        
        
        
//        self.addSubview(btnCommentCreation)
//        btnCommentCreation.OWSnp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-20)
//        }
        
        self.addSubview(btnFullConversation)
        btnFullConversation.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            make.top.equalTo(tableView.OWSnp.bottom).offset(Metrics.btnFullConversationTopPadding)
        }
        
        self.addSubview(footerView)
        footerView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            make.top.equalTo(btnFullConversation.OWSnp.bottom).offset(Metrics.btnFullConversationTopPadding)
            make.bottom.equalToSuperview().offset(-23)
        }
        
        // After building the other views, position the table view in the appropriate place
        //        self.addSubviews(tableView, footerView)
        //        if SpotIm.buttonOnlyMode != .withoutTitle {
        //            self.addSubview(header)
        //            header.OWSnp.makeConstraints { make in
        //                make.top.equalToSuperview()
        //                make.leading.trailing.equalToSuperview()
        //                make.height.equalTo(Metrics.headerHeight)
        //            }
        //        }
        //        if !viewModel.outputs.isButtonOnlyModeEnabled {
        //            self.addSubviews(communityGuidelinesView, communityQuestionView, commentCreationEntryView)
        //            communityGuidelinesView.OWSnp.makeConstraints { make in
        //                make.top.equalTo(header.OWSnp.bottom)
        //                make.leading.trailing.equalToSuperview()
        //            }
        //            communityQuestionView.OWSnp.makeConstraints { make in
        //                make.top.equalTo(communityGuidelinesView.OWSnp.bottom)
        //                make.leading.trailing.equalToSuperview()
        //            }
        //            commentCreationEntryView.OWSnp.makeConstraints { make in
        //                make.top.equalTo(communityQuestionView.OWSnp.bottom)
        //                make.leading.trailing.equalToSuperview()
        //                make.height.equalTo(Metrics.whatYouThinkHeight)
        //            }
        //        }
        //        tableView.OWSnp.makeConstraints { make in
        //            make.top.equalTo(commentCreationEntryView.OWSnp.bottom)
        //            make.leading.trailing.equalToSuperview()
        //            make.height.equalTo(0.0)
        //        }
        //        let footerViewTopConstraint = viewModel.outputs.isButtonOnlyModeEnabled && SpotIm.buttonOnlyMode == .withoutTitle ? header.OWSnp.bottom :  tableView.OWSnp.bottom
        //        footerView.OWSnp.makeConstraints { make in
        //            make.top.equalTo(footerViewTopConstraint)
        //            make.leading.trailing.equalToSuperview()
        //        }
    }
    
    func setupObservers() {
        viewModel.inputs.preConversationChangedSize.onNext(CGSize(width: Metrics.assumedWidth, height: Metrics.initialHeight))
        
        viewModel.outputs.preConversationDataSourceSections
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                self?.updateTableViewHeightIfNeeded()
            })
            .bind(to: tableView.rx.items(dataSource: preConversationDataSource))
            .disposed(by: disposeBag)
                
        viewModel.outputs.changeSizeAtIndex
                .subscribe(onNext: { [weak self] index in
                    guard let self = self else { return }
                    UIView.performWithoutAnimation {
                        print("NOGAH: update row: \(index)")
                        self.tableView.reloadItemsAtIndexPaths([IndexPath(row: index, section: 0)], animationStyle: .none)
//                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
//                        self.tableView.reloadData()
                    }
                })
                .disposed(by: disposeBag)
        
        btnFullConversation.rx.tap
            .voidify()
            .bind(to: viewModel.inputs.fullConversationTap)
            .disposed(by: disposeBag)
        
        btnCommentCreation.rx.tap
                .voidify()
                .bind(onNext: { [weak self] in
                    self?.viewModel.inputs.commentCreationTap.onNext(.comment)
                })
                .disposed(by: disposeBag)
        
                
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .background0Color, themeStyle: currentStyle)
                self.separatorView.backgroundColor = OWColorPalette.shared.color(type: .separatorColor,
                                                                   themeStyle: currentStyle)
                self.btnFullConversation.backgroundColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: currentStyle)
            }).disposed(by: disposeBag)
    }
    
    // TODO: after moving to table cells defined with constraints and not numbered height, we might not need this function and the tableview height constraint
    private func updateTableViewHeightIfNeeded() {
//        if (tableView.frame.size.height != tableView.contentSize.height) {
//            tableView.OWSnp.updateConstraints { make in
//                make.height.equalTo(tableView.contentSize.height)
//            }
//            self.layoutIfNeeded()
//        }
    }
}
