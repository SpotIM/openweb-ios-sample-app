//
//  OWCommentStatusIndicationView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWCommentStatusIndicationView: OWBaseView {
    private let iconImageView: OWBaseUIImageView = {
        let imageView = OWBaseUIImageView()
        imageView.image = UIImage(spNamed: "pendingIcon")
        return imageView
    }()
    
    private let statusTextLabel: OWBaseLabel = {
        let label = OWBaseLabel()
        label.textColor = .steelGrey
        label.text = "TODO!!!!"
        label.font = UIFont.preferred(style: .regular, of: Metrics.fontSize)
        return label
    }()
    
    private let statusExplanationButton: OWBaseButton = {
        let btn = OWBaseButton()
        btn.setTitle("Why?"/*LocalizationManager.localizedString(key: "Why?")*/, for: .normal)
        btn.setTitleColor(.brandColor, for: .normal)
        btn.titleLabel?.font = UIFont.preferred(style: .regular, of: Metrics.fontSize)
//        btn.addTarget(self, action: #selector(presentAuth), for: .touchUpInside)
        return btn
    }()
    
    fileprivate var viewModel: OWCommentStatusIndicationViewModeling!
    fileprivate var disposeBag: DisposeBag!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    func configure(with viewModel: OWCommentStatusIndicationViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        setupObservers()
    }

    func setupObservers() {
        viewModel.outputs.indicationIcon
            .bind(to: iconImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.outputs.indicationText
            .bind(to: statusTextLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        self.backgroundColor = .iceBlue
        self.addCornerRadius(4)
        self.addSubviews(iconImageView, statusTextLabel, statusExplanationButton)
        
        iconImageView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.iconLeadingOffset)
            make.top.equalToSuperview().offset(Metrics.iconVerticalPadding)
            make.bottom.equalToSuperview().offset(-Metrics.iconVerticalPadding)
            make.width.height.equalTo(Metrics.iconSize)
        }
        
        statusTextLabel.OWSnp.makeConstraints { make in
            make.leading.equalTo(iconImageView.OWSnp.trailing).offset(Metrics.statusTextLeadingOffset)
            make.centerY.equalToSuperview()
        }
        
        statusExplanationButton.OWSnp.makeConstraints { make in
            make.leading.equalTo(statusTextLabel.OWSnp.trailing).offset(Metrics.explanationButtonLeadingOffset)
            make.centerY.equalToSuperview()
        }
    }
}

fileprivate struct Metrics {
    static let iconSize: CGFloat = 14

    static let iconLeadingOffset: CGFloat = 10
    static let iconVerticalPadding: CGFloat = 12
    static let statusTextLeadingOffset: CGFloat = 8
    static let explanationButtonLeadingOffset: CGFloat = 10
    
    static let fontSize: CGFloat = 15
    
}
