//
//  OWCommentCreationView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentCreationView: UIView {
    fileprivate struct Metrics {
        
    }
    
    fileprivate let viewModel: OWCommentCreationViewViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(viewModel: OWCommentCreationViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
    }
}

fileprivate extension OWCommentCreationView {
    func setupViews() {

        // TODO: Remove the ugly blue when actually starting to work on the UI, this is only for integration purposes at the moment
        self.backgroundColor = .blue
    }
}
