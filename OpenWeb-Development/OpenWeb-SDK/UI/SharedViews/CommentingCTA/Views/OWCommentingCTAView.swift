//
//  OWCommentingCTAView.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 07/05/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift

class OWCommentingCTAView: UIView {

    private lazy var skelatonView: OWCommentingCTASkeletonView = {
        return OWCommentingCTASkeletonView()
    }()

    private lazy var commentCreationEntryView: OWCommentCreationEntryView = {
        return OWCommentCreationEntryView(with: self.viewModel.outputs.commentCreationEntryViewModel)
            .enforceSemanticAttribute()
            .wrapContent()
    }()

    private lazy var commentingReadOnlyView: OWCommentingReadOnlyView = {
        return OWCommentingReadOnlyView(with: self.viewModel.outputs.commentingReadOnlyViewModel)
            .wrapContent()
    }()

    private var currentStyleView: UIView?
    private var heightConstraint: OWConstraint?
    private var viewModel: OWCommentingCTAViewModeling!
    private var disposeBag = DisposeBag()

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

private extension OWCommentingCTAView {
    func setupViews() {
        self.enforceSemanticAttribute()

        self.addSubview(skelatonView)
        skelatonView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperviewSafeArea()
            self.heightConstraint = make.height.equalTo(0).constraint
        }
    }

    func setupObservers() {
        viewModel.outputs.style
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] style in
                guard let self = self else { return }
                self.subviews.forEach { $0.removeFromSuperview() }

                let view = self.view(forStyle: style)
                self.currentStyleView = view
                self.addSubview(view)
                view.OWSnp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.top.bottom.equalToSuperviewSafeArea()
                }
            })
            .disposed(by: disposeBag)

        if let heightConstraint = heightConstraint {
            viewModel.outputs.shouldShowView
                .map { !$0 }
                .bind(to: heightConstraint.rx.isActive)
                .disposed(by: disposeBag)
        }

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }

    func view(forStyle style: OWCommentingCTAStyle) -> UIView {
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
