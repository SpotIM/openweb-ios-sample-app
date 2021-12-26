//
//  OWOnlineViewingUsersCounterView.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/12/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
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
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    fileprivate lazy var lblViewersNumber: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferred(style: .regular, of: Metrics.viewersFontSize)
        lbl.textColor = .spForeground3
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
    
    func configure(with viewModel: OWOnlineViewingUsersCounterViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        configureViews()
    }
}

fileprivate extension OWOnlineViewingUsersCounterView {
    func setupViews() {
        self.addSubview(imgViewIcon)
        imgViewIcon.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.addSubview(lblViewersNumber)
        lblViewersNumber.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(imgViewIcon.snp.trailing).offset(Metrics.horizontalMargin)
            make.trailing.equalToSuperview()
        }
    }
    
    func configureViews() {
        imgViewIcon.image = viewModel.outputs.image
        viewModel.outputs.viewingCount
            .bind(to: lblViewersNumber.rx.text)
            .disposed(by: disposeBag)
    }
}

