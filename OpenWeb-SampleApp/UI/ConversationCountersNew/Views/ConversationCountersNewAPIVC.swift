//
//  ConversationCountersNewAPIVC.swift
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 19/09/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa
import CombineDataSources
import SnapKit

class ConversationCountersNewAPIVC: UIViewController {
    private struct Metrics {
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

    private let viewModel: ConversationCountersNewAPIViewModeling
    private var cancellables = Set<AnyCancellable>()

    private lazy var txtFieldPostIds: TextFieldSetting = {
        let txtField = TextFieldSetting(title: NSLocalizedString("PostIdOrIds", comment: "") + ":",
                                        accessibilityPrefixId: Metrics.txtFieldPostIdsIdentifier)
        return txtField
    }()

    private lazy var lblDescription: UILabel = {
        let txt = NSLocalizedString("ConversationCounterMultiplePostIdsDescription", comment: "")

        return txt
            .label
            .font(FontBook.helper)
            .textColor(ColorPalette.shared.color(type: .red))
            .numberOfLines(0)
    }()

    private lazy var btnExecute: UIButton = {
        return NSLocalizedString("Execute", comment: "")
            .blueRoundedButton
            .withPadding(Metrics.btnPadding)
    }()

    private lazy var loader: UIActivityIndicatorView = {
        let style: UIActivityIndicatorView.Style
        style = .large
        let loader = UIActivityIndicatorView(style: style)
        return loader
    }()

    private lazy var counterTableView: UITableView = {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        applyAccessibility()
        setupObservers()
    }
}

private extension ConversationCountersNewAPIVC {
    @objc func setupViews() {
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
            make.top.equalTo(txtFieldPostIds.snp.bottom).offset(Metrics.verticalMargin / 2)
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

        txtFieldPostIds.textFieldControl.textPublisher
            .unwrap()
            .bind(to: viewModel.inputs.userPostIdsInput)
            .store(in: &cancellables)

        btnExecute.tapPublisher
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.txtFieldPostIds.resignFirstResponder()
            })
            .bind(to: viewModel.inputs.loadConversationCounter)
            .store(in: &cancellables)

        viewModel.outputs.showLoader
            .sink { [weak self] showLoader in
                guard let self else { return }
                if showLoader {
                    loader.startAnimating()
                } else {
                    loader.stopAnimating()
                }
            }
            .store(in: &cancellables)

        viewModel.outputs.showError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showError(message: message)
            }
            .store(in: &cancellables)

        viewModel.outputs.cellsViewModels
            .bind(subscriber: counterTableView.rowsSubscriber(cellType: ConversationCounterNewAPICell.self, cellConfig: { cell, indexPath, viewModel in
                cell.configure(with: viewModel)
            }))
            .store(in: &cancellables)
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
