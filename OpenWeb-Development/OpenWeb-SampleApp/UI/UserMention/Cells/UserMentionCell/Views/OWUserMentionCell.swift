//
//  OWUserMentionCell.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 03/03/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import Foundation

class OWUserMentionCell: UITableViewCell {
    fileprivate var disposeBag: DisposeBag!
    fileprivate var viewModel: OWUserMentionCellViewModeling!

    fileprivate struct Metrics {
        static let identifier = "user_mention_cell_id"
        static let titleLabelIdentifier = "user_mention_cell_title_label_id"
        static let subtitleLabelIdentifier = "user_mention_cell_subtitle_label_id"
        static let verticalTextSpace: CGFloat = 2
        static let cellTrailingPadding: CGFloat = 9
        static let cellHeight: CGFloat = 56
        static let avatarLeadingPadding: CGFloat = 16
        static let avatarSize: CGFloat = 40.0
    }

    fileprivate lazy var avatarView: OWAvatarView = {
        return OWAvatarView()
    }()

    fileprivate lazy var viewForText: UIView = {
        let viewForText = UIView()
        return viewForText
    }()

    fileprivate lazy var lblTitle: UILabel = {
        let lblTitle = UILabel()
        return lblTitle
            .textColor(OWColorPalette.shared.color(type: .textColor1, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .font(OWFontBook.shared.font(typography: .bodyText))
            .lineBreakMode(.byWordWrapping)
    }()

    fileprivate lazy var lblSubtitle: UILabel = {
        let lblSubtitle = UILabel()
        return lblSubtitle
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .font(OWFontBook.shared.font(typography: .footnoteText))
                .numberOfLines(2)
                .lineBreakMode(.byTruncatingMiddle)
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    override func prepareForReuse() {
        disposeBag = nil
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    func configure(with viewModel: OWUserMentionCellViewModeling) {
        self.viewModel = viewModel
        setupObservers()
        applyAccessibility()
        avatarView.configure(with: viewModel.outputs.avatarVM)
    }
}

fileprivate extension OWUserMentionCell {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        lblTitle.accessibilityIdentifier = Metrics.titleLabelIdentifier
        lblSubtitle.accessibilityIdentifier = Metrics.subtitleLabelIdentifier
    }

    func setupViews() {
        selectionStyle = .none
        self.backgroundColor = .clear

        contentView.OWSnp.makeConstraints { make in
            make.height.equalTo(Metrics.cellHeight)
            make.edges.equalToSuperview()
        }

        contentView.addSubview(avatarView)
        avatarView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Metrics.avatarLeadingPadding)
            make.centerY.equalToSuperview()
            make.size.equalTo(Metrics.avatarSize)
        }

        contentView.addSubview(viewForText)
        viewForText.OWSnp.makeConstraints { make in
            make.leading.equalTo(avatarView.OWSnp.trailing).offset(Metrics.avatarLeadingPadding)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(Metrics.cellTrailingPadding)
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }

        viewForText.addSubview(lblTitle)
        lblTitle.OWSnp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }

        viewForText.addSubview(lblSubtitle)
        lblSubtitle.OWSnp.makeConstraints { make in
            make.top.equalTo(lblTitle.OWSnp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }

    func setupObservers() {
        disposeBag = DisposeBag()

        viewModel.outputs.displayName
            .bind(to: lblTitle.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.userName
            .bind(to: lblSubtitle.rx.text)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.lblTitle.textColor = OWColorPalette.shared.color(type: .textColor1, themeStyle: currentStyle)
                self.lblSubtitle.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.lblTitle.font = OWFontBook.shared.font(typography: .bodyText)
                self.lblSubtitle.font = OWFontBook.shared.font(typography: .footnoteText)
            })
            .disposed(by: disposeBag)
    }
}
