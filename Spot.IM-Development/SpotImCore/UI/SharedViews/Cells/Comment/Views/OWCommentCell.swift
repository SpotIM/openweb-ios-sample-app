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
    fileprivate lazy var commentHeaderView: OWCommentHeaderView = {
        return OWCommentHeaderView()
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
        self.commentHeaderView.configure(with: self.viewModel.outputs.commentVM.outputs.commentHeaderVM as! OWCommentHeaderViewModeling)
        setupUI()
        setupObservers()
    }
}

fileprivate extension OWCommentCell {
    func setupUI() {
        self.backgroundColor = .clear
        self.addSubviews(commentHeaderView)
        commentHeaderView.OWSnp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    func setupObservers() {
        
    }
}
