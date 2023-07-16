//
//  OWCommentCreationReplySnippetView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 16/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWCommentCreationReplySnippetView: UIView {
    fileprivate struct Metrics {

    }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: OWCommentCreationReplySnippetViewModel

    init(with viewModel: OWCommentCreationReplySnippetViewModel) {
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

fileprivate extension OWCommentCreationReplySnippetView {
    func setupUI() {

    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
            }).disposed(by: disposeBag)
    }

    func applyAccessibility() {

    }
}
