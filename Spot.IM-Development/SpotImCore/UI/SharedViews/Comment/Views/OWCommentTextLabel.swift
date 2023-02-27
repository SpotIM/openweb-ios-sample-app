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

    init() {
        super.init(frame: .zero)
        setupGestureRecognizer()
    }

    func configure(with viewModel: OWCommentTextViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        setupObservers()
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

extension OWCommentTextLabel: UIGestureRecognizerDelegate {
    @objc
    func handleTap(gesture: UITapGestureRecognizer) {
        if isTarget(substring: viewModel.outputs.readMoreText, destinationOf: gesture) {
            viewModel.inputs.readMoreTap.onNext()
        } else if isTarget(substring: viewModel.outputs.readLessText, destinationOf: gesture) {
            viewModel.inputs.readLessTap.onNext()
        } else {
            checkURLTap(in: gesture.location(in: self))
        }
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
    }

    func isTarget(substring: String, destinationOf gesture: UIGestureRecognizer) -> Bool {
        guard let string = self.attributedText?.string else { return false }
        guard let range = string.range(of: substring, options: [.backwards, .literal]) else { return false }

        let tapLocation = gesture.location(in: self)
        let index = self.indexOfAttributedTextCharacterAtPoint(point: tapLocation)

        return range.contains(string.utf16.index(string.utf16.startIndex, offsetBy: index))
    }

    func checkURLTap(in point: CGPoint) {
        let index = self.indexOfAttributedTextCharacterAtPoint(point: point)
        let url = viewModel.outputs.availableUrlsRange.first { $0.key.contains(index) }?.value

        guard let activeUrl = url else { return }
        viewModel.inputs.urlTap.onNext(activeUrl)
    }

    func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delegate = self
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
}
