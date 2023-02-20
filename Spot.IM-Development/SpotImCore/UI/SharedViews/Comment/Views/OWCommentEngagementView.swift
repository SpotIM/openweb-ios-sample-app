//
//  OWCommentEngagementView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 27/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentEngagementView: UIView {

    fileprivate struct Metrics {
        static let fontSize: CGFloat = 16.0
        static let baseOffset: CGFloat = 14
        static let identifier = "comment_actions_view_id"
        static let replyButtonIdentifier = "comment_actions_view_reply_button_id"
    }

    fileprivate var viewModel: OWCommentEngagementViewModeling!
    fileprivate var disposeBag: DisposeBag = DisposeBag()

    fileprivate lazy var replyButton: UIButton = {
        return UIButton()
            .setTitleColor(OWColorPalette.shared.color(type: .foreground3Color, themeStyle: .light), state: .normal)
            .setTitleFont(.preferred(style: .regular, of: Metrics.fontSize))
    }()

    fileprivate lazy var votingView: OWCommentRatingView = {
        return OWCommentRatingView()
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        replyButton.accessibilityIdentifier = Metrics.replyButtonIdentifier
    }

    func configure(with viewModel: OWCommentEngagementViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        votingView.configure(with: viewModel.outputs.votingVM)
        setupObservers()
    }

    func prepareForReuse() {
        votingView.prepareForReuse()
    }
}

fileprivate extension OWCommentEngagementView {
    func setupUI() {
        self.addSubviews(replyButton, votingView)

        replyButton.OWSnp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
        }

        votingView.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(replyButton.OWSnp.trailing).offset(Metrics.baseOffset)
        }
    }

    func setupObservers() {
        viewModel.outputs.repliesText
            .bind(to: replyButton.rx.title())
            .disposed(by: disposeBag)

        replyButton.rx.tap
            .bind(to: viewModel.inputs.replyClicked)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.replyButton.setTitleColor(OWColorPalette.shared.color(type: .foreground3Color, themeStyle: currentStyle), for: .normal)
            }).disposed(by: disposeBag)
    }
}
