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
        lbl.textColor = OWColorPalette.shared.color(type: .foreground0Color,
                                                    themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
        lbl.text = LocalizationManager.localizedString(key: "Conversation")
        return lbl
    }()
    
    private lazy var counterLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferred(style: .regular, of: Metrics.counterFontSize)
        lbl.textColor = OWColorPalette.shared.color(type: .foreground1Color,
                                                    themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
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
        viewModel.inputs.customizeTitleLabelUI.onNext(titleLabel)
        viewModel.inputs.customizeCounterLabelUI.onNext(counterLabel)
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
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                
                self.titleLabel.textColor = OWColorPalette.shared.color(type: .foreground0Color,
                                                                        themeStyle: currentStyle)
                self.counterLabel.textColor = OWColorPalette.shared.color(type: .foreground1Color,
                                                                          themeStyle: currentStyle)
                self.updateCustomUI()
            }).disposed(by: disposeBag)
    }
}

