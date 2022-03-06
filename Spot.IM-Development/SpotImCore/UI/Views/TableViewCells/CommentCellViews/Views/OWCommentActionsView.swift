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
    private let replyButton: OWBaseButton = .init()
    private let votingView: OWCommentVotingView = .init()
    
    private var replyActionViewWidthConstraint: OWConstraint?
    private var replyButtonTrailingConstraint: OWConstraint?
    
    private var isReadOnlyMode: Bool = false

    private var rankedByUser: Int = 0 {
        didSet {
            votingView.rankedByUser = rankedByUser
        }
    }

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

    func setBrandColor(_ color: UIColor) {
        votingView.setBrandColor(color)
    }

    func setRankUp(_ rank: Int) {
        votingView.setRankUp(rank)
    }

    func setRankDown(_ rank: Int) {
        votingView.setRankDown(rank)
    }

    func setRanked(with rankedByUser: Int?) {
        if let ranked = rankedByUser, ranked <= 1, ranked >= -1 {
            self.rankedByUser = ranked
        } else {
            self.rankedByUser = 0
        }
    }

    // MARK: - Private
    
    private func setShowReplyButton(_ showButton: Bool) {
        showButton ? replyActionViewWidthConstraint?.deactivate() : replyActionViewWidthConstraint?.activate()
        replyButtonTrailingConstraint?.update(offset: showButton ? -Theme.baseOffset : 0.0)
    }

    // MARK: - Private configurations

    private func setupUI() {
        addSubviews(replyButton, votingView)
        configureReplyButton()
        configureVotingView()
        updateColorsAccordingToStyle()
    }

    private func configureReplyButton() {
        replyButton.addTarget(self, action: #selector(reply), for: .touchUpInside)
        replyButton.titleLabel?.font = .preferred(style: .regular, of: Theme.fontSize)
        replyButton.setTitle(replyDefaultTitle, for: .normal)
        
        replyButton.OWSnp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            replyButtonTrailingConstraint = make.trailing.equalTo(votingView.OWSnp.leading).offset(-Theme.baseOffset).constraint
            replyActionViewWidthConstraint = make.width.equalTo(0.0).constraint
            replyActionViewWidthConstraint?.deactivate()
        }
    }
    
    private func configureVotingView() {
        votingView.OWSnp.makeConstraints { make in
            make.centerY.equalTo(replyButton)
            make.top.bottom.trailing.equalToSuperview()
        }
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
    static let engagementStackHeight: CGFloat = 33
    static let baseOffset: CGFloat = 14
}
