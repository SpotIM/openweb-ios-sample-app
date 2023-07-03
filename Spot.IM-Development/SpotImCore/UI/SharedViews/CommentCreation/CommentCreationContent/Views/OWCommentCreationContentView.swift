//
//  OWCommentCreationContentView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 03/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWCommentCreationContentView: UIView {
    fileprivate struct Metrics {

    }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: OWCommentCreationContentViewModeling

    fileprivate lazy var textInput: UITextView = {
        return UITextView()
    }()

    init(with viewModel: OWCommentCreationContentViewModeling) {
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

fileprivate extension OWCommentCreationContentView {
    func setupUI() {
        addSubview(textInput)
        textInput.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
            }).disposed(by: disposeBag)

        viewModel.outputs.commentTextOutput
            .bind(to: textInput.rx.text)
            .disposed(by: disposeBag)

        textInput.rx.didChange
            .map { [weak self] _ in
                guard let self = self else { return nil }
                return self.textInput.text
            }
            .bind(to: viewModel.inputs.commentText)
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {

    }
}
