//
//  OWCollapsableLabel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 27/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWCollapsableLabel: UILabel {
    fileprivate var viewModel: OWCollapsableLabelViewModeling = OWCollapsableLabelViewModel(text: NSMutableAttributedString(string: ""), lineLimit: 0)
    fileprivate var disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero)
    }
    
    func configure(with viewModel: OWCollapsableLabelViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCollapsableLabel {
    func setupObservers() {
        viewModel.outputs.text
            .bind(onNext: { [weak self] text in
                self?.attributedText = text
            })
            .disposed(by: disposeBag)
    }
}
