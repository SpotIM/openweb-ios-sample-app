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
        
    }
    
    fileprivate lazy var headerView: OWCommentUserView = {
        let vm = viewModel.outputs.commentUserVM
        return OWCommentUserView() // TODO - Pass the VM
    }()
    
    fileprivate lazy var statusView: OWCommentStatusIndicationView = {
        let vm = viewModel.outputs.statusIndicationVM
        return OWCommentStatusIndicationView() // TODO - Pass the VM
    }()
    
    fileprivate lazy var contentView: OWCommentContentView = {
        let vm = viewModel.outputs.contentVM
        return OWCommentContentView(viewModel: vm)
    }()
    
    fileprivate lazy var actionsView: OWCommentActionsView = {
        let vm = viewModel.outputs.commentActionsVM
        return OWCommentActionsView() // TODO - Pass the VM
    }()
    
    fileprivate let viewModel: OWCommentViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(viewModel: OWCommentViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
    }
}

fileprivate extension OWCommentView {
    func setupViews() {
        addSubview(headerView)
        headerView.OWSnp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
        }
        
        addSubview(statusView)
        statusView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(headerView.OWSnp.bottom)
        }
        
        addSubview(contentView)
        contentView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(statusView.OWSnp.bottom)
            make.bottom.equalTo(actionsView.OWSnp.top)
        }

        addSubview(actionsView)
        actionsView.OWSnp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
        }

    }
    
    func setupObservers() {

    }
}
