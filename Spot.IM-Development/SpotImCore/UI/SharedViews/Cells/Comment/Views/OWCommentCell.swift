//
//  OWCommentCell.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 05/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

class OWCommentCell: UITableViewCell {
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
    
    fileprivate var viewModel: OWCommentCellViewModeling!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWCommentCellViewModeling else { return }
        
        self.viewModel = vm
        self.commentHeaderView.configure(with: self.viewModel.outputs.commentVM.outputs.commentHeaderVM!)
        self.commentLabelView.configure(viewModel: self.viewModel.outputs.commentVM.outputs.commentLabelVM!)
        self.commentContentView.configure(with: self.viewModel.outputs.commentVM.outputs.contentVM!)
        
        setupUI()
        setupObservers()
    }
}

fileprivate extension OWCommentCell {
    func setupUI() {
        self.backgroundColor = .clear
        self.addSubviews(commentHeaderView, commentLabelView, commentContentView)
        
        commentHeaderView.OWSnp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(50) // TODO: remove
        }
        
        commentLabelView.OWSnp.makeConstraints { make in
            make.top.equalTo(commentHeaderView.OWSnp.bottom).offset(Metrics.commentLabelTopPadding)
            make.leading.equalToSuperview()
        }
        
        commentContentView.OWSnp.makeConstraints { make in
            make.top.equalTo(commentLabelView.OWSnp.bottom).offset(Metrics.messageContainerTopOffset) // TODO!
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func setupObservers() {
        
    }
}
