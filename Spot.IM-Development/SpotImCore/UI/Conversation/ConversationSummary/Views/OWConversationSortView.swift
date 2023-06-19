//
//  OWConversationSortView.swift
//  SpotImCore
//
//  Created by Revital Pisman on 22/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OWConversationSortView: UIView {
    fileprivate struct Metrics {
        static let titleFontSize: CGFloat = 15.0
        static let buttonFontSize: CGFloat = 15.0
        static let verticalMarginBetweenSortLabelAndSortIcon: CGFloat = 10.0
        static let verticalMarginBetweenSortLabelAndSortButton: CGFloat = 5.0
        static let sortButtonImageSize: CGFloat = 16
        static let sortByLabelIdentifier = "conversation_sort_by_label_id"
        static let sortViewIdentifier = "conversation_sort_view_id"
    }

    fileprivate var viewModel: OWConversationSortViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var sortByLabel: UILabel = {
        return UILabel()
            .text(OWLocalizationManager.shared.localizedString(key: "Sort by"))
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.titleFontSize))
            .textColor(OWColorPalette.shared.color(type: .textColor2,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var sortIcon: UIImageView = {
        return UIImageView()
            .image(UIImage(spNamed: "sort")!)
    }()

    fileprivate lazy var sortLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(style: .bold, size: Metrics.titleFontSize))
            .textColor(OWColorPalette.shared.color(type: .textColor3,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var sortView: UIView = {
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
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
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

fileprivate extension OWConversationSortView {
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
                self?.sortView
            }
            .unwrap()
            .bind(to: viewModel.inputs.sortTapped)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.sortByLabel.textColor = OWColorPalette.shared.color(type: .textColor2,
                                                                          themeStyle: currentStyle)
                self.sortLabel.textColor(OWColorPalette.shared.color(type: .textColor3,
                                                                           themeStyle: currentStyle))
                self.sortIcon.image(UIImage(spNamed: "sort", supportDarkMode: true)!)
                self.updateCustomUI()
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
