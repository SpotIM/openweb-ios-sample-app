//
//  ConversationCounterVC.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 22/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ConversationCounterVC: UIViewController {
    fileprivate struct Metrics {
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 20
        static let textFieldHeight: CGFloat = 40
        static let textFieldCorners: CGFloat = 12
        static let executeButtonCorners: CGFloat = 12
        static let executeButtonPadding: CGFloat = 12
    }

    fileprivate let viewModel: ConversationCounterViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var counterTableView: UITableView = {
        let tblView = UITableView()
            .backgroundColor(ColorPalette.lightGrey)
            .separatorStyle(.none)

        tblView.register(cellClass: ConversationCounterCell.self)
        return tblView
    }()

    fileprivate lazy var lblPostIds: UILabel = {
        let txt = NSLocalizedString("PostIdOrIds", comment: "") + ":"

        return txt
            .label
            .hugContent(axis: .horizontal)
            .font(FontBook.mainHeading)
            .textColor(ColorPalette.blackish)
    }()

    fileprivate lazy var lblDescription: UILabel = {
        let txt = NSLocalizedString("ConversationCounterMultiplePostIdsDescription", comment: "")

        return txt
            .label
            .font(FontBook.helper)
            .textColor(ColorPalette.red)
            .numberOfLines(0)
    }()

    fileprivate lazy var txtFieldPostIds: UITextField = {
        let txtField = UITextField()
            .corner(radius: Metrics.textFieldCorners)
            .border(width: 1.0, color: ColorPalette.blackish)

        txtField.borderStyle = .roundedRect
        txtField.autocapitalizationType = .none
        return txtField
    }()

    fileprivate lazy var btnExecute: UIButton = {
        let txt = NSLocalizedString("Execute", comment: "") + "!"

        return txt
            .button
            .backgroundColor(ColorPalette.green)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.executeButtonCorners)
            .withPadding(Metrics.executeButtonPadding)
            .font(FontBook.secondaryHeadingBold)
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

    init(viewModel: ConversationCounterViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func loadView() {
        super.loadView()
        setupViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
    }
}

fileprivate extension ConversationCounterVC {
    func setupViews() {
        view.backgroundColor = ColorPalette.lightGrey

        view.addSubview(lblPostIds)
        lblPostIds.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Metrics.verticalMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
        }

        view.addSubview(txtFieldPostIds)
        txtFieldPostIds.snp.makeConstraints { make in
            make.centerY.equalTo(lblPostIds)
            make.leading.equalTo(lblPostIds.snp.trailing).offset(Metrics.horizontalMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
            make.height.equalTo(Metrics.textFieldHeight)
        }

        view.addSubview(lblDescription)
        lblDescription.snp.makeConstraints { make in
            make.top.equalTo(txtFieldPostIds.snp.bottom).offset(Metrics.verticalMargin/2)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
        }

        view.addSubview(btnExecute)
        btnExecute.snp.makeConstraints { make in
            make.top.equalTo(lblDescription.snp.bottom).offset(Metrics.verticalMargin)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }

        view.addSubview(counterTableView)
        counterTableView.snp.makeConstraints { make in
            make.top.equalTo(btnExecute.snp.bottom).offset(Metrics.verticalMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        view.addSubview(loader)
        loader.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        viewModel.outputs.cellsViewModels
            .bind(to: counterTableView.rx.items(cellIdentifier: ConversationCounterCell.identifierName,
                                                cellType: ConversationCounterCell.self)) { _, viewModel, cell in
                cell.configure(with: viewModel)
            }
            .disposed(by: disposeBag)

        viewModel.outputs.showError
            .subscribe(onNext: { [weak self] message in
                self?.showError(message: message)
            })
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

        txtFieldPostIds.rx.text
            .unwrap()
            .bind(to: viewModel.inputs.userPostIdsInput)
            .disposed(by: disposeBag)

        btnExecute.rx.tap
            .do(onNext: { [weak self] _ in
                self?.txtFieldPostIds.resignFirstResponder()
            })
            .bind(to: viewModel.inputs.loadConversationCounter)
            .disposed(by: disposeBag)
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
