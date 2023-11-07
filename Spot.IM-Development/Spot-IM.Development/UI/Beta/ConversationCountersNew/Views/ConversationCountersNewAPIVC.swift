//
//  ConversationCountersNewAPIVC.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 19/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

#if NEW_API

class ConversationCountersNewAPIVC: UIViewController {
    fileprivate struct Metrics {
        static let identifier = "conversation_counters_new_api_vc_id"
        static let txtFieldPostIdsIdentifier = "post_ids"
        static let btnExecuteIdentifier = "execute_btn"
        static let countersTableIdentifier = "counters_table"
        static let textFieldHeight: CGFloat = 40
        static let verticalMargin: CGFloat = 20
        static let horizontalMargin: CGFloat = 20
        static let horizontalSmallMargin: CGFloat = 10
        static let btnPadding: CGFloat = 12
        static let btnTopPadding: CGFloat = 40
    }

    fileprivate let viewModel: ConversationCountersNewAPIViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var txtFieldPostIds: TextFieldSetting = {
        let txtField = TextFieldSetting(title: NSLocalizedString("PostIdOrIds", comment: "") + ":",
                                        accessibilityPrefixId: Metrics.txtFieldPostIdsIdentifier)
        return txtField
    }()

    fileprivate lazy var lblDescription: UILabel = {
        let txt = NSLocalizedString("ConversationCounterMultiplePostIdsDescription", comment: "")

        return txt
            .label
            .font(FontBook.helper)
            .textColor(ColorPalette.shared.color(type: .red))
            .numberOfLines(0)
    }()

    fileprivate lazy var btnExecute: UIButton = {
        return NSLocalizedString("Execute", comment: "")
            .blueRoundedButton
            .withPadding(Metrics.btnPadding)
    }()

    fileprivate lazy var loader: UIActivityIndicatorView = {
        let style: UIActivityIndicatorView.Style
        if #available(iOS 13.0, *) {
            style = .large
        } else {
            style = .whiteLarge
        }
        let loader = UIActivityIndicatorView(style: style)
        loader.isHidden = true
        return loader
    }()

    fileprivate lazy var counterTableView: UITableView = {
        let tblView = UITableView()
            .separatorStyle(.none)

        tblView.register(cellClass: ConversationCounterNewAPICell.self)
        return tblView
    }()

    init(viewModel: ConversationCountersNewAPIViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func loadView() {
        super.loadView()
        setupViews()
        applyAccessibility()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
    }
}

fileprivate extension ConversationCountersNewAPIVC {
    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        applyLargeTitlesIfNeeded()

        self.view.addSubview(txtFieldPostIds)
        txtFieldPostIds.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Metrics.verticalMargin)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Metrics.horizontalSmallMargin)
            make.height.equalTo(Metrics.textFieldHeight)
        }

        self.view.addSubview(lblDescription)
        lblDescription.snp.makeConstraints { make in
            make.top.equalTo(txtFieldPostIds.snp.bottom).offset(Metrics.verticalMargin/2)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Metrics.horizontalMargin)
        }

        self.view.addSubview(btnExecute)
        btnExecute.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(lblDescription.snp.bottom).offset(Metrics.btnTopPadding)
        }

        view.addSubview(counterTableView)
        counterTableView.snp.makeConstraints { make in
            make.top.equalTo(btnExecute.snp.bottom).offset(Metrics.verticalMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        self.view.addSubview(loader)
        loader.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func applyAccessibility() {
        self.view.accessibilityIdentifier = Metrics.identifier
        btnExecute.accessibilityIdentifier = Metrics.btnExecuteIdentifier
        txtFieldPostIds.accessibilityIdentifier = Metrics.txtFieldPostIdsIdentifier
        counterTableView.accessibilityIdentifier = Metrics.countersTableIdentifier
    }

    func setupObservers() {
        title = viewModel.outputs.title

        txtFieldPostIds.rx.textFieldText
            .unwrap()
            .bind(to: viewModel.inputs.userPostIdsInput)
            .disposed(by: disposeBag)

        btnExecute.rx.tap
            .do(onNext: { [weak self] _ in
                self?.txtFieldPostIds.resignFirstResponder()
            })
            .bind(to: viewModel.inputs.loadConversationCounter)
            .disposed(by: disposeBag)

        let showLoaderObservable = viewModel.outputs.showLoader
            .share(replay: 0)

        showLoaderObservable
            .map { !$0 }
            .bind(to: loader.rx.isHidden)
            .disposed(by: disposeBag)

        showLoaderObservable
            .bind(to: loader.rx.isAnimating)
            .disposed(by: disposeBag)

        viewModel.outputs.showError
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.showError(message: message)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.cellsViewModels
            .bind(to: counterTableView.rx.items(cellIdentifier: ConversationCounterNewAPICell.identifierName,
                                                cellType: ConversationCounterNewAPICell.self)) { _, viewModel, cell in
                cell.configure(with: viewModel)
            }
            .disposed(by: disposeBag)
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

#endif
