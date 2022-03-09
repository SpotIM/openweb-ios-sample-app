//
//  OWCommentActionsView.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 27/09/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// aka Engagement view
final class OWCommentActionsView: OWBaseView {
    
    fileprivate var viewModel: OWCommentActionsViewModeling!
    fileprivate var disposeBag: DisposeBag!

    weak var delegate: CommentActionsDelegate? {
        didSet {
            votingView.delegate = delegate
        }
    }

    private let replyDefaultTitle: String
    
    private let stackView: OWBaseStackView = .init()
    
    private let replyButton: OWBaseButton = .init()
    private let votingView: OWCommentVotingView = .init()
    
    private var isReadOnlyMode: Bool = false

    override init(frame: CGRect) {
        replyDefaultTitle = LocalizationManager.localizedString(key: "Reply")
        super.init(frame: frame)
        
        clipsToBounds = true
        setupUI()
    }
    
    func configure(with viewModel: OWCommentActionsViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()

        votingView.configure(with: viewModel.outputs.votingVM)
    }
    
    func setReadOnlyMode(enabled: Bool) {
        self.isReadOnlyMode = enabled
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        replyButton.backgroundColor = .spBackground0
        replyButton.setTitleColor(.buttonTitle, for: .normal)
        votingView.updateColorsAccordingToStyle()
    }
    
    func setReplyButton(repliesCount: String?, shouldHideButton: Bool = false) {
        var replyButtonTitle: String?
        var isEnabled: Bool = true
        
        switch (self.isReadOnlyMode, repliesCount, shouldHideButton) {
        case (_, _, true), (true, nil, _):
            isEnabled = false
            break
        case (false, _, false):
            isEnabled = true
            replyButtonTitle = replyDefaultTitle
            break
        case (true, .some, false):
            isEnabled = false
            replyButtonTitle = LocalizationManager.localizedString(key: "Replies")
            break
        }
        
        replyButton.isEnabled = isEnabled
        
        if var replyButtonTitle = replyButtonTitle {
            if let repliesCount = repliesCount {
                replyButtonTitle.append(" (\(repliesCount))")
            }
            setShowReplyButton(true)
            replyButton.setTitle(replyButtonTitle, for: .normal)
        } else {
            setShowReplyButton(false)
        }
    }

    // MARK: - Private
    
    private func setShowReplyButton(_ showButton: Bool) {
        if showButton {
            stackView.insertArrangedSubview(replyButton, at: 0)
        } else {
            stackView.removeArrangedSubview(replyButton)
        }
    }

    // MARK: - Private configurations

    private func setupUI() {
        self.addSubview(stackView)
        configureStackView()
        
        configureReplyButton()
        configureVotingView()
        
        updateColorsAccordingToStyle()
    }
    
    private func configureStackView() {
        stackView.axis = .horizontal
        stackView.spacing = Theme.baseOffset
        stackView.alignment = .center
        stackView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configureReplyButton() {
        stackView.addArrangedSubview(replyButton)
        replyButton.addTarget(self, action: #selector(reply), for: .touchUpInside)
        replyButton.titleLabel?.font = .preferred(style: .regular, of: Theme.fontSize)
        replyButton.setTitle(replyDefaultTitle, for: .normal)
    }
    
    private func configureVotingView() {
        stackView.addArrangedSubview(votingView)
    }

    // MARK: - Actions

    @objc
    private func reply() {
        delegate?.reply()
    }
}

// MARK: - Delegate

protocol CommentActionsDelegate: AnyObject {

    func reply()
    func rankUp(_ rankChange: SPRankChange, updateRankLocal: () -> Void)
    func rankDown(_ rankChange: SPRankChange, updateRankLocal: () -> Void)

}

// MARK: - Theme

private enum Theme {
    static let fontSize: CGFloat = 16.0
    static let baseOffset: CGFloat = 14
}
