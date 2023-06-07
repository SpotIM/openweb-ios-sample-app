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
        static let insetTiny: CGFloat = 10.0
        static let verticalMarginBetweenSortLabel: CGFloat = 5.0
        static let sortLabelIdentifier = "conversation_sort_label_id"
        static let sortButtonIdentifier = "conversation_sort_button_id"
    }

    fileprivate var viewModel: OWConversationSortViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var sortLabel: UILabel = {
        let lbl = UILabel()
            .enforceSemanticAttribute()
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.titleFontSize))
            .textColor(OWColorPalette.shared.color(type: .textColor2,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .text(OWLocalizationManager.shared.localizedString(key: "Sort by"))

        return lbl
    }()

    fileprivate lazy var sortButton: UIButton = {
        let button = UIButton()
            .font(UIFont.preferred(style: .bold, of: Metrics.buttonFontSize))
            .adjustTextAndImageAlignment(Metrics.insetTiny)
            .enforceSemanticAttribute()

        // Transform Button in order to put image to the right
        if OWLocalizationManager.shared.semanticAttribute == .forceLeftToRight {
            button.reverseTransform()
        }

        return button
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
        // Setup sort button
        self.addSubview(sortButton)
        sortButton.OWSnp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
        }

        // Setup sort label
        self.addSubviews(sortLabel)
        sortLabel.OWSnp.makeConstraints { make in
            make.trailing.equalTo(sortButton.OWSnp.leading).offset(-Metrics.verticalMarginBetweenSortLabel)
            make.top.bottom.equalToSuperview()
        }
    }

    func setupObservers() {
        // Setup sort title
        viewModel.outputs.selectedSortOption
            .map { $0.title }
            .bind(to: sortButton.rx.title())
            .disposed(by: disposeBag)

        // Setup sort button tapped
        sortButton.rx.tap
            .bind(to: viewModel.inputs.sortTapped)
            .disposed(by: disposeBag)

        // Setup sort option selected
        viewModel.outputs.openSort
            .subscribe(onNext: { [weak self] _ in
                guard let _ = self else { return }
                // TODO: open sort
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.sortLabel.textColor = OWColorPalette.shared.color(type: .textColor2,
                                                                          themeStyle: currentStyle)
                self.sortButton.setTitleColor(OWColorPalette.shared.color(type: .textColor3,
                                                                          themeStyle: currentStyle), state: .normal)
                self.sortButton.setImage(UIImage(spNamed: "sort", supportDarkMode: true), for: .normal)
                self.updateCustomUI()
            })
            .disposed(by: disposeBag)
    }

    func updateCustomUI() {
        viewModel.inputs.triggerCustomizeSortByLabelUI.onNext(sortLabel)
    }

    func applyAccessibility() {
        sortLabel.accessibilityIdentifier = Metrics.sortLabelIdentifier
        sortButton.accessibilityIdentifier = Metrics.sortButtonIdentifier
    }
}
