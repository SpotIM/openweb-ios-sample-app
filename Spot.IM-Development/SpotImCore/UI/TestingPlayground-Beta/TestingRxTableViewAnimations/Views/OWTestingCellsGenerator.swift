//
//  OWTestingCellsGenerator.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if BETA

import UIKit
import RxSwift
import RxCocoa

class OWTestingCellsGenerator: UIView {

    fileprivate struct Metrics {
        static let mainFontSize: CGFloat = 16.0
        static let secondaryFontSize: CGFloat = 14.0
        static let verticalMargin: CGFloat = 10.0
        static let horizontalMargin: CGFloat = 8.0
        static let roundCorners: CGFloat = 10.0
        static let txtFieldHeight: CGFloat = 40.0
    }

    fileprivate var viewModel: OWTestingCellsGeneratorViewModeling!
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var mainTitle: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.mainFontSize))
    }()

    fileprivate lazy var addCellsView: UIView = {
        let view = UIView()

        view.addSubview(btnAdd)
        btnAdd.OWSnp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }

        view.addSubview(textFieldNumberToAdd)
        textFieldNumberToAdd.OWSnp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
            make.leading.equalTo(btnAdd).offset(Metrics.horizontalMargin)
            make.trailing.equalToSuperview()
        }

        return view
    }()

    fileprivate lazy var btnAdd: UIButton = {
        return "Add"
            .button
            .backgroundColor(.lightGray)
            .textColor(.black)
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.secondaryFontSize))
    }()

    fileprivate lazy var textFieldNumberToAdd: UITextField = {
        let txtField = UITextField()
            .backgroundColor(UIColor.white)
            .corner(radius: Metrics.roundCorners)
            .border(width: 2.0, color: UIColor.black)

        txtField.textColor = UIColor.black
        txtField.font = UIFont.systemFont(ofSize: Metrics.secondaryFontSize)
        txtField.keyboardType = .numberPad
        txtField.returnKeyType = .done

        return txtField
    }()

    fileprivate lazy var btnReloadAll: UIButton = {
        return "Reload All"
            .button
            .backgroundColor(.lightGray)
            .textColor(.black)
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.secondaryFontSize))
    }()

    fileprivate lazy var btnRemoveAll: UIButton = {
        return "Remove All"
            .button
            .backgroundColor(.lightGray)
            .textColor(.black)
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.secondaryFontSize))
    }()

    init(viewModel: OWTestingCellsGeneratorViewModeling) {
        super.init(frame: .zero)
        self.viewModel = viewModel

        setupUI()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWTestingCellsGenerator {
    func setupUI() {
        self.backgroundColor = .white

        self.addSubview(mainTitle)
        mainTitle.OWSnp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.top.equalToSuperview().offset(Metrics.verticalMargin)
        }

        self.addSubview(addCellsView)
        addCellsView.OWSnp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.top.equalTo(mainTitle.OWSnp.bottom).offset(Metrics.verticalMargin)
        }

        self.addSubview(btnReloadAll)
        btnReloadAll.OWSnp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.top.equalTo(addCellsView.OWSnp.bottom).offset(Metrics.verticalMargin)
        }

        self.addSubview(btnRemoveAll)
        btnRemoveAll.OWSnp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.top.equalTo(btnReloadAll.OWSnp.bottom).offset(Metrics.verticalMargin)
            make.bottom.equalToSuperview().offset(-Metrics.verticalMargin)
        }

    }

    func setupObservers() {
        btnAdd.rx.tap
            .bind(to: viewModel.inputs.addTap)
            .disposed(by: disposeBag)

        btnReloadAll.rx.tap
            .bind(to: viewModel.inputs.reloadAllTap)
            .disposed(by: disposeBag)

        btnRemoveAll.rx.tap
            .bind(to: viewModel.inputs.removeAllTap)
            .disposed(by: disposeBag)

        viewModel.outputs.textFieldNumberString
            .bind(to: textFieldNumberToAdd.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.mainText
            .bind(to: mainTitle.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.mainTextColor
            .bind(to: mainTitle.rx.textColor)
            .disposed(by: disposeBag)
    }
}

#endif
