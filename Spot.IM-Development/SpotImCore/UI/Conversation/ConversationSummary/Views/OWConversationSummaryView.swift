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
        static let leadingOffset: CGFloat = 16
        static let trailingOffset: CGFloat = 8
        static let horizontalMarginBetweenSeparator: CGFloat = 5
        static let topMarginBetweenSeparator: CGFloat = 3.5
        static let separatorHeight: CGFloat = 1
        static let separatorWidth: CGFloat = 1
        static let horizontalMarginBetweenOnlineUsersAndSort: CGFloat = 10

        static let margins: UIEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        static let identifier = "conversation_header_view_id"
        static let commentsCountLabelIdentifier = "comments_count_label_id"
    }

    fileprivate lazy var summaryView: UIView = {
        let view = UIView()
            .enforceSemanticAttribute()

        // Setup comments label
        view.addSubview(commentsCountLabel)
        commentsCountLabel.OWSnp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
        }

        // Setup vertical separator between comments and viewingUsers
        view.addSubview(verticalSeparatorBetweenCommentsAndViewingUsers)
        verticalSeparatorBetweenCommentsAndViewingUsers.OWSnp.makeConstraints { make in
            make.leading.equalTo(commentsCountLabel.OWSnp.trailing).offset(Metrics.horizontalMarginBetweenSeparator)
            make.bottom.equalToSuperview().offset(-Metrics.topMarginBetweenSeparator)
            make.top.equalToSuperview().offset(Metrics.topMarginBetweenSeparator)
            make.width.equalTo(Metrics.separatorWidth)
        }

        // Setup online viewing users
        view.addSubview(onlineViewingUsersView)
        onlineViewingUsersView.OWSnp.makeConstraints { make in
            make.leading.equalTo(verticalSeparatorBetweenCommentsAndViewingUsers.OWSnp.trailing).offset(Metrics.horizontalMarginBetweenSeparator)
            make.centerY.equalToSuperview()
        }

        // Setup sort button
        view.addSubview(conversationSortView)
        conversationSortView.OWSnp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(onlineViewingUsersView.OWSnp.trailing).offset(Metrics.horizontalMarginBetweenOnlineUsersAndSort)
            make.top.bottom.trailing.equalToSuperview()
        }

        return view
    }()

    fileprivate lazy var commentsCountLabel: UILabel = {
        return UILabel()
            .enforceSemanticAttribute()
            .font(OWFontBook.shared.font(typography: .bodyText))
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
            .enforceSemanticAttribute()
            .wrapContent()
    }()

    fileprivate lazy var conversationSortView: OWConversationSortView = {
        return OWConversationSortView(viewModel: viewModel.outputs.conversationSortVM)
            .enforceSemanticAttribute()
            .wrapContent()
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

        // Setup summary
        self.addSubview(summaryView)
        summaryView.OWSnp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide).offset(Metrics.leadingOffset)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-Metrics.trailingOffset)
            make.top.equalToSuperview().offset(Metrics.margins.top)
        }

        // Setup bottom horizontal separator
        self.addSubview(bottomHorizontalSeparator)
        bottomHorizontalSeparator.OWSnp.makeConstraints { make in
            make.top.equalTo(summaryView.OWSnp.bottom).offset(Metrics.margins.bottom)
            make.bottom.leading.trailing.equalToSuperview()
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

                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.commentsCountLabel.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.verticalSeparatorBetweenCommentsAndViewingUsers.backgroundColor(OWColorPalette.shared.color(type: .separatorColor2, themeStyle: currentStyle))
                self.bottomHorizontalSeparator.backgroundColor(OWColorPalette.shared.color(type: .separatorColor1, themeStyle: currentStyle))
                self.updateCustomUI()
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.commentsCountLabel.font = OWFontBook.shared.font(typography: .bodyText)
            })
            .disposed(by: disposeBag)
    }

    func updateCustomUI() {
        viewModel.inputs.triggerCustomizeCounterLabelUI.onNext(commentsCountLabel)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        commentsCountLabel.accessibilityIdentifier = Metrics.commentsCountLabelIdentifier
    }
}

