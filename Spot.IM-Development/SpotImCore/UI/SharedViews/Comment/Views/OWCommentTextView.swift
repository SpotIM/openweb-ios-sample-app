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

class OWCommentTextView: UILabel {
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
}

extension OWCommentTextView: UIGestureRecognizerDelegate {
    
    fileprivate func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delegate = self
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
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
    
    fileprivate func isTarget(substring: String, destinationOf gesture: UIGestureRecognizer) -> Bool {
        guard let string = self.attributedText?.string else { return false }
        
        guard let range = string.range(of: substring, options: [.backwards, .literal]) else { return false }
        let tapLocation = gesture.location(in: self)
        let index = self.indexOfAttributedTextCharacterAtPoint(point: tapLocation)
        
        return range.contains(string.utf16.index(string.utf16.startIndex, offsetBy: index))
    }
    
    fileprivate func checkURLTap(in point: CGPoint) {
        let index = self.indexOfAttributedTextCharacterAtPoint(point: point)
        let url = viewModel.outputs.activeURLs.first { $0.key.contains(index) }?.value

        guard let activeUrl = url else { return }
        viewModel.inputs.urlTap.onNext(activeUrl)
    }
}

fileprivate extension OWCommentTextView {
    func setupObservers() {
        viewModel.outputs.attributedString
            .bind(onNext: { [weak self] attString in
                self?.attributedText = attString
            })
            .disposed(by: disposeBag)
    }
}
