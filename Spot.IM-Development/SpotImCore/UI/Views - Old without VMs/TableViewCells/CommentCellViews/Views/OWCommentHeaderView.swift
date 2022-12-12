//
//  OWCommentHeaderView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class OWCommentHeaderView: UIView {
    
    fileprivate struct Metrics {
        static let topOffset: CGFloat = 14.0
        static let topCollapsedOffset: CGFloat = 38.0
        static let leadingOffset: CGFloat = 16.0
        static let userViewCollapsedHeight: CGFloat = 44.0
        static let userViewExpandedHeight: CGFloat = 69.0
        static let avatarSideSize: CGFloat = 39.0
        static let avatarImageViewTrailingOffset: CGFloat = 11.0
    }
    
    fileprivate var viewModel: OWCommentUserViewModeling!
    fileprivate var disposeBag: DisposeBag!
        
    private let avatarImageView: SPAvatarView = SPAvatarView()
    private let userNameView: UserNameView = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
     // TODO: empty init + configure should be deleted once refactor is done
    init(viewModel: OWCommentUserViewModeling) {
        super.init(frame: .zero)
        setupViews()
        self.viewModel = viewModel
        
        avatarImageView.configure(with: viewModel.outputs.avatarVM)
        userNameView.configure(with: viewModel.outputs.userNameVM)
        
        userNameView.OWSnp.updateConstraints { make in
            make.height.equalTo(44.0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: CommentViewModel) {
        self.viewModel = model.commentUserVM
        disposeBag = DisposeBag()
        
        avatarImageView.configure(with: viewModel.outputs.avatarVM)
        userNameView.configure(with: viewModel.outputs.userNameVM)
        
        let userViewHeight = model.usernameViewHeight()
        userNameView.OWSnp.updateConstraints { make in
            make.height.equalTo(userViewHeight)
        }
    }
    
    func setDelegate(_ delegate: SPCommentCellDelegate?) {
        guard let delegate = delegate,
              let vm = self.viewModel
        else { return }
        vm.inputs.setDelegate(delegate)
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        userNameView.updateColorsAccordingToStyle()
        avatarImageView.updateColorsAccordingToStyle()
    }
}

fileprivate extension OWCommentHeaderView {
    func setupViews() {
        addSubviews(avatarImageView, userNameView)
        
        // Setup avatar
        avatarImageView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(userNameView.OWSnp.leading).offset(-Metrics.avatarImageViewTrailingOffset)
            make.top.equalTo(userNameView)
            make.size.equalTo(Metrics.avatarSideSize)
        }
        
        // Setup user name view
        userNameView.OWSnp.makeConstraints { make in
            make.trailing.top.equalToSuperview()
            make.height.equalTo(Metrics.userViewCollapsedHeight)
        }
    }
}
