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
    
    var rankedByUser: Int = 0 {
        didSet {
            updateRankButtonState()
        }
    }
    
    private let stackView: OWBaseStackView = .init()
    
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
    
    func setBrandColor(_ color: UIColor) {
        rankUpButton.imageColorOn = color
        rankUpButton.circleColor = color
        rankUpButton.lineColor = color
        rankDownButton.imageColorOn = color
        rankDownButton.circleColor = color
        rankDownButton.lineColor = color
    }

    func setRankUp(_ rank: Int) {
        rankUpLabel.text = rank.kmFormatted
    }

    func setRankDown(_ rank: Int) {
        rankDownLabel.text = rank.kmFormatted
    }
    
    func updateRankButtonState() {
        switch rankedByUser {
        case -1:
            rankUpButton.isSelected = false
            rankDownButton.isSelected = true
        case 1:
            rankUpButton.isSelected = true
            rankDownButton.isSelected = false
        default:
            rankUpButton.isSelected = false
            rankDownButton.isSelected = false
        }
    }
    
    private func setupUI() {
        self.addSubviews(stackView)
        
        configureStackView()
        configureRankUpButton()
        configureRankDownButton()
    }
    
    private func configureStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .center
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

// MARK: Accessibility

extension OWCommentVotingView {
    func applyAccessibility() {
        rankUpButton.accessibilityTraits = .button
        rankUpButton.accessibilityLabel = LocalizationManager.localizedString(key: "Up vote button")
        
        rankDownButton.accessibilityTraits = .button
        rankDownButton.accessibilityLabel = LocalizationManager.localizedString(key: "Down vote button")
    }
}
