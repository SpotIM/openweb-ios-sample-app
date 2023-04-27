//
//  OWReportReasonView.swift
//  SpotImCore
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Foundation

#if NEW_API

class OWReportReasonView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "report_reason_view_id"
        static let cellIdentifier = "reportReasonCell"
        static let titleViewIdentifier = "title_view_id"
        static let titleLabelIdentifier = "title_label_id"
        static let cellHeight: CGFloat = 68
        static let titleFontSize: CGFloat = 15
        static let titleViewHeight: CGFloat = 56
        static let footerViewHeight: CGFloat = 70
        static let titleLeadingPadding: CGFloat = 16
        static let buttonsRadius: CGFloat = 6
        static let buttonsPadding: CGFloat = 15
        static let buttonsHeight: CGFloat = 40
    }

    fileprivate lazy var titleView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var titleLabel: UILabel = {
        return viewModel.outputs.titleText
                .label
                .font(UIFont.preferred(style: .bold, of: Metrics.titleFontSize))
    }()

    fileprivate lazy var footerView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var footerStackView: UIStackView = {
        return UIStackView()
            .spacing(Metrics.buttonsPadding)
            .axis(.horizontal)
            .distribution(.fillEqually)
    }()

    fileprivate lazy var cancelButton: UIButton = {
        return UIButton()
                .backgroundColor(OWColorPalette.shared.color(type: .separatorColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .setTitle(viewModel.outputs.cancelButtonText, state: .normal)
                .corner(radius: Metrics.buttonsRadius)
    }()

    fileprivate lazy var submitButton: UIButton = {
        return UIButton()
                .backgroundColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .textColor(.white)
                .setTitle(viewModel.outputs.submitButtonText, state: .normal)
                .corner(radius: Metrics.buttonsRadius)
    }()

    fileprivate lazy var tableViewReasons: UITableView = {
        return UITableView()
                .delegate(self)
                .separatorStyle(.none)
                .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate let viewModel: OWReportReasonViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: OWReportReasonViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        setupViews()
        applyAccessibility()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWReportReasonView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        titleView.accessibilityIdentifier = Metrics.titleViewIdentifier
        titleLabel.accessibilityIdentifier = Metrics.titleLabelIdentifier
    }

    func setupViews() {
        self.useAsThemeStyleInjector()

        let shouldShowTitleView = viewModel.outputs.shouldShowTitleView

        if shouldShowTitleView {
            self.addSubview(titleView)
            titleView.OWSnp.makeConstraints { make in
                make.leading.trailing.top.equalToSuperViewSafeArea()
                make.height.equalTo(Metrics.titleViewHeight)
            }

            titleView.addSubview(titleLabel)
            titleLabel.OWSnp.makeConstraints { make in
                make.leading.equalToSuperViewSafeArea().inset(Metrics.titleLeadingPadding)
                make.centerY.equalToSuperview()
            }
        }

        self.addSubview(tableViewReasons)
        tableViewReasons.OWSnp.makeConstraints { make in
            if shouldShowTitleView {
                make.top.equalTo(titleView.OWSnp.bottom)
            } else {
                make.top.equalToSuperview()
            }
            make.leading.trailing.equalToSuperViewSafeArea()
        }

        self.addSubviews(footerView)
        footerView.OWSnp.makeConstraints { make in
            make.top.equalTo(tableViewReasons.OWSnp.bottom)
            make.height.equalTo(Metrics.footerViewHeight)
            make.leading.trailing.equalToSuperViewSafeArea()
            make.bottom.equalToSuperViewSafeArea()
        }

        footerView.addSubview(footerStackView)
        footerStackView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Metrics.buttonsPadding)
            make.centerY.equalToSuperview()
            make.height.equalTo(Metrics.buttonsHeight)
        }

        footerStackView.addArrangedSubview(cancelButton)
        footerStackView.addArrangedSubview(submitButton)
    }

    func setupObservers() {
        bindTableView()

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.titleView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.tableViewReasons.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.footerView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.cancelButton.setBackgroundColor(color: OWColorPalette.shared.color(type: .separatorColor2, themeStyle: currentStyle), forState: .normal)
                self.cancelButton.textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle))
            })
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .bind(to: viewModel.inputs.cancelReportReasonTap)
            .disposed(by: disposeBag)

        submitButton.rx.tap
            .bind(to: viewModel.inputs.submitReportReasonTap)
            .disposed(by: disposeBag)
    }

    func bindTableView() {
        tableViewReasons.register(OWReportReasonCell.self, forCellReuseIdentifier: Metrics.cellIdentifier)

        viewModel.outputs.reportReasonCellViewModels
            .bind(to: tableViewReasons.rx.items(cellIdentifier: Metrics.cellIdentifier, cellType: OWReportReasonCell.self)) { (_, viewModel, cell) in
            cell.configure(with: viewModel)
        }.disposed(by: disposeBag)

        tableViewReasons.rx.modelDeselected(OWReportReasonCellViewModeling.self)
            .subscribe(onNext: { viewModel in
            viewModel.inputs.setSelected.onNext(false)
        }).disposed(by: disposeBag)

        tableViewReasons.rx.modelSelected(OWReportReasonCellViewModeling.self)
            .subscribe(onNext: { viewModel in
            viewModel.inputs.setSelected.onNext(true)
        }).disposed(by: disposeBag)
    }
}

extension OWReportReasonView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Metrics.cellHeight
    }
}

#endif
