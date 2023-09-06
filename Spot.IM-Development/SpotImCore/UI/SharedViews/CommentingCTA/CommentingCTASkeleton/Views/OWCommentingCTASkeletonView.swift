//
//  OWCommentingCTASkeletonView.swift
//  SpotImCore
//
//  Created by Revital Pisman on 09/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

class OWCommentingCTASkeletonView: OWSkeletonShimmeringView {

    fileprivate struct Metrics {
        static let avatarSize: CGFloat = 40
        static let commentEntrySkeletonHeight: CGFloat = 40
        static let commentEntrySkeletonCornerRadius: CGFloat = 6
        static let commentEntrySkeletonLeadingOffset: CGFloat = 10

        static let margins: UIEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }

    fileprivate lazy var avatarSkeleton: UIView = {
        return UIView()
            .corner(radius: Metrics.avatarSize / 2)
            .backgroundColor(OWColorPalette.shared.color(type: .skeletonColor,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var commentEntrySkeleton: UIView = {
        return UIView()
            .corner(radius: Metrics.commentEntrySkeletonCornerRadius)
            .backgroundColor(OWColorPalette.shared.color(type: .skeletonColor,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var skelatonView: OWSkeletonShimmeringView = {
        let view = OWSkeletonShimmeringView()
        view.enforceSemanticAttribute()

        view.addSubview(avatarSkeleton)
        avatarSkeleton.OWSnp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
            make.size.equalTo(Metrics.avatarSize)
        }

        view.addSubview(commentEntrySkeleton)
        commentEntrySkeleton.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.height.equalTo(Metrics.commentEntrySkeletonHeight)
            make.leading.equalTo(avatarSkeleton.OWSnp.trailing).offset(Metrics.commentEntrySkeletonLeadingOffset)
            make.trailing.equalToSuperview()
        }

        return view
    }()

    init() {
        super.init(frame: .zero)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OWCommentingCTASkeletonView {
    func setupUI() {
        self.enforceSemanticAttribute()

        self.addSubview(skelatonView)
        skelatonView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.margins.top)
            make.bottom.equalToSuperview().offset(-Metrics.margins.bottom)
            make.leading.trailing.equalToSuperview()
        }
        skelatonView.addSkeletonShimmering()
    }
}
