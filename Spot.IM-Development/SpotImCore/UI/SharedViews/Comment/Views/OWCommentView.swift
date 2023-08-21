//
//  OWCommentView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentView: UIView {
    fileprivate struct Metrics {
        static let leadingOffset: CGFloat = 16.0
        static let bottomOffset: CGFloat = 16.0
        static let commentHeaderVerticalOffset: CGFloat = 12.0
        static let commentStatusBottomPadding: CGFloat = 12.0
        static let commentLabelTopPadding: CGFloat = 10.0
        static let horizontalOffset: CGFloat = 16.0
        static let messageContainerTopOffset: CGFloat = 4.0
        static let commentActionsTopPadding: CGFloat = 15.0
    }

    fileprivate lazy var commentStatusView: OWCommentStatusView = {
        return OWCommentStatusView()
    }()
    fileprivate lazy var commentHeaderView: OWCommentHeaderView = {
        return OWCommentHeaderView()
    }()
    fileprivate lazy var commentLabelsContainerView: OWCommentLabelsContainerView = {
        return OWCommentLabelsContainerView()
    }()
    fileprivate lazy var commentContentView: OWCommentContentView = {
        return OWCommentContentView()
    }()
    fileprivate lazy var commentEngagementView: OWCommentEngagementView = {
        return OWCommentEngagementView()
    }()

    fileprivate var viewModel: OWCommentViewModeling!
    fileprivate var disposedBag = DisposeBag()

    fileprivate var commentHeaderBottomConstraint: OWConstraint? = nil
    fileprivate var commentStatusZeroHeightConstraint: OWConstraint? = nil

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init() {
        super.init(frame: .zero)
        setupUI()
    }

    func configure(with viewModel: OWCommentViewModeling) {
        self.disposedBag = DisposeBag()
        self.viewModel = viewModel
        self.commentStatusView.configure(with: viewModel.outputs.commentStatusVM)
        self.commentHeaderView.configure(with: viewModel.outputs.commentHeaderVM)
        self.commentLabelsContainerView.configure(viewModel: viewModel.outputs.commentLabelsContainerVM)
        self.commentContentView.configure(with: viewModel.outputs.contentVM)
        self.commentEngagementView.configure(with: viewModel.outputs.commentEngagementVM)
        self.setupObservers()
    }

    func prepareForReuse() {
        commentHeaderView.prepareForReuse()
        commentLabelsContainerView.prepareForReuse()
        commentEngagementView.prepareForReuse()
    }
}

fileprivate extension OWCommentView {
    func setupUI() {
        self.backgroundColor = .clear

        self.addSubviews(commentStatusView)
        commentStatusView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(Metrics.commentHeaderVerticalOffset)
            commentStatusZeroHeightConstraint = make.height.equalTo(0).constraint
        }

        self.addSubview(commentHeaderView)
        commentHeaderView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(commentStatusView.OWSnp.bottom).offset(Metrics.commentStatusBottomPadding)
            commentHeaderBottomConstraint = make.bottom.equalToSuperview().offset(-Metrics.commentHeaderVerticalOffset).constraint
        }
    }

    func setupCommentContentUI() {
        self.addSubview(commentLabelsContainerView)
        commentLabelsContainerView.OWSnp.makeConstraints { make in
            make.top.equalTo(commentHeaderView.OWSnp.bottom).offset(Metrics.commentLabelTopPadding)
            make.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }

        self.addSubview(commentContentView)
        commentContentView.OWSnp.makeConstraints { make in
            make.top.equalTo(commentLabelsContainerView.OWSnp.bottom).offset(Metrics.messageContainerTopOffset)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
        }

        self.addSubview(commentEngagementView)
        commentEngagementView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(commentContentView.OWSnp.bottom).offset(Metrics.commentActionsTopPadding)
            make.bottom.equalToSuperview().offset(-Metrics.bottomOffset)
        }
    }

    func setupObservers() {
        viewModel.outputs.shouldHideCommentContent
            .subscribe(onNext: { [weak self] shouldBlockComment in
                guard let self = self else { return }
                if (shouldBlockComment) {
                    self.commentLabelsContainerView.removeFromSuperview()
                    self.commentContentView.removeFromSuperview()
                    self.commentEngagementView.removeFromSuperview()
                } else if (self.commentLabelsContainerView.superview == nil) {
                    self.setupCommentContentUI()
                }
            }).disposed(by: disposedBag)

        if let commentHeaderBottomConstraint = commentHeaderBottomConstraint {
            viewModel.outputs.shouldHideCommentContent
                .bind(to: commentHeaderBottomConstraint.rx.isActive)
                .disposed(by: disposedBag)
        }

        viewModel.outputs.shouldShowCommentStatus
            .subscribe(onNext: { [weak self] shouldShow in
                guard let self = self else { return }
                self.commentHeaderView.OWSnp.updateConstraints { make in
                    make.top.equalTo(self.commentStatusView.OWSnp.bottom).offset(shouldShow ? Metrics.commentStatusBottomPadding : 0)
                }
                self.commentStatusView.isHidden = !shouldShow
                self.commentStatusZeroHeightConstraint?.isActive = !shouldShow
            })
            .disposed(by: disposedBag)
    }
}
