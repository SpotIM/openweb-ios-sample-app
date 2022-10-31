//
//  OWOnlineViewingUsersCounterView.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/12/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWOnlineViewingUsersCounterView: UIView {
    fileprivate struct Metrics {
        static let horizontalMargin: CGFloat = 6
        static let viewersFontSize: CGFloat = 15.0
    }
    
    fileprivate var viewModel: OWOnlineViewingUsersCounterViewModeling!
    fileprivate var disposeBag: DisposeBag!
    
    fileprivate lazy var imgViewIcon: UIImageView = {
        let img = UIImageView()
            .contentMode(.scaleAspectFit)
        
        return img
    }()
    
    fileprivate lazy var lblViewersNumber: UILabel = {
        let lbl = UILabel()
            .font(UIFont.preferred(style: .regular, of: Metrics.viewersFontSize))
            .textColor(.spForeground3)

        return lbl
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    init(viewModel: OWOnlineViewingUsersCounterViewModeling) {
        super.init(frame: .zero)
        self.viewModel = viewModel
        setupViews()
        disposeBag = DisposeBag()
        configureViews()
    }
    
    func configure(with viewModel: OWOnlineViewingUsersCounterViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        configureViews()
    }
}

fileprivate extension OWOnlineViewingUsersCounterView {
    func setupViews() {
        self.addSubview(imgViewIcon)
        imgViewIcon.OWSnp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }
        
        self.addSubview(lblViewersNumber)
        lblViewersNumber.OWSnp.makeConstraints { make in
            make.centerY.trailing.equalToSuperview()
            make.leading.equalTo(imgViewIcon.OWSnp.trailing).offset(Metrics.horizontalMargin)
        }
    }
    
    func configureViews() {
        imgViewIcon.image = viewModel.outputs.image
        viewModel.outputs.viewingCount
            .startWith("0")
            .bind(to: lblViewersNumber.rx.text)
            .disposed(by: disposeBag)
    }
}

