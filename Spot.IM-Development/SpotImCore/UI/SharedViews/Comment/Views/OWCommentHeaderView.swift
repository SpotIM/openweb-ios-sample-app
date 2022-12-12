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
        static let userViewHeight: CGFloat = 44.0
        static let userViewExpandedHeight: CGFloat = 69.0
        static let avatarSideSize: CGFloat = 39.0
        static let avatarImageViewTrailingOffset: CGFloat = 11.0
        static let usernameFontSize: CGFloat = 16.0
    }
    
    fileprivate var viewModel: OWCommentHeaderViewModeling!
    fileprivate var disposeBag: DisposeBag!
        
    fileprivate let avatarImageView: SPAvatarView = SPAvatarView()
    
    fileprivate lazy var userNameLabel: UILabel = {
        return UILabel()
    }()
    
    private let userNameView: UserNameView = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
     // TODO: empty init + configure should be deleted once refactor is done
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: OWCommentHeaderViewModeling) {
        self.viewModel = model
        avatarImageView.configure(with: viewModel.outputs.avatarVM)
        
        disposeBag = DisposeBag()
        setupObservers()
//        userNameView.configure(with: viewModel.outputs.userNameVM)

//        let userViewHeight = model.usernameViewHeight()
//        userNameView.OWSnp.updateConstraints { make in
//            make.height.equalTo(userViewHeight)
//        }
    }
    
    func setDelegate(_ delegate: SPCommentCellDelegate?) {
        guard let delegate = delegate,
              let vm = self.viewModel
        else { return }
//        vm.inputs.setDelegate(delegate)
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
//        userNameView.updateColorsAccordingToStyle()
        avatarImageView.updateColorsAccordingToStyle()
    }
}

fileprivate extension OWCommentHeaderView {
    func setupViews() {
        addSubviews(avatarImageView, userNameLabel)
        
        // Setup avatar
        avatarImageView.OWSnp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.trailing.equalTo(userNameLabel.OWSnp.leading).offset(-Metrics.avatarImageViewTrailingOffset)
            make.size.equalTo(Metrics.avatarSideSize)
        }
        
        // Setup user name view
//        userNameView.OWSnp.makeConstraints { make in
//            make.trailing.top.equalToSuperview()
//            make.height.equalTo(Metrics.userViewHeight)
//        }
        userNameLabel.OWSnp.makeConstraints { make in
            make.trailing.top.equalToSuperview()
        }
    }
    
    func setupObservers() {
        viewModel.outputs.nameText
            .bind(to: userNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.nameTextStyle
            .subscribe(onNext: { [weak self] style in
                guard let self = self else { return }
                self.userNameLabel.font(
                    .preferred(style: style, of: Metrics.usernameFontSize)
                )
            }).disposed(by: disposeBag)
    }
}
