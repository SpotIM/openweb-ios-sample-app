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
final class OWCommentActionsView: SPBaseView {

    fileprivate struct Metrics {
        static let fontSize: CGFloat = 16.0
        static let baseOffset: CGFloat = 14
        static let identifier = "comment_actions_view_id"
        static let replyButtonIdentifier = "comment_actions_view_reply_button_id"
    }

    fileprivate var viewModel: OWCommentActionsViewModeling!
    fileprivate var disposeBag: DisposeBag!

    weak var delegate: CommentActionsDelegate? = nil

    private let replyDefaultTitle: String

    private let stackView: SPBaseStackView = .init()

    private let replyButton: SPBaseButton = .init()
    private let votingView: OWCommentVotingView = .init()

    private var isReadOnlyMode: Bool = false

    override init(frame: CGRect) {
        replyDefaultTitle = SPLocalizationManager.localizedString(key: "Reply")
        super.init(frame: frame)
        clipsToBounds = true
        setupUI()
        applyAccessibility()
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        replyButton.accessibilityIdentifier = Metrics.replyButtonIdentifier
    }

    func configure(with viewModel: OWCommentActionsViewModeling, delegate: CommentActionsDelegate) {
        self.delegate = delegate
        self.viewModel = viewModel
        disposeBag = DisposeBag()

        votingView.configure(with: viewModel.outputs.votingVM, delegate: delegate)
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

    func setIsDisabled(isDisabled: Bool) {
        if (!isReadOnlyMode) {
            replyButton.isEnabled = !isDisabled
        }
        votingView.isUserInteractionEnabled = !isDisabled
    }

    func setReplyButton(repliesCount: String?, shouldHideButton: Bool = false) {
        var replyButtonTitle: String?
        var isEnabled: Bool = true

        switch (self.isReadOnlyMode, repliesCount, shouldHideButton) {
        case (_, _, true), (true, nil, _):
            isEnabled = false

        case (false, _, false):
            isEnabled = true
            replyButtonTitle = replyDefaultTitle

        case (true, .some, false):
            isEnabled = false
            replyButtonTitle = SPLocalizationManager.localizedString(key: "Replies")

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

    func prepareForReuse() {
        votingView.prepareForReuse()
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
        stackView.spacing = Metrics.baseOffset
        stackView.alignment = .center
        stackView.backgroundColor = .clear
        stackView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configureReplyButton() {
        stackView.addArrangedSubview(replyButton)
        replyButton.addTarget(self, action: #selector(reply), for: .touchUpInside)
        replyButton.titleLabel?.font = OWFontBook.shared.font(style: .regular, size: Metrics.fontSize)
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
    func rankUp(_ rankChange: SPRankChange)
    func rankDown(_ rankChange: SPRankChange)

}
