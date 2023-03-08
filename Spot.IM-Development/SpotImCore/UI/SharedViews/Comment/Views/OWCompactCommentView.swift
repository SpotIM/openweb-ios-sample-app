//
//  OWCompactCommentView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 08/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCompactCommentView: UIView {

    fileprivate var viewModel: OWCompactCommentViewModeling!
    fileprivate lazy var avatarImageView: SPAvatarView = {
        return SPAvatarView()
            .backgroundColor(.clear)
    }()

    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    func configure(with viewModel: OWCompactCommentViewModeling) {
        self.viewModel = viewModel
        avatarImageView.configure(with: viewModel.outputs.avatarVM)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCompactCommentView {
    func setupViews() {
        self.addSubview(avatarImageView)
        avatarImageView.OWSnp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
    }
}
