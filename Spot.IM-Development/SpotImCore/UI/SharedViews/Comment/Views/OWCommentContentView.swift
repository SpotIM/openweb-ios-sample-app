//
//  OWCommentContentView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OWCommentContentView: UIView {
    fileprivate struct Metrics {
        
    }
    
    fileprivate let viewModel: OWCommentContentViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(viewModel: OWCommentContentViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
    }
}

fileprivate extension OWCommentContentView {
    func setupViews() {

    }
    
    func setupObservers() {

    }
}
