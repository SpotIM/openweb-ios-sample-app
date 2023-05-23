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

class OWReportReasonView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "report_reason_view_id"
        static let cellReuseIdentifier = "reportReasonCell"
        static let prefixIdentifier = "report_reason"
        static let cellHeight: CGFloat = 68
        static let titleViewHeight: CGFloat = 56
        static let buttonsRadius: CGFloat = 6
        static let buttonsPadding: CGFloat = 15
        static let buttonsHeight: CGFloat = 40
        static let textViewPadding: CGFloat = 10
        static let textViewHeight: CGFloat = 62
        static let submitDisabledOpacity: CGFloat = 0.5
        static let headerTextPadding: CGFloat = 16
        static let delayAnimateTextViewDuration: CGFloat = 0.15
        static let animateTextViewHeightDuration: CGFloat = 0.3
        static let animateTextViewAlphaDuration: CGFloat = 0.7
    }

    fileprivate var textViewHeightConstraint: OWConstraint? = nil

    fileprivate lazy var titleView: OWTitleView = {
        return OWTitleView(title: viewModel.outputs.titleText,
                           prefixIdentifier: Metrics.prefixIdentifier)
    }()

    fileprivate lazy var footerView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .apply(shadow: .low, direction: .up)
    }()

    fileprivate lazy var textView: OWTextView = {
        return OWTextView(viewModel: viewModel.outputs.textViewVM,
                          prefixIdentifier: Metrics.prefixIdentifier)
                .alpha(0)
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

    fileprivate lazy var submitButton: OWLoaderButton = {
        return OWLoaderButton()
            .backgroundColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .textColor(.white)
            .setTitle(viewModel.outputs.submitButtonText, state: .normal)
            .corner(radius: Metrics.buttonsRadius)
            .isEnabled(false)
            .alpha(Metrics.submitDisabledOpacity)
    }()

    fileprivate lazy var tableViewReasons: UITableView = {
        return UITableView(frame: .zero, style: .grouped)
            .delegate(self)
            .separatorStyle(.none)
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var tableViewHeaderView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var tableViewHeaderLabel: UILabel = {
        return UILabel()
            .backgroundColor(.clear)
            .numberOfLines(0)
            .attributedText(viewModel.outputs.tableViewHeaderAttributedText)
            .addRangeGesture(stringRange: viewModel.outputs.tableViewHeaderTapText) { [weak self] in
                guard let self = self else { return }
                self.viewModel.inputs.learnMoreTap.onNext()
            }
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
    }

    func setupViews() {
        self.useAsThemeStyleInjector()

        let shouldShowTitleView = viewModel.outputs.shouldShowTitleView

        if shouldShowTitleView {
            self.addSubview(titleView)
            titleView.OWSnp.makeConstraints { make in
                make.leading.trailing.top.equalToSuperviewSafeArea()
                make.height.equalTo(Metrics.titleViewHeight)
            }
        }

        self.addSubview(tableViewReasons)
        tableViewReasons.OWSnp.makeConstraints { make in
            if shouldShowTitleView {
                make.top.equalTo(titleView.OWSnp.bottom)
            } else {
                make.top.equalToSuperview()
            }
            make.leading.trailing.equalToSuperviewSafeArea()
        }

        self.addSubviews(footerView)
        footerView.OWSnp.makeConstraints { make in
            make.top.equalTo(tableViewReasons.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperviewSafeArea()
        }

        footerView.addSubview(textView)
        footerView.addSubview(footerStackView)

        textView.OWSnp.makeConstraints { [weak self] make in
            guard let self = self else { return }
            make.top.leading.trailing.equalToSuperviewSafeArea().inset(Metrics.textViewPadding)
            // Low priority so that when the next line textViewHeightConstraint will be active it will take over this constraint
            make.height.equalTo(0).priority(1)
            self.textViewHeightConstraint = make.height.equalTo(Metrics.textViewHeight).constraint
        }
        self.textViewHeightConstraint?.isActive = false

        footerStackView.OWSnp.makeConstraints { make in
            make.top.equalTo(textView.OWSnp.bottom).offset(Metrics.textViewPadding)
            make.leading.trailing.equalToSuperviewSafeArea().inset(Metrics.buttonsPadding)
            make.bottom.equalToSuperview().inset(Metrics.buttonsPadding)
            make.height.equalTo(Metrics.buttonsHeight)
        }

        footerStackView.addArrangedSubview(cancelButton)
        footerStackView.addArrangedSubview(submitButton)

        tableViewHeaderView.addSubview(tableViewHeaderLabel)
        tableViewHeaderLabel.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Metrics.headerTextPadding)
        }
    }

    func setupObservers() {
        bindTableView()

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.titleView
                    .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2,
                                                                 themeStyle: currentStyle))
                self.tableViewReasons
                    .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2,
                                                                 themeStyle: currentStyle))
                self.footerView
                    .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2,
                                                                 themeStyle: currentStyle))
                self.cancelButton
                    .setBackgroundColor(color: OWColorPalette.shared.color(type: .separatorColor2, themeStyle: currentStyle), forState: .normal)
                self.cancelButton
                    .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle))
                self.tableViewHeaderView
                    .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2,
                                                                 themeStyle: currentStyle))
            })
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .bind(to: viewModel.inputs.cancelReportReasonTap)
            .disposed(by: disposeBag)

        submitButton.rx.tap
            .bind(to: viewModel.inputs.submitReportReasonTap)
            .disposed(by: disposeBag)

        viewModel.outputs.submitInProgress
            .bind(to: submitButton.rx.isLoading)
            .disposed(by: disposeBag)

        viewModel.outputs.isSubmitEnabled
            .map { [weak self] isSubmitEnabled -> Bool in
                guard let self = self else { return isSubmitEnabled }
                self.submitButton.alpha = isSubmitEnabled ? 1 : Metrics.submitDisabledOpacity
                return isSubmitEnabled
            }
            .bind(to: submitButton.rx.isEnabled)
            .disposed(by: disposeBag)

        titleView.outputs.closeTapped
            .bind(to: viewModel.inputs.cancelReportReasonTap)
            .disposed(by: disposeBag)

        viewModel.outputs.selectedReason
            .subscribe(onNext: { [weak self] _ in
                // Show textView after selection
                guard let self = self else { return }
                self.textViewHeightConstraint?.isActive = true
                UIView.animate(withDuration: Metrics.animateTextViewHeightDuration, delay: Metrics.delayAnimateTextViewDuration) {
                    self.layoutIfNeeded()
                }
                UIView.animate(withDuration: Metrics.animateTextViewAlphaDuration, delay: Metrics.delayAnimateTextViewDuration) {
                    self.textView.alpha = 1
                }
            })
            .disposed(by: disposeBag)
    }

    func bindTableView() {
        tableViewReasons.register(OWReportReasonCell.self, forCellReuseIdentifier: Metrics.cellReuseIdentifier)

        viewModel.outputs.reportReasonCellViewModels
            .bind(to: tableViewReasons.rx.items(cellIdentifier: Metrics.cellReuseIdentifier, cellType: OWReportReasonCell.self)) { (_, viewModel, cell) in
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

        tableViewReasons.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.viewModel.inputs.reasonIndexSelect.onNext(indexPath.row)
            })
            .disposed(by: disposeBag)
    }
}

extension OWReportReasonView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Metrics.cellHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableViewHeaderView
    }
}
