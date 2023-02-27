//
//  OWCommentThreadView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 30/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentThreadView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "comment_thread_view_id"
    }

    fileprivate let viewModel: OWCommentThreadViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWCommentThreadViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
        applyAccessibility()
    }
}

fileprivate extension OWCommentThreadView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }
    
    func setupViews() {
        self.useAsThemeStyleInjector()

        // TODO: Remove the ugly green when actually starting to work on the UI, this is only for integration purposes at the moment
        self.backgroundColor = .green
    }

    func setupObservers() {

    }
}
