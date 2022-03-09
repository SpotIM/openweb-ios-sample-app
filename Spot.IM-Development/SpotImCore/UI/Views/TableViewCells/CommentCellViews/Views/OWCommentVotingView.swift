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
        static let height: CGFloat = 33
        static let fontSize: CGFloat = 16.0
        static let rankButtonVerticalInset: CGFloat = 6.0
        static let rankButtonHorizontalInset: CGFloat = 3.0
        static let rankUpButtonOffset: CGFloat = 3.0
        static let rankDownButtonOffset: CGFloat = -3.0
    }
    
    fileprivate var viewModel: OWCommentVotingViewModeling!
    fileprivate var disposeBag: DisposeBag!
    
    weak var delegate: CommentActionsDelegate?
    
    var rankedByUser: Int = 0
    
    fileprivate lazy var stackView: OWBaseStackView = {
        let stackView = OWBaseStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()
    
    fileprivate lazy var rankUpButton: SPAnimatedButton = {
        let rankUpNormalImage = UIImage(spNamed: "rank_up_normal", supportDarkMode: false)
        let rankUpSelectedImage = UIImage(spNamed: "rank_up_selected", supportDarkMode: false)
        let insets = UIEdgeInsets(
            top: Metrics.rankButtonVerticalInset - Metrics.rankUpButtonOffset,
            left: Metrics.rankButtonHorizontalInset,
            bottom: Metrics.rankButtonVerticalInset + Metrics.rankUpButtonOffset,
            right: Metrics.rankButtonHorizontalInset
        )
        let width = Metrics.height - Metrics.rankButtonHorizontalInset * 2
        let frame = CGRect(x: 0, y: 0, width: width, height: Metrics.height)

        let button = SPAnimatedButton(frame: frame,
                                image: rankUpNormalImage,
                                selectedImage: rankUpSelectedImage,
                                buttonInset: insets)
        
        button.addTarget(self, action: #selector(rankUp), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        
        return button
    }()
    
    fileprivate lazy var rankDownButton: SPAnimatedButton = {
        let rankDownIconNormal = UIImage(spNamed: "rank_down_normal", supportDarkMode: false)
        let rankDownIconSelected = UIImage(spNamed: "rank_down_selected", supportDarkMode: false)
        let insets = UIEdgeInsets(top: Metrics.rankButtonVerticalInset - Metrics.rankDownButtonOffset,
                                  left: Metrics.rankButtonHorizontalInset,
                                  bottom: Metrics.rankButtonVerticalInset + Metrics.rankDownButtonOffset,
                                  right: Metrics.rankButtonHorizontalInset)
        let width = Metrics.height - Metrics.rankButtonHorizontalInset * 2
        let frame = CGRect(x: 0, y: 0, width: width, height: Metrics.height)

        let button = SPAnimatedButton(frame: frame,
                                image: rankDownIconNormal,
                                selectedImage: rankDownIconSelected,
                                buttonInset: insets)
        
        button.addTarget(self, action: #selector(rankDown), for: .touchUpInside)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        applyAccessibility()
        setupUI()
    }
    
    func configure(with viewModel: OWCommentVotingViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        
        confiureViews()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        rankUpButton.backgroundColor = .spBackground0
        rankUpButton.imageColorOff = .buttonTitle
        rankUpLabel.backgroundColor = .spBackground0
        rankUpLabel.textColor = .buttonTitle
        rankDownButton.backgroundColor = .spBackground0
        rankDownButton.imageColorOff = .buttonTitle
        rankDownLabel.backgroundColor = .spBackground0
        rankDownLabel.textColor = .buttonTitle
    }
    
    private func setupUI() {
        self.addSubviews(stackView)
        
        configureStackView()
        configureRankUpButton()
        configureRankDownButton()
    }
    
    private func configureStackView() {
        stackView.OWSnp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
        }
    }
    
    private func configureRankUpButton() {
        stackView.addArrangedSubview(rankUpButton)
        stackView.addArrangedSubview(rankUpLabel)
    }

    private func configureRankDownButton() {
        let view = UIView()
        view.backgroundColor = .lightPink
        stackView.addArrangedSubview(view)
        view.OWSnp.makeConstraints { make in
            make.width.equalTo(10)
        }
        
        stackView.addArrangedSubview(rankDownButton)
        stackView.addArrangedSubview(rankDownLabel)
    }
    
    @objc
    private func rankUp() {
        let from: SPRank = SPRank(rawValue: rankedByUser) ?? .unrank
        let to: SPRank = (rankedByUser == 0 || rankedByUser == -1) ? .up : .unrank
        
        delegate?.rankUp(SPRankChange(from: from, to: to), updateRankLocal: rankUpLocal)
    }
    
    private func rankUpLocal() {
        switch rankedByUser {
        case -1, 0:
            rankUpButton.select()
            rankedByUser = 1
        default:
            rankUpButton.deselect()
            rankedByUser = 0
        }
    }

    @objc
    private func rankDown() {
        let from: SPRank = SPRank(rawValue: rankedByUser) ?? .unrank
        let to: SPRank = (rankedByUser == 0 || rankedByUser == 1) ? .down : .unrank
        
        delegate?.rankDown(SPRankChange(from: from, to: to), updateRankLocal: rankDownLocal)
    }
    
    private func rankDownLocal() {
        switch rankedByUser {
        case 0, 1:
            rankDownButton.select()
            rankedByUser = -1
        default:
            rankDownButton.deselect()
            rankedByUser = 0
        }
    }
}

fileprivate extension OWCommentVotingView {
    func confiureViews() {
        viewModel.outputs.rankUpCount
            .bind(to: rankUpLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.rankDownCount
            .bind(to: rankDownLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.brandColor
            .bind(to: rankUpButton.rx.imageColorOn)
            .disposed(by: disposeBag)
        
        viewModel.outputs.brandColor
            .subscribe(onNext: { [weak self] color in
                guard let self = self else { return }
                self.rankUpButton.imageColorOn = color
                self.rankUpButton.circleColor = color
                self.rankUpButton.lineColor = color
                self.rankDownButton.imageColorOn = color
                self.rankDownButton.circleColor = color
                self.rankDownButton.lineColor = color
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.rankedByUser
            .subscribe(onNext: { [weak self] ranked in
                guard let self = self else { return }
                switch ranked {
                case -1:
                    self.rankUpButton.isSelected = false
                    self.rankDownButton.isSelected = true
                case 1:
                    self.rankUpButton.isSelected = true
                    self.rankDownButton.isSelected = false
                default:
                    self.rankUpButton.isSelected = false
                    self.rankDownButton.isSelected = false
                }
            })
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
