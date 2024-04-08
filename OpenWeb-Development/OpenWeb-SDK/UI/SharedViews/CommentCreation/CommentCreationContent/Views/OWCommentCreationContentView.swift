//
//  OWCommentCreationContentView.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 03/07/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWCommentCreationContentView: UIView {
    fileprivate struct Metrics {
        static let identifier = "comment_creation_content_id"
        static let placeholderLabelIdentifier = "comment_creation_placeholder_label_id"
        static let prefixIdentifier = "comment_creation_content"

        static let placeholderLabelTopOffset: CGFloat = 8.0
        static let placeholderLabelLeadingOffset: CGFloat = 6.0
        static let horizontalOffset: CGFloat = 16.0
        static let verticalOffset: CGFloat = 12.0
        static let avatarSize: CGFloat = 40.0
        static let avatarToInputSpacing: CGFloat = 13.0
        static let becomeFirstResponderDelay = 0 // miliseconds
    }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: OWCommentCreationContentViewModeling

    fileprivate lazy var avatarView: OWAvatarView = {
        return OWAvatarView()
    }()

    fileprivate lazy var textInput: OWTextView = {
        let textView = OWTextView(viewModel: viewModel.outputs.textViewVM,
                          prefixIdentifier: Metrics.prefixIdentifier)
        textView.layer.borderColor = UIColor.clear.cgColor
        return textView
    }()

    fileprivate lazy var imagePreview: OWCommentCreationImagePreviewView = {
        return OWCommentCreationImagePreviewView(with: viewModel.outputs.imagePreviewVM)
    }()

    fileprivate lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
            .enforceSemanticAttribute()

        scroll.isUserInteractionEnabled = true

        scroll.contentLayoutGuide.OWSnp.makeConstraints { make in
            make.width.equalTo(scroll)
        }

        scroll.addSubview(avatarView)
        avatarView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.verticalOffset)
            make.leading.equalTo(scroll.contentLayoutGuide).offset(Metrics.horizontalOffset)
            make.size.equalTo(Metrics.avatarSize)
        }

        scroll.addSubview(textInput)
        textInput.OWSnp.makeConstraints { make in
            make.leading.equalTo(avatarView.OWSnp.trailing).offset(Metrics.avatarToInputSpacing)
            make.trailing.equalTo(scroll.contentLayoutGuide).offset(-Metrics.horizontalOffset)
            make.top.equalToSuperview().offset(Metrics.verticalOffset)
        }

        scroll.addSubviews(imagePreview)
        imagePreview.OWSnp.makeConstraints { make in
            make.top.equalTo(textInput.OWSnp.bottom).offset(Metrics.verticalOffset)
            make.top.greaterThanOrEqualTo(avatarView.OWSnp.bottom).offset(Metrics.verticalOffset)
            make.bottom.equalToSuperview().offset(-Metrics.verticalOffset)
            make.leading.trailing.equalTo(scroll.contentLayoutGuide).inset(Metrics.horizontalOffset)
        }

        return scroll
    }()

    init(with viewModel: OWCommentCreationContentViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        avatarView.configure(with: viewModel.outputs.avatarViewVM)

        setupUI()
        applyAccessibility()

        viewModel.outputs.textViewVM.inputs.becomeFirstResponderCallWithDelay.onNext(Metrics.becomeFirstResponderDelay)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCommentCreationContentView {
    func setupUI() {
        self.enforceSemanticAttribute()

        addSubview(scrollView)
        scrollView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }
}
