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
        label.font = UIFont.preferred(style: .regular, of: Metrics.fontSize)
        return label
    }()
    
    fileprivate var viewModel: OWCommentStatusIndicationViewModeling!
    fileprivate var disposeBag: DisposeBag!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    func updateColorsAccordingToStyle() {
        statusTextLabel.textColor = .commentStatusIndicatorText
        self.backgroundColor = .commentStatusIndicatorBackground
    }
    
    func configure(with viewModel: OWCommentStatusIndicationViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        setupObservers()
    }
    
    struct Metrics {
        static let iconSize: CGFloat = 14

        static let iconLeadingOffset: CGFloat = 12
        static let iconTopPadding: CGFloat = 14
        static let textVerticalPadding: CGFloat = 12
        static let statusTextHorizontalOffset: CGFloat = 8
        
        static let fontSize: CGFloat = 15
        
    }
}

fileprivate extension OWCommentStatusIndicationView {
    func setupObservers() {
        viewModel.outputs.indicationIcon
            .bind(to: iconImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.outputs.indicationText
            .bind(to: statusTextLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func setupUI() {
        self.addCornerRadius(4)
        self.addSubviews(iconImageView, statusTextLabel)
        
        iconImageView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.iconLeadingOffset)
            make.top.equalToSuperview().offset(Metrics.iconTopPadding)
            make.width.height.equalTo(Metrics.iconSize)
        }
        
        statusTextLabel.OWSnp.makeConstraints { make in
            make.leading.equalTo(iconImageView.OWSnp.trailing).offset(Metrics.statusTextHorizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.statusTextHorizontalOffset)
            make.top.equalToSuperview().offset(Metrics.textVerticalPadding)
            make.bottom.equalToSuperview().offset(-Metrics.textVerticalPadding)
        }
    }
}
