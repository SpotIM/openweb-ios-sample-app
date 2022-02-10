//
//  OWUserSubscriberBadgeView.swift
//  SpotImCore
//
//  Created by Tomer Ben Rachel on 27/01/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


class OWUserSubscriberBadgeView: UIView {
    
    fileprivate struct Metrics {
        static let subscriberBadgeIconSize: CGFloat = 20.0
    }
    
    fileprivate var viewModel: OWUserSubscriberBadgeViewModeling!
    fileprivate var disposeBag: DisposeBag!
    
    fileprivate lazy var imgViewIcon: UIImageView = {
        let img = UIImageView()
            .contentMode(.scaleAspectFit)
            .tintColor(UIColor.brandColor)
        return img
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    func configure(with viewModel: OWUserSubscriberBadgeViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        configureViews()
    }
}

fileprivate extension OWUserSubscriberBadgeView {
    
    func setupViews() {
        self.addSubview(imgViewIcon)
        imgViewIcon.layout {
            $0.top.equal(to: self.topAnchor)
            $0.leading.equal(to: self.leadingAnchor)
            $0.trailing.equal(to: self.trailingAnchor)
            $0.bottom.equal(to: self.bottomAnchor)
            $0.width.equal(to: Metrics.subscriberBadgeIconSize)
            $0.height.equal(to: Metrics.subscriberBadgeIconSize)
        }
    }
    
    
    func configureViews() {
        viewModel.outputs.isSubscriber
            .map { !$0 } // Reverse
            .bind(to: self.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.outputs.image
            .map { $0.withRenderingMode(.alwaysTemplate) }
            .bind(to: self.imgViewIcon.rx.image)
            .disposed(by: disposeBag)
    }
}
