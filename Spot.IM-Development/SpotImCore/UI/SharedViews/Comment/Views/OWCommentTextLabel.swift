//
//  OWCommentTextView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 27/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWCommentTextLabel: UILabel {
    fileprivate var viewModel: OWCommentTextViewModeling!
    fileprivate var disposeBag: DisposeBag!

    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.delegate = self
        return tap
    }()

    init() {
        super.init(frame: .zero)
    }

    func configure(with viewModel: OWCommentTextViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        setupObservers()
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let viewModel = viewModel else { return }

        viewModel.inputs.width.onNext(self.bounds.width)
    }
}

fileprivate extension OWCommentTextLabel {

    func setupObservers() {
        viewModel.outputs.attributedString
            .subscribe(onNext: { [weak self] attString in
                guard let self = self else { return }
                self.attributedText = attString
            })
            .disposed(by: disposeBag)

        tapGesture.rx.event
            .subscribe(onNext: { [weak self] tap in
                guard let self = self else { return }
                let tapLocation = tap.location(in: self)
                let index = self.indexOfAttributedTextCharacterAtPoint(point: tapLocation)
                self.viewModel.inputs.labelClickIndex.onNext(index)
            })
            .disposed(by: disposeBag)
    }
}

extension OWCommentTextLabel: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer is UITapGestureRecognizer else { return true }

        let tapLocation = gestureRecognizer.location(in: self)
        let index = self.indexOfAttributedTextCharacterAtPoint(point: tapLocation)
        return viewModel.inputs.shouldTapBeHandeled(at: index)
    }
}
