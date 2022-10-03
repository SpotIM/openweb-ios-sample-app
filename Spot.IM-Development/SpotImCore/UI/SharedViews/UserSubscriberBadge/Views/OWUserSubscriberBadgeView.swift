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
        static let identifier = "subscriber_badge_view_id"
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
        self.accessibilityIdentifier = Metrics.identifier
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
        
        imgViewIcon.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(Metrics.subscriberBadgeIconSize)
        }
    }
    
    func configureViews() {
        viewModel.outputs.isSubscriber
            .map { !$0 } // Reverse
            .bind(to: imgViewIcon.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.outputs.image
            .map { $0.withRenderingMode(.alwaysTemplate) }
            .bind(to: imgViewIcon.rx.image)
            .disposed(by: disposeBag)
    }
}
