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
    
    fileprivate var viewModel: OWUserSubscriberBadgeViewModel!
    fileprivate var disposeBag: DisposeBag!
    
    fileprivate lazy var imgViewIcon: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
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
    
    func configure(with viewModel: OWUserSubscriberBadgeViewModel) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        configureViews()
    }
}

fileprivate extension OWUserSubscriberBadgeView {
    
    func setupViews() {
        self.addSubview(imgViewIcon)
        
    }
    
    
    func configureViews() {
        imgViewIcon.image = viewModel.outputs.image
    }

}
