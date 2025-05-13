//
//  OWCommentCreationView-preview.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 09/03/2025.
//

#if DEBUG
@testable import OpenWebSDK

@available(iOS 17, *)
#Preview {
    let starRatingsData: [OWStarRatingSummaryType: Int] = [.oneStar: 3, .twoStars: 12, .threeStars: 34, .fourStars: 56, .fiveStars: 12]
    let summaryData = OWStarRatingSummary(summary: starRatingsData, total: 117, average: 3.5)

    let headerViewVM = OWStarRatingHeaderViewViewModel()
    let headerView = OWStarRatingHeaderView(viewModel: headerViewVM)
    headerViewVM.inputs.totalRatingsChange.onNext(summaryData.total ?? 0)
    headerViewVM.inputs.starsChange.onNext(summaryData.average ?? 0)

    let summaryViewVM = OWStarRatingSummaryViewViewModel()
    summaryViewVM.inputs.summaryDataChange.onNext(summaryData)

    let summaryView = OWStarRatingSummaryView(viewModel: summaryViewVM)

    let expandableView = OWExpandableView(headerView: headerView,
                                          contentView: summaryView)
    expandableView.backgroundColor = OWColorPalette.shared.dynamicColor(type: .backgroundColor1)

    expandableView.OWSnp.makeConstraints { make in
        make.width.equalTo(380)
    }

    return expandableView
}
#endif
