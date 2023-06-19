//
//  OWCommentCreationFooterView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 18/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

class OWCommentCreationFooterView: UIView {

    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: OWCommentCreationFooterViewModeling

    init(with viewModel: OWCommentCreationFooterViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        self.enforceSemanticAttribute()

        setupUI()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCommentCreationFooterView {
    func setupUI() {
        backgroundColor = .blue
    }

    func setupObservers() {

    }

    func applyAccessibility() {

    }
}
