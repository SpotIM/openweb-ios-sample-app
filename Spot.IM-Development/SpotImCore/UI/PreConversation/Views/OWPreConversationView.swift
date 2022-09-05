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

class OWPreConversationView: UIView {
    fileprivate struct Metrics {
        static let headerHeight: CGFloat = 50
        static let bannerViewMargin: CGFloat = 40
        static let whatYouThinkHeight: CGFloat = 64
    }
    
    private var actualBannerMargin: CGFloat {
        adBannerView.frame.height == 0 ? 0 : Metrics.bannerViewMargin
    }
    
    fileprivate lazy var adBannerView: SPAdBannerView = .init()
    fileprivate lazy var header: SPPreConversationHeaderView = .init()
    fileprivate lazy var communityGuidelinesView: SPCommunityGuidelinesView = .init()
    fileprivate lazy var communityQuestionView: SPCommunityQuestionView = .init()
    fileprivate lazy var whatYouThinkView: SPMainConversationFooterView = .init()
    fileprivate lazy var footerView: SPPreConversationFooter = .init()
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
            .enforceSemanticAttribute()
            .backgroundColor(.spBackground0)
            .separatorStyle(.none)
        tableView.isScrollEnabled = false
        // Register cells
        for option in OWPreConversationCellOption.allCases {
            tableView.register(cellClass: option.cellClass)
        }
            
        return tableView
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
    
    fileprivate let adsProvider: AdsProvider
    
    fileprivate let viewModel: OWPreConversationViewViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(viewModel: OWPreConversationViewViewModeling, adsProvider: AdsProvider) {
        self.viewModel = viewModel
        self.adsProvider = adsProvider
        super.init(frame: .zero)
        adsProvider.bannerDelegate = self
        adsProvider.interstitialDelegate = self
        setupViews()
        setupObservers()
    }
}

fileprivate extension OWPreConversationView {
    func setupViews() {
        // After building the other views, position the table view in the appropriate place
        self.addSubviews(adBannerView, tableView, footerView)
        adBannerView.OWSnp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
        if SpotIm.buttonOnlyMode != .withoutTitle {
            self.addSubview(header)
            header.OWSnp.makeConstraints { make in
                make.top.equalTo(adBannerView.OWSnp.bottom).offset(actualBannerMargin)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(Metrics.headerHeight)
            }
        }
        if !viewModel.outputs.isButtonOnlyModeEnabled {
            self.addSubviews(communityGuidelinesView, communityQuestionView, whatYouThinkView)
            communityGuidelinesView.OWSnp.makeConstraints { make in
                make.top.equalTo(header.OWSnp.bottom)
                make.leading.trailing.equalToSuperview()
            }
            communityQuestionView.OWSnp.makeConstraints { make in
                make.top.equalTo(communityGuidelinesView.OWSnp.bottom)
                make.leading.trailing.equalToSuperview()
            }
            whatYouThinkView.OWSnp.makeConstraints { make in
                make.top.equalTo(communityQuestionView.OWSnp.bottom)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(Metrics.whatYouThinkHeight)
            }
        }
        tableView.OWSnp.makeConstraints { make in
            make.top.equalTo(whatYouThinkView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.0)
        }
        let footerViewTopConstraint = viewModel.outputs.isButtonOnlyModeEnabled ? (SpotIm.buttonOnlyMode == .withoutTitle ? adBannerView.OWSnp.bottom : header.OWSnp.bottom) :  tableView.OWSnp.bottom
        footerView.OWSnp.makeConstraints { make in
            make.top.equalTo(footerViewTopConstraint)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func setupObservers() {
        viewModel.outputs.preConversationDataSourceSections
            .do(onNext: { [weak self] _ in
                self?.updateTableViewHeightIfNeeded()
            })
            .bind(to: tableView.rx.items(dataSource: preConversationDataSource))
            .disposed(by: disposeBag)
    }
    
    // TODO: after moving to table cells defined with constraints and not numbered height, we might not need this function and the tableview height constraint
    private func updateTableViewHeightIfNeeded() {
        if (tableView.frame.size.height != tableView.contentSize.height) {
            tableView.OWSnp.updateConstraints { make in
                make.height.equalTo(tableView.contentSize.height)
            }
            self.layoutIfNeeded()
        }
    }
}

extension OWPreConversationView: AdsProviderBannerDelegate {
    func bannerLoaded(bannerView: UIView, adBannerSize: CGSize, adUnitID: String) {
//        SPAnalyticsHolder.default.log(event: .engineStatus(.engineInitialized, .banner), source: .conversation)
//
//        adBannerView.OWSnp.makeConstraints { make in
//            make.height.equalTo(adBannerSize.height)
//        }
//
//        adBannerView.update(bannerView, height: adBannerSize.height)
//
//        bannerVisisilityTracker.startTracking()
    }
    
    func bannerFailedToLoad(error: Error) {
//        servicesProvider.logger().log(level: .error, "error bannerFailedToLoad - \(error.localizedDescription)")
//        SPDefaultFailureReporter.shared.report(error: .monetizationError(.bannerFailedToLoad(source: .preConversation, error: error)))
//        SPAnalyticsHolder.default.log(event: .engineStatus(.engineInitilizeFailed, .banner), source: .conversation)
    }
}

extension OWPreConversationView: AdsProviderInterstitialDelegate {
    func interstitialLoaded() {
//        SPAnalyticsHolder.default.log(event: .engineStatus(.engineInitialized, .interstitial), source: .conversation)
    }
    
    func interstitialWillBeShown() {
//        AdsManager.willShowInterstitial(for: model.dataSource.postId)
//        SPAnalyticsHolder.default.log(event: .engineStatus(.engineMonetizationView, .interstitial), source: .conversation)
    }
    
    func interstitialDidDismiss() {
        
    }
    
    func interstitialFailedToLoad(error: Error) {
//        SPDefaultFailureReporter.shared.report(error: .monetizationError(.interstitialFailedToLoad(error: error)))
//        SPAnalyticsHolder.default.log(event: .engineStatus(.engineInitilizeFailed, .interstitial), source: .conversation)
    }
}
