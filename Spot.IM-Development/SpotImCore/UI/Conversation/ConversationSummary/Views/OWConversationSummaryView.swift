//
//  OWConversationSummaryView.swift
//  SpotImCore
//
//  Created by Revital Pisman on 08/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OWConversationSummaryView: UIView {
    fileprivate struct Metrics {
        static let commentsCountFontSize: CGFloat = 15.0
        static let sideOffset: CGFloat = 16.0
        static let horizontalMarginBetweenSeparator: CGFloat = 9.5
        static let topMarginBetweenSeparator: CGFloat = 13.5
        static let separatorHeight: CGFloat = 1.0
        static let separatorWidth: CGFloat = 1.0
        static let identifier = "conversation_header_view_id"
        static let commentsCountLabelIdentifier = "comments_count_label_id"
    }

    fileprivate lazy var commentsCountLabel: UILabel = {
        return UILabel()
            .enforceSemanticAttribute()
            .font(OWFontBook.shared.font(style: .regular,
                                         size: Metrics.commentsCountFontSize))
            .textColor(OWColorPalette.shared.color(type: .textColor2,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var verticalSeparatorBetweenCommentsAndViewingUsers: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor2,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var onlineViewingUsersView: OWOnlineViewingUsersCounterView = {
        return OWOnlineViewingUsersCounterView(viewModel: viewModel.outputs.onlineViewingUsersVM)
    }()

    fileprivate lazy var conversationSortView: OWConversationSortView = {
        return OWConversationSortView(viewModel: viewModel.outputs.conversationSortVM)
    }()

    fileprivate lazy var bottomHorizontalSeparator: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor1, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate var viewModel: OWConversationSummaryViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: OWConversationSummaryViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.accessibilityIdentifier = Metrics.identifier
        setupUI()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWConversationSummaryView {
    func setupUI() {
        self.enforceSemanticAttribute()

        // Setup comments label
        self.addSubview(commentsCountLabel)
        commentsCountLabel.OWSnp.makeConstraints { make in
            // avoide device notch in landscape
            if #available(iOS 11.0, *) {
                make.leading.equalTo(safeAreaLayoutGuide).offset(Metrics.sideOffset)
            } else {
                make.leading.equalToSuperview().offset(Metrics.sideOffset)
            }
            make.top.bottom.equalToSuperview()
        }

        // Setup vertical separator between comments and viewingUsers
        self.addSubview(verticalSeparatorBetweenCommentsAndViewingUsers)
        verticalSeparatorBetweenCommentsAndViewingUsers.OWSnp.makeConstraints { make in
            make.leading.equalTo(commentsCountLabel.OWSnp.trailing).offset(Metrics.horizontalMarginBetweenSeparator)
            make.bottom.equalToSuperview().offset(-Metrics.topMarginBetweenSeparator)
            make.top.equalToSuperview().offset(Metrics.topMarginBetweenSeparator)
            make.width.equalTo(Metrics.separatorWidth)
        }

        // Setup online viewing users
        self.addSubview(onlineViewingUsersView)
        onlineViewingUsersView.OWSnp.makeConstraints { make in
            make.leading.equalTo(verticalSeparatorBetweenCommentsAndViewingUsers.OWSnp.trailing).offset(Metrics.horizontalMarginBetweenSeparator)
            make.centerY.equalToSuperview()
        }

        // Setup sort button
        self.addSubviews(conversationSortView)
        conversationSortView.OWSnp.makeConstraints { make in
            // avoide device notch in landscape
            if #available(iOS 11.0, *) {
                make.trailing.equalTo(safeAreaLayoutGuide).offset(-Metrics.sideOffset)
            } else {
                make.trailing.equalToSuperview().offset(-Metrics.sideOffset)
            }
            make.top.bottom.equalToSuperview()
        }

        // Setup bottom horizontal separator
        self.addSubview(bottomHorizontalSeparator)
        bottomHorizontalSeparator.OWSnp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Metrics.separatorHeight)
        }
    }

    func setupObservers() {
        viewModel.outputs.commentsCount
            .startWith("")
            .bind(to: commentsCountLabel.rx.text)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.commentsCountLabel.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.verticalSeparatorBetweenCommentsAndViewingUsers.backgroundColor(OWColorPalette.shared.color(type: .separatorColor2, themeStyle: currentStyle))
                self.bottomHorizontalSeparator.backgroundColor(OWColorPalette.shared.color(type: .separatorColor1, themeStyle: currentStyle))
                self.updateCustomUI()
            })
            .disposed(by: disposeBag)
    }

    func updateCustomUI() {
        viewModel.inputs.triggerCustomizeCounterLabelUI.onNext(commentsCountLabel)
    }

    func applyAccessibility() {
        commentsCountLabel.accessibilityIdentifier = Metrics.commentsCountLabelIdentifier
    }
}

