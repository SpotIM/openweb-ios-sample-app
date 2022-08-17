//
//  OWCommentCreationView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 17/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OWCommentCreationEntryView: UIView {
    fileprivate struct Metrics {
        
    }
    
    fileprivate let viewModel: OWCommentCreationEntryViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(viewModel: OWCommentCreationEntryViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
    }
}

fileprivate extension OWCommentCreationEntryView {
    func setupViews() {
    }
    
    func setupObservers() {
    }
}
