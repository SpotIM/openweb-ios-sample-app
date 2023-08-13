//
//  OWPreConversationSummaryView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 24/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWPreConversationSummaryView: UIView {
    fileprivate struct Metrics {
        static let counterLeading: CGFloat = 8
        static let nextArrowLeading: CGFloat = 10
        static let onlineViewingUsersBottomLeading: CGFloat = 8
        static let onlineViewingUsersBottomOffset: CGFloat = 2
        static let nextArrowIconSize: CGFloat = 20

        static let margins: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        static let identifier = "pre_conversation_summary_view_id"
        static let titleLabelIdentifier = "pre_conversation_title_label_id"
        static let counterLabelIdentifier = "pre_conversation_counter_label_id"
    }

    private lazy var titleLabel: UILabel = {
        return UILabel()
            .enforceSemanticAttribute()
            .font(OWFontBook.shared.font(typography: viewModel.outputs.titleFontTypography))
            .textColor(OWColorPalette.shared.color(type: .textColor1,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .text(OWLocalizationManager.shared.localizedString(key: "Conversation"))
    }()

    private lazy var counterLabel: UILabel = {
        return UILabel()
            .enforceSemanticAttribute()
            .wrapContent(axis: .horizontal)
            .font(OWFontBook.shared.font(typography: viewModel.outputs.counterFontTypography))
            .textColor(OWColorPalette.shared.color(type: .textColor2,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    private lazy var onlineViewingUsersView: OWOnlineViewingUsersCounterView = {
        return OWOnlineViewingUsersCounterView(viewModel: viewModel.outputs.onlineViewingUsersVM)
            .enforceSemanticAttribute()
            .wrapContent(axis: .horizontal)
    }()

    fileprivate lazy var nextArrow: UIImageView = {
        return UIImageView()
            .image(UIImage(spNamed: "nextArrow", supportDarkMode: true)!)
            .enforceSemanticAttribute()
            .wrapContent(axis: .horizontal)
    }()

    fileprivate var viewModel: OWPreConversationSummaryViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: OWPreConversationSummaryViewModeling) {
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

fileprivate extension OWPreConversationSummaryView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        titleLabel.accessibilityIdentifier = Metrics.titleLabelIdentifier
        counterLabel.accessibilityIdentifier = Metrics.counterLabelIdentifier
    }

    func updateCustomUI() {
        viewModel.inputs.triggerCustomizeTitleLabelUI.onNext(titleLabel)
        viewModel.inputs.triggerCustomizeCounterLabelUI.onNext(counterLabel)
    }

    func setupUI() {
        self.enforceSemanticAttribute()

        self.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(Metrics.margins.left)
        }

        self.addSubview(counterLabel)
        counterLabel.OWSnp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.lastBaseline.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.OWSnp.trailing).offset(Metrics.counterLeading)
        }

        self.addSubview(onlineViewingUsersView)
        onlineViewingUsersView.OWSnp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.equalTo(counterLabel).offset(-Metrics.onlineViewingUsersBottomOffset)
            make.leading.greaterThanOrEqualTo(counterLabel.OWSnp.trailing).offset(Metrics.onlineViewingUsersBottomLeading)
        }

        if viewModel.outputs.showNextArrow {
            self.addSubview(nextArrow)
            nextArrow.OWSnp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalTo(onlineViewingUsersView.OWSnp.trailing).offset(Metrics.nextArrowLeading)
                make.trailing.equalToSuperview().offset(-Metrics.margins.right)
                make.width.equalTo(Metrics.nextArrowIconSize)
            }
        } else {
            onlineViewingUsersView.OWSnp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-Metrics.margins.right)
            }
        }

        self.isHidden = !viewModel.outputs.isVisible
        if (!viewModel.outputs.isVisible) {
            self.OWSnp.makeConstraints { make in
                make.height.equalTo(0)
            }
        }
    }

    func setupObservers() {
        viewModel.outputs.commentsCount
            .startWith("")
            .bind(to: counterLabel.rx.text)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor1,
                                                                        themeStyle: currentStyle)
                self.counterLabel.textColor = OWColorPalette.shared.color(type: .textColor2,
                                                                          themeStyle: currentStyle)
                self.nextArrow.image = UIImage(spNamed: "nextArrow", supportDarkMode: true)
                self.updateCustomUI()
            }).disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.titleLabel.font = OWFontBook.shared.font(typography: self.viewModel.outputs.titleFontTypography)
                self.counterLabel.font = OWFontBook.shared.font(typography: self.viewModel.outputs.counterFontTypography)
            })
            .disposed(by: disposeBag)
    }
}

