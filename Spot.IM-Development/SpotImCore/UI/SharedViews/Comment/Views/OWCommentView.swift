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
        static let commentLabelTopPadding: CGFloat = 10.0
        static let messageContainerTopOffset: CGFloat = 5.0
    }
    
    fileprivate lazy var commentHeaderView: OWCommentHeaderView = {
        return OWCommentHeaderView()
    }()
    fileprivate lazy var commentLabelView: OWCommentLabelView = {
        return OWCommentLabelView()
    }()
    fileprivate lazy var commentContentView: OWCommentContentView = {
        return OWCommentContentView()
    }()
    
    fileprivate var viewModel: OWCommentViewModeling!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init() {
        super.init(frame: .zero)
        setupUI()
        // setupObservers?
    }
    
    func configure(with viewModel: OWCommentViewModeling) {
        self.viewModel = viewModel
        self.commentHeaderView.configure(with: viewModel.outputs.commentHeaderVM)
        self.commentLabelView.configure(viewModel: viewModel.outputs.commentLabelVM)
        self.commentContentView.configure(with: viewModel.outputs.contentVM)
        
        setupUI()
        setupObservers()
    }
}

fileprivate extension OWCommentView {
    func setupUI() {
        self.backgroundColor = .clear
        self.addSubviews(commentHeaderView, commentLabelView, commentContentView)
        
        commentHeaderView.OWSnp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
        
        commentLabelView.OWSnp.makeConstraints { make in
            make.top.equalTo(commentHeaderView.OWSnp.bottom).offset(Metrics.commentLabelTopPadding)
            make.leading.equalToSuperview()
        }
        
        commentContentView.OWSnp.makeConstraints { make in
            make.top.equalTo(commentLabelView.OWSnp.bottom).offset(Metrics.messageContainerTopOffset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func setupObservers() {
        
    }
}
