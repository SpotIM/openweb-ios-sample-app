//
//  OWPreConversationHeaderView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 24/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWPreConversationHeaderView: UIView {
    fileprivate struct Metrics {
        static let counterLeading: CGFloat = 5
        static let titleFontSize: CGFloat = 25
        static let counterFontSize: CGFloat = 16
        static let margins: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)
        static let identifier = "pre_conversation_header_view_id"
    }
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferred(style: .bold, of: Metrics.titleFontSize)
        lbl.textColor = .spForeground0
        lbl.text = LocalizationManager.localizedString(key: "Conversation")
        return lbl
    }()
    
    private lazy var counterLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferred(style: .regular, of: Metrics.counterFontSize)
        lbl.textColor = .spForeground1
        return lbl
    }()
    
    private lazy var onlineViewingUsersView: OWOnlineViewingUsersCounterView = {
        return OWOnlineViewingUsersCounterView(viewModel: viewModel.outputs.onlineViewingUsersVM)
    }()
    
    fileprivate var viewModel: OWPreConversationHeaderViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    init(viewModel: OWPreConversationHeaderViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.accessibilityIdentifier = Metrics.identifier
        setupUI()
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateCustomUI() {
        // TODO: use VM for UI customization
    }
}

fileprivate extension OWPreConversationHeaderView {
    func setupUI() {
        self.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(Metrics.margins.left)
        }
        
        self.addSubview(counterLabel)
        counterLabel.OWSnp.makeConstraints { make in
            make.firstBaseline.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.OWSnp.trailing).offset(Metrics.counterLeading)
            make.trailing.lessThanOrEqualToSuperview()
        }
        
        self.addSubview(onlineViewingUsersView)
        onlineViewingUsersView.OWSnp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-Metrics.margins.right)
        }
    }
    
    func setupObservers() {
        viewModel.outputs.commentsCount
            .startWith("")
            .bind(to: counterLabel.rx.text)
            .disposed(by: disposeBag)
        
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.backgroundColor = .clear
                self.titleLabel.textColor = .spForeground0
                self.counterLabel.textColor = .spForeground1
                self.updateCustomUI()
            }).disposed(by: disposeBag)
    }
}

