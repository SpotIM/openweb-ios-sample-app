//
//  OWStarRatingSummary-preview.swift
//  OpenWeb-SampleApp
//
//  Created by Refael Sommer on 11/05/2025.
//  Copyright © 2025 OpenWeb. All rights reserved.

#if DEBUG
@testable import OpenWebSDK

@available(iOS 17, *)
#Preview {
    let starRatingsData: [OWStarRatingLevel: Int] = [.oneStar: 3, .twoStars: 12, .threeStars: 34, .fourStars: 56, .fiveStars: 12]
    let summaryData = OWStarRatingSummary(summary: starRatingsData, total: 117, average: 3.5)

    let summaryVM = OWStarRatingSummaryViewViewModel()
    summaryVM.inputs.summaryDataChange.onNext(summaryData)
    let summaryView = OWStarRatingSummaryView(with: summaryVM)

    summaryView.OWSnp.makeConstraints { make in
        make.width.equalTo(380)
    }

    return summaryView
}
#endif
