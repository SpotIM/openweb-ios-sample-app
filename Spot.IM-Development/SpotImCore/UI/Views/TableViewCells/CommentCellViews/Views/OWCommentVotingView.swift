//
//  OWCommentVotingView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 06/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class OWCommentVotingView: OWBaseView {
    
    fileprivate struct Metrics {
        static let voteButtonSize: CGFloat = 32.0
        static let voteButtonInset: CGFloat = 4.0
        static let fontSize: CGFloat = 16.0
    }
    
    fileprivate var viewModel: OWCommentVotingViewModeling!
    fileprivate var disposeBag: DisposeBag!
    
    fileprivate lazy var stackView: OWBaseStackView = {
        let stackView = OWBaseStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    fileprivate lazy var rankUpButton: SPAnimatedButton = {
        let insets = UIEdgeInsets(
            top: Metrics.voteButtonInset,
            left: Metrics.voteButtonInset,
            bottom: Metrics.voteButtonInset,
            right: Metrics.voteButtonInset
        )
        let frame = CGRect(x: 0, y: 0, width: Metrics.voteButtonSize, height: Metrics.voteButtonSize)
        let button = SPAnimatedButton(frame: frame, buttonInset: insets)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()
    
    fileprivate lazy var rankDownButton: SPAnimatedButton = {
        let insets = UIEdgeInsets(
            top: Metrics.voteButtonInset,
            left: Metrics.voteButtonInset,
            bottom: Metrics.voteButtonInset,
            right: Metrics.voteButtonInset
        )
        let frame = CGRect(x: 0, y: 0, width: Metrics.voteButtonSize, height: Metrics.voteButtonSize)
        let button = SPAnimatedButton(frame: frame, buttonInset: insets)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()
    
    fileprivate lazy var rankUpLabel: OWBaseLabel = {
        let label = OWBaseLabel()
        label.textAlignment = .center
        label.font = .preferred(style: .regular, of: Metrics.fontSize)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    fileprivate lazy var rankDownLabel: OWBaseLabel = {
        let label = OWBaseLabel()
        label.textAlignment = .center
        label.font = .preferred(style: .regular, of: Metrics.fontSize)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    fileprivate lazy var seperetorView: UIView = {
        let view = UIView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        applyAccessibility()
        setupUI()
    }
    
    func configure(with viewModel: OWCommentVotingViewModeling, delegate: CommentActionsDelegate) {
        
        self.viewModel = viewModel
        self.viewModel.inputs.setDelegate(delegate)
        disposeBag = DisposeBag()
        
        setupObservers()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        rankUpButton.backgroundColor = .spBackground0
        rankUpButton.imageColorOff = .buttonTitle
        rankUpLabel.backgroundColor = .clear
        rankUpLabel.textColor = .buttonTitle
        rankDownButton.backgroundColor = .spBackground0
        rankDownButton.imageColorOff = .buttonTitle
        rankDownLabel.backgroundColor = .clear
        rankDownLabel.textColor = .buttonTitle
    }
    
    private func setupUI() {
        self.addSubviews(stackView)
        
        // stackView
        stackView.OWSnp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
        }
    }
    
    private func configureRankUpButton() {
        stackView.addArrangedSubview(rankUpButton)
        stackView.addArrangedSubview(rankUpLabel)
    }
    
    private func configureSeperatorView() {
        stackView.addArrangedSubview(seperetorView)
        seperetorView.OWSnp.makeConstraints { make in
            make.width.equalTo(10)
        }
    }

    private func configureRankDownButton() {
        stackView.addArrangedSubview(rankDownButton)
        stackView.addArrangedSubview(rankDownLabel)
    }
}

fileprivate extension OWCommentVotingView {
    func setupObservers() {
        viewModel.outputs.rankUpText
            .bind(to: rankUpLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.rankDownText
            .bind(to: rankDownLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.brandColor
            .bind(to: self.rankUpButton.rx.brandColor)
            .disposed(by: disposeBag)
        
        viewModel.outputs.brandColor
            .bind(to: self.rankDownButton.rx.brandColor)
            .disposed(by: disposeBag)
        
        viewModel.outputs.rankUpSelected
            .take(1)
            .bind(to: self.rankUpButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        viewModel.outputs.rankUpSelected
            .skip(1)
            .subscribe(onNext: { [weak self] selected in
                guard let self = self else { return }
                selected ? self.rankUpButton.select() : self.rankUpButton.deselect()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.rankDownSelected
            .take(1)
            .bind(to: self.rankDownButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        viewModel.outputs.rankDownSelected
            .skip(1)
            .subscribe(onNext: { [weak self] selected in
                guard let self = self else { return }
                selected ? self.rankDownButton.select() : self.rankDownButton.deselect()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.voteTypes
            .subscribe(onNext: { [weak self] voteTypes in
                guard let self = self else { return }
                if (voteTypes.contains(.voteUp)) {
                    self.configureRankUpButton()
                    self.configureSeperatorView()
                }
                if (voteTypes.contains(.voteDown)) {
                    self.configureRankDownButton()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.votingUpImages
            .subscribe(onNext: { [weak self] (regular: UIImage?, selected: UIImage?) in
                guard let self = self else { return }
                self.rankUpButton.image = regular
                self.rankUpButton.selectedImage = selected
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.votingDownImages
            .subscribe(onNext: { [weak self] (regular: UIImage?, selected: UIImage?) in
                guard let self = self else { return }
                self.rankDownButton.image = regular
                self.rankDownButton.selectedImage = selected
            })
            .disposed(by: disposeBag)
            
        
        rankUpButton.rx.tap
            .bind(to: viewModel.inputs.tapRankUp)
            .disposed(by: disposeBag)
        
        rankDownButton.rx.tap
            .bind(to: viewModel.inputs.tapRankDown)
            .disposed(by: disposeBag)
    }
}

// MARK: Accessibility

fileprivate extension OWCommentVotingView {
    func applyAccessibility() {
        rankUpButton.accessibilityTraits = .button
        rankUpButton.accessibilityLabel = LocalizationManager.localizedString(key: "Up vote button")
        
        rankDownButton.accessibilityTraits = .button
        rankDownButton.accessibilityLabel = LocalizationManager.localizedString(key: "Down vote button")
    }
}
