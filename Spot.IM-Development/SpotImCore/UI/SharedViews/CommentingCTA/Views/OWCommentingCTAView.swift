//
//  OWCommentingCTAView.swift
//  SpotImCore
//
//  Created by Revital Pisman on 07/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

class OWCommentingCTAView: UIView {
    fileprivate struct Metrics {
        static let commentCreationTopPadding: CGFloat = 28
        static let readOnlyTopPadding: CGFloat = 40
    }

    fileprivate lazy var skelatonView: OWCommentingCTASkeletonView = {
        return OWCommentingCTASkeletonView()
    }()

    fileprivate lazy var commentCreationEntryView: OWCommentCreationEntryView = {
        return OWCommentCreationEntryView(with: self.viewModel.outputs.commentCreationEntryViewModel)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var commentingReadOnlyView: OWCommentingReadOnlyView = {
       return OWCommentingReadOnlyView()
    }()

    fileprivate var viewModel: OWCommentingCTAViewModeling!
    fileprivate var disposeBag = DisposeBag()

    init(with viewModel: OWCommentingCTAViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
    }

    init() {
        super.init(frame: .zero)
        self.setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCommentingCTAView {
    func setupViews() {
        self.enforceSemanticAttribute()

        self.addSubview(skelatonView)
        skelatonView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupObservers() {
        viewModel.outputs.style
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] style in
                guard let self = self else { return }
                self.subviews.forEach { $0.removeFromSuperview() }

                let view = self.getViewForStyle(style)
                self.addSubview(view)
                view.OWSnp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            })
            .disposed(by: disposeBag)
    }

    func getViewForStyle(_ style: OWCommentingCTAStyle) -> UIView {
        switch style {
        case .cta:
            return self.commentCreationEntryView
        case .conversationEnded:
            return self.commentingReadOnlyView
        default:
            return UIView()
        }
    }
}

