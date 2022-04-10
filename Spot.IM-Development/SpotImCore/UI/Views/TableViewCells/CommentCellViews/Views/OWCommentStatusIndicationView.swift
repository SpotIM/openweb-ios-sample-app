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
        label.numberOfLines = 0
        label.textColor = .steelGrey
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.preferred(style: .regular, of: Metrics.fontSize)
        return label
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
        self.addSubviews(iconImageView, statusTextLabel)
        
        iconImageView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.iconLeadingOffset)
            make.top.equalToSuperview().offset(Metrics.iconVerticalPadding)
            make.bottom.equalToSuperview().offset(-Metrics.iconVerticalPadding)
            make.width.height.equalTo(Metrics.iconSize)
        }
        
        statusTextLabel.OWSnp.makeConstraints { make in
            make.leading.equalTo(iconImageView.OWSnp.trailing).offset(Metrics.statusTextLeadingOffset)
            make.trailing.equalToSuperview().offset(-Metrics.statusTextLeadingOffset)
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
