//
//  OWConversationSortView.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 22/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWConversationSortView: UIView {
    private struct Metrics {
        static let verticalMarginBetweenSortLabelAndSortIcon: CGFloat = 2
        static let verticalMarginBetweenSortLabelAndSortButton: CGFloat = 5

        static let sortByLabelIdentifier = "conversation_sort_by_label_id"
        static let sortViewIdentifier = "conversation_sort_view_id"
    }

    private var viewModel: OWConversationSortViewModeling
    private let disposeBag = DisposeBag()

    private lazy var sortByLabel: UILabel = {
        return UILabel()
            .wrapContent()
            .text(OWLocalizationManager.shared.localizedString(key: "SortBy"))
            .font(OWFontBook.shared.font(typography: .bodyText))
            .textColor(OWColorPalette.shared.color(type: .textColor2,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    private lazy var sortIcon: UIImageView = {
        return UIImageView()
            .wrapContent()
            .image(UIImage(spNamed: "sort")!)
    }()

    private lazy var sortLabel: UILabel = {
        return UILabel()
            .wrapContent()
            .font(OWFontBook.shared.font(typography: .bodyContext))
            .textColor(OWColorPalette.shared.color(type: .textColor3,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    private lazy var sortView: UIView = {
        let view = UIView()
        view.addGestureRecognizer(tapGesture)

        view.addSubview(sortLabel)
        sortLabel.OWSnp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
        }

        view.addSubview(sortIcon)
        sortIcon.OWSnp.makeConstraints { make in
            make.leading.equalTo(sortLabel.OWSnp.trailing).offset(Metrics.verticalMarginBetweenSortLabelAndSortIcon)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(sortLabel.OWSnp.centerY)
        }

        return view
            .wrapContent()
            .enforceSemanticAttribute()
    }()

    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer()
        return tapGesture
    }()

    init(viewModel: OWConversationSortViewModeling) {
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

private extension OWConversationSortView {
    func setupUI() {
        // Setup sort by label
        self.addSubview(sortByLabel)
        sortByLabel.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }

        // Setup sort button
        self.addSubview(sortView)
        sortView.OWSnp.makeConstraints { make in
            make.leading.equalTo(sortByLabel.OWSnp.trailing).offset(Metrics.verticalMarginBetweenSortLabelAndSortButton)
            make.top.bottom.trailing.equalToSuperview()
        }
    }

    func setupObservers() {
        // Setup sort title
        viewModel.outputs.selectedSortOption
            .map { $0.title }
            .bind(to: sortLabel.rx.text)
            .disposed(by: disposeBag)

        // Setup sort button tapped
        tapGesture.rx.event
            .map { [weak self] _ in
                self?.sortIcon
            }
            .unwrap()
            .bind(to: viewModel.inputs.sortTapped)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self else { return }

                self.sortByLabel.textColor = OWColorPalette.shared.color(type: .textColor2,
                                                                          themeStyle: currentStyle)
                self.sortLabel.textColor(OWColorPalette.shared.color(type: .textColor3,
                                                                           themeStyle: currentStyle))
                self.sortIcon.image(UIImage(spNamed: "sort", supportDarkMode: true)!)
                self.updateCustomUI()
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.sortByLabel.font = OWFontBook.shared.font(typography: .bodyText)
                self.sortLabel.font = OWFontBook.shared.font(typography: .bodyContext)
            })
            .disposed(by: disposeBag)
    }

    func updateCustomUI() {
        viewModel.inputs.triggerCustomizeSortByLabelUI.onNext(sortLabel)
    }

    func applyAccessibility() {
        sortByLabel.accessibilityIdentifier = Metrics.sortByLabelIdentifier
        sortView.accessibilityIdentifier = Metrics.sortViewIdentifier
    }
}
