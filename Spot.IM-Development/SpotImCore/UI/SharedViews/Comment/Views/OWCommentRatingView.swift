//
//  OWCommentRatingView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 28/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentRatingView: UIView {

    fileprivate struct Metrics {
        static let voteButtonSize: CGFloat = 32.0
        static let voteButtonInset: CGFloat = 4.0
        static let fontSize: CGFloat = 16.0
        static let identifier = "comment_voting_view_id"
        static let rankUpButtonIdentifier = "comment_voting_view_rank_up_button_id"
        static let rankDownButtonIdentifier = "comment_voting_view_rank_down_button_id"
        static let rankUpLabelIdentifier = "comment_voting_view_rank_up_label_id"
        static let rankDownLabelIdentifier = "comment_voting_view_rank_down_label_id"
    }

    fileprivate var viewModel: OWCommentRatingViewModeling!
    fileprivate var disposeBag: DisposeBag = DisposeBag()

    fileprivate lazy var stackView: UIStackView = {
        return UIStackView()
            .axis(.horizontal)
            .alignment(.center)
            .backgroundColor(.clear)
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
            .hugContent(axis: .horizontal)
        button.imageColorOff = OWColorPalette.shared.color(type: .foreground3Color, themeStyle: .light)
        button.brandColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: .light)
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
            .hugContent(axis: .horizontal)
        button.imageColorOff = OWColorPalette.shared.color(type: .foreground3Color, themeStyle: .light)
        button.brandColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: .light)
        return button
    }()

    fileprivate lazy var rankUpLabel: UILabel = {
        return UILabel()
            .textAlignment(.center)
            .font(.preferred(style: .regular, of: Metrics.fontSize))
            .hugContent(axis: .horizontal)
            .textColor(OWColorPalette.shared.color(type: .foreground3Color, themeStyle: .light))
    }()

    fileprivate lazy var rankDownLabel: UILabel = {
        return UILabel()
            .textAlignment(.center)
            .font(.preferred(style: .regular, of: Metrics.fontSize))
            .hugContent(axis: .horizontal)
            .textColor(OWColorPalette.shared.color(type: .foreground3Color, themeStyle: .light))
    }()

    fileprivate lazy var seperetorView: UIView = {
        return UIView()
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        applyAccessibility()
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: OWCommentRatingViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()

        setupObservers()
    }

    func prepareForReuse() {
        rankUpButton.deselect()
        rankDownButton.deselect()
    }
}

fileprivate extension OWCommentRatingView {
    func setupUI() {
        self.addSubviews(stackView)

        // stackView
        stackView.OWSnp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
        }
    }

    func configureRankUpButton() {
        stackView.addArrangedSubview(rankUpButton)
        stackView.addArrangedSubview(rankUpLabel)
    }

    func configureSeperatorView() {
        stackView.addArrangedSubview(seperetorView)
        seperetorView.OWSnp.makeConstraints { make in
            make.width.equalTo(10)
        }
    }

    func configureRankDownButton() {
        stackView.addArrangedSubview(rankDownButton)
        stackView.addArrangedSubview(rankDownLabel)
    }

    func setupObservers() {
        viewModel.outputs.rankUpText
            .bind(to: rankUpLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.rankDownText
            .bind(to: rankDownLabel.rx.text)
            .disposed(by: disposeBag)

        let rankUpSelectedObservable = viewModel.outputs.rankUpSelected.share(replay: 1)

        rankUpSelectedObservable
            .take(1)
            .bind(to: self.rankUpButton.rx.isSelected)
            .disposed(by: disposeBag)

        rankUpSelectedObservable
            .skip(1)
            .subscribe(onNext: { [weak self] selected in
                guard let self = self else { return }
                _ = selected ? self.rankUpButton.select() : self.rankUpButton.deselect()
            })
            .disposed(by: disposeBag)

        let rankDownSelectedObservable = viewModel.outputs.rankDownSelected
            .share(replay: 1)

        rankDownSelectedObservable
            .take(1)
            .bind(to: self.rankDownButton.rx.isSelected)
            .disposed(by: disposeBag)

        rankDownSelectedObservable
            .skip(1)
            .subscribe(onNext: { [weak self] selected in
                guard let self = self else { return }
                _ = selected ? self.rankDownButton.select() : self.rankDownButton.deselect()
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

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.rankUpButton.imageColorOff = OWColorPalette.shared.color(type: .foreground3Color, themeStyle: currentStyle)
                self.rankUpButton.brandColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: currentStyle)
                self.rankDownButton.imageColorOff = OWColorPalette.shared.color(type: .foreground3Color, themeStyle: currentStyle)
                self.rankDownButton.brandColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: currentStyle)
                self.rankUpLabel.textColor = OWColorPalette.shared.color(type: .foreground3Color, themeStyle: currentStyle)
                self.rankDownLabel.textColor = OWColorPalette.shared.color(type: .foreground3Color, themeStyle: currentStyle)
            }).disposed(by: disposeBag)
    }
}

// MARK: Accessibility
fileprivate extension OWCommentRatingView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        rankUpButton.accessibilityIdentifier = Metrics.rankUpButtonIdentifier
        rankDownButton.accessibilityIdentifier = Metrics.rankDownButtonIdentifier
        rankUpLabel.accessibilityIdentifier = Metrics.rankUpLabelIdentifier
        rankDownLabel.accessibilityIdentifier = Metrics.rankDownLabelIdentifier

        rankUpButton.accessibilityTraits = .button
        rankUpButton.accessibilityLabel = LocalizationManager.localizedString(key: "Up vote button")

        rankDownButton.accessibilityTraits = .button
        rankDownButton.accessibilityLabel = LocalizationManager.localizedString(key: "Down vote button")
    }
}
