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
        label.text = "TODO!!!!"
        label.font = UIFont.preferred(style: .regular, of: Metrics.fontSize)
        return label
    }()
    
//    private let statusExplanationButton: OWBaseButton = {
//        let btn = OWBaseButton()
//        btn.setTitle(LocalizationManager.localizedString(key: "Why?"), for: .normal)
//        btn.setTitleColor(.brandColor, for: .normal)
//        btn.titleLabel?.font = UIFont.preferred(style: .regular, of: Metrics.fontSize)
////        btn.addTarget(self, action: #selector(presentAuth), for: .touchUpInside)
//        return btn
//    }()
    
    fileprivate var viewModel: OWCommentStatusIndicationViewModeling!
    fileprivate var disposeBag: DisposeBag!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupGestureRecognizer()
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
            .subscribe(onNext: { text in
                self.setLabelText(with: text)
            })
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
        
//        statusExplanationButton.OWSnp.makeConstraints { make in
//            make.leading.equalTo(statusTextLabel.OWSnp.trailing).offset(Metrics.explanationButtonLeadingOffset)
//            make.centerY.equalToSuperview()
//        }
    }
    
    private func setLabelText(with text: String) {
        let attributedMessage = NSMutableAttributedString(
            string: text + " ",
            attributes: [
                .font: UIFont.preferred(style: .regular, of: Metrics.fontSize),
                .foregroundColor: UIColor.steelGrey
            ])
        
        attributedMessage.append(NSAttributedString(
            string: LocalizationManager.localizedString(key: "Why?"),
            attributes: [
                .font: UIFont.preferred(style: .regular, of: Metrics.fontSize),
                .foregroundColor: UIColor.brandColor,
            ]))
        attributedMessage.clippedToLine(index: 0, width: 0, clippedTextSettings: SPClippedTextSettings(collapsed: false, edited: false))
        self.statusTextLabel.attributedText = attributedMessage
    }
    
    private func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delegate = self
        statusTextLabel.addGestureRecognizer(tap)
        statusTextLabel.isUserInteractionEnabled = true
    }
    
    @objc
    private func handleTap(gesture: UITapGestureRecognizer) {
        let statusExplanationButtonText = LocalizationManager.localizedString(key: "Why?")
        
        if isTarget(substring: statusExplanationButtonText, destinationOf: gesture) {
            // TODO
        }
    }
    
    private func didHitCustomTarget(with recognizer: UIGestureRecognizer) -> Bool {
        let statusExplanationButtonText = LocalizationManager.localizedString(key: "Why?")

        if isTarget(substring: statusExplanationButtonText, destinationOf: recognizer) {
            return true
        }
        return false
    }
    
    private func isTarget(substring: String, destinationOf gesture: UIGestureRecognizer) -> Bool {
        guard let string = statusTextLabel.attributedText?.string else { return false }
        
        guard let range = string.range(of: substring, options: [.backwards, .literal]) else { return false }
        let tapLocation = gesture.location(in: statusTextLabel)
        let index = statusTextLabel.indexOfAttributedTextCharacterAtPoint(point: tapLocation)
        
        return range.contains(string.utf16.index(string.utf16.startIndex, offsetBy: index))
    }
}

extension OWCommentStatusIndicationView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let statusExplanationButtonText = LocalizationManager.localizedString(key: "Why?")

        if isTarget(substring: statusExplanationButtonText, destinationOf: gestureRecognizer) {
            return true
        }
        return false
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
