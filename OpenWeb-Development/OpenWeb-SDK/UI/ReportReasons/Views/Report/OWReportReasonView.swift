//
//  OWReportReasonView.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 16/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Foundation

class OWReportReasonView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "report_reason_view_id"
        static let cancelButtonIdentifier = "report_reason_cancel_button_id"
        static let submitButtonIdentifier = "report_reason_submit_button_id"
        static let tableViewIdentifier = "report_reason_table_view_id"
        static let tableHeaderViewIdentifier = "report_reason_table_header_view_id"
        static let tableViewHeaderLabelIdentifier = "report_reason_table_header_label_id"
        static let footerViewIdentifier = "report_reason_footer_view_id"
        static let prefixIdentifier = "report_reason"
        static let titleViewHeight: CGFloat = 56
        static let buttonsRadius: CGFloat = 6
        static let buttonsPadding: CGFloat = 15
        static let buttonsHeight: CGFloat = 40
        static let textViewHorizontalPadding: CGFloat = 10
        static let textViewVerticalPadding: CGFloat = 10
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
                           prefixIdentifier: Metrics.prefixIdentifier,
                           viewModel: viewModel.outputs.titleViewVM)
    }()

    fileprivate lazy var footerView: UIView = {
        let footerView = UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            footerView.apply(shadow: .standard, direction: .up)
        return footerView
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
            .corner(radius: Metrics.buttonsRadius)
            .isEnabled(false)
            .alpha(Metrics.submitDisabledOpacity)
    }()

    fileprivate lazy var tableHeaderView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var tableViewReasons: UITableView = {
        return UITableView(frame: .zero, style: .grouped)
            .delegate(self)
            .separatorStyle(.none)
            .registerCell(cellClass: OWReportReasonCell.self)
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var tableHeaderLabel: UILabel = {
        return UILabel()
            .backgroundColor(.clear)
            .numberOfLines(0)
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
        cancelButton.accessibilityIdentifier = Metrics.cancelButtonIdentifier
        submitButton.accessibilityIdentifier = Metrics.submitButtonIdentifier
        tableViewReasons.accessibilityIdentifier = Metrics.tableViewIdentifier
        tableHeaderView.accessibilityIdentifier = Metrics.tableHeaderViewIdentifier
        tableHeaderLabel.accessibilityIdentifier = Metrics.tableViewHeaderLabelIdentifier
        footerView.accessibilityIdentifier = Metrics.footerViewIdentifier
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
            make.top.leading.trailing.equalToSuperviewSafeArea().inset(Metrics.textViewHorizontalPadding)
            // Low priority so that when the next line textViewHeightConstraint will be active it will take over this constraint
            make.height.equalTo(0).priority(1)
            self.textViewHeightConstraint = make.height.greaterThanOrEqualTo(Metrics.textViewHeight).constraint
        }
        self.textViewHeightConstraint?.isActive = false

        footerStackView.OWSnp.makeConstraints { make in
            make.top.equalTo(textView.OWSnp.bottom).offset(Metrics.textViewVerticalPadding)
            make.leading.trailing.equalToSuperviewSafeArea().inset(Metrics.buttonsPadding)
            make.bottom.equalToSuperview().inset(Metrics.buttonsPadding)
            make.height.equalTo(Metrics.buttonsHeight)
        }

        footerStackView.addArrangedSubview(cancelButton)
        footerStackView.addArrangedSubview(submitButton)

        tableHeaderView.addSubview(tableHeaderLabel)
        tableHeaderLabel.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Metrics.headerTextPadding)
        }
    }

    // swiftlint:disable function_body_length
    func setupObservers() {
        // TableView binding
        viewModel.outputs.reportReasonCellViewModels
            .bind(to: tableViewReasons.rx.items(cellIdentifier: OWReportReasonCell.self.identifierName, cellType: OWReportReasonCell.self)) { (_, viewModel, cell) in
                cell.configure(with: viewModel)
            }
            .disposed(by: disposeBag)

        tableViewReasons.rx.modelDeselected(OWReportReasonCellViewModeling.self)
            .subscribe(onNext: { viewModel in
                viewModel.inputs.setSelected.onNext(false)
            })
            .disposed(by: disposeBag)

        tableViewReasons.rx.modelSelected(OWReportReasonCellViewModeling.self)
            .subscribe(onNext: { viewModel in
                viewModel.inputs.setSelected.onNext(true)
            })
            .disposed(by: disposeBag)

        tableViewReasons.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.viewModel.inputs.reasonIndexSelect.onNext(indexPath.row)
            })
            .disposed(by: disposeBag)

        tableViewReasons.rx.contentOffset
            .observe(on: MainScheduler.instance)
            .bind(to: viewModel.inputs.changeReportOffset)
            .disposed(by: disposeBag)

        // Views Binding
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .withLatestFrom(viewModel.outputs.tableViewHeaderAttributedText) { ($0, $1) }
            .subscribe(onNext: { [weak self] (currentStyle, tableViewHeaderAttributedText) in
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
                    .backgroundColor(OWColorPalette.shared.color(type: .separatorColor2, themeStyle: currentStyle))
                self.cancelButton
                    .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle))
                self.tableHeaderView
                    .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2,
                                                                 themeStyle: currentStyle))

                self.tableHeaderLabel.textColor = OWColorPalette.shared.color(type: .textColor1, themeStyle: currentStyle)
                self.tableHeaderLabel
                    .attributedText(tableViewHeaderAttributedText)
                    .addRangeGesture(targetRange: self.viewModel.outputs.tableViewHeaderTapText) { [weak self] in
                        guard let self = self else { return }
                        self.viewModel.inputs.learnMoreTap.onNext()
                    }

                self.submitButton.backgroundColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.submitButtonText
            .bind(to: submitButton.rx.title(for: .normal))
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

        viewModel.outputs.titleViewVM.outputs.closeTapped
            .bind(to: viewModel.inputs.cancelReportReasonTap)
            .disposed(by: disposeBag)

        viewModel.outputs.selectedReason
            .subscribe(onNext: { [weak self] selectedReason in
                // Show textView after selection
                guard let self = self,
                      self.textViewHeightConstraint?.isActive == false
                else { return }

                self.textViewHeightConstraint?.isActive = true

                if selectedReason.requiredAdditionalInfo { // We do not animate textView if it is a requiredAdditionalInfo reason since we move to the additional info screen
                    self.layoutIfNeeded()
                    self.textView.alpha = 1
                } else {
                    UIView.animate(withDuration: Metrics.animateTextViewHeightDuration, delay: Metrics.delayAnimateTextViewDuration) {
                        self.layoutIfNeeded()
                    }
                    UIView.animate(withDuration: Metrics.animateTextViewAlphaDuration, delay: Metrics.delayAnimateTextViewDuration) {
                        self.textView.alpha = 1
                    }
                }

                if let selectedIndex = self.tableViewReasons.indexPathForSelectedRow {
                    self.tableViewReasons.selectRow(at: selectedIndex, animated: true, scrollPosition: .bottom)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension OWReportReasonView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableHeaderView
    }
}
