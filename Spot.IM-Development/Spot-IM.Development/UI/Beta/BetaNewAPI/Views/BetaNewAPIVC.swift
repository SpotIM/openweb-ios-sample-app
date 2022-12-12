//
//  BetaNewAPIVC.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 31/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

#if NEW_API

class BetaNewAPIVC: UIViewController {
    fileprivate struct Metrics {
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 50
        static let textFieldHeight: CGFloat = 40
        static let textFieldCorners: CGFloat = 12
        static let buttonVerticalMargin: CGFloat = 20
        static let buttonCorners: CGFloat = 16
        static let buttonPadding: CGFloat = 10
        static let buttonHeight: CGFloat = 50
        static let pickerHeight: CGFloat = 250
        static let toolbarPickerHeight: CGFloat = 40
    }
    
    fileprivate let viewModel: BetaNewAPIViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate lazy var settingsRightBarItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "settingsIcon"),
                               style: .plain,
                               target: self,
                               action: #selector(showSettings))
    }()
    
    private lazy var spotPresetSelectionView: UIView = {
        let spotPresetSelection = UIView()
        spotPresetSelection.backgroundColor = .gray
        
        spotPresetSelection.addSubview(toolbarPicker)
        toolbarPicker.snp.makeConstraints { (make) in
            make.height.equalTo(Metrics.toolbarPickerHeight)
            make.top.leading.trailing.equalToSuperview()
        }
        
        spotPresetSelection.addSubview(presetPicker)
        presetPicker.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(toolbarPicker.snp.bottom)
        }
        
        return spotPresetSelection
    }()

    private lazy var presetPicker: UIPickerView = {
        return UIPickerView()
    }()

    private lazy var toolbarPicker: UIToolbar = {
        var toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.barTintColor = .gray
        toolbar.tintColor = .white
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.setItems([spaceButton, doneButton], animated: false)
        return toolbar
    }()
    
    fileprivate lazy var btnSelectPreset: UIButton = {
        let txt = NSLocalizedString("SelectPreset", comment: "")

        return txt
            .button
            .backgroundColor(ColorPalette.darkGrey)
            .textColor(.white)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()
    
    fileprivate lazy var lblSpotId: UILabel = {
        let txt = NSLocalizedString("SpotId", comment: "") + ":"

        return txt
            .label
            .hugContent(axis: .horizontal)
            .font(FontBook.mainHeading)
            .textColor(ColorPalette.blackish)
    }()
    
    fileprivate lazy var lblPostId: UILabel = {
        let txt = NSLocalizedString("PostId", comment: "") + ":"

        return txt
            .label
            .hugContent(axis: .horizontal)
            .font(FontBook.mainHeading)
            .textColor(ColorPalette.blackish)
    }()
    
    fileprivate lazy var txtFieldSpotId: UITextField = {
        let txtField = UITextField()
            .corner(radius: Metrics.textFieldCorners)
            .border(width: 1.0, color: ColorPalette.blackish)
        
        txtField.borderStyle = .roundedRect
        txtField.autocapitalizationType = .none
        return txtField
    }()
    
    fileprivate lazy var txtFieldPostId: UITextField = {
        let txtField = UITextField()
            .corner(radius: Metrics.textFieldCorners)
            .border(width: 1.0, color: ColorPalette.blackish)
        
        txtField.borderStyle = .roundedRect
        txtField.autocapitalizationType = .none
        return txtField
    }()
    
    fileprivate lazy var btnUIFlows: UIButton = {
        let txt = NSLocalizedString("UIFlows", comment: "")
        
        return txt
            .button
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()
    
    fileprivate lazy var btnUIViews: UIButton = {
        let txt = NSLocalizedString("UIViews", comment: "")
        
        return txt
            .button
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()
    
    fileprivate lazy var btnMiscellaneous: UIButton = {
        let txt = NSLocalizedString("Miscellaneous", comment: "")
        
        return txt
            .button
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .corner(radius: Metrics.buttonCorners)
            .withHorizontalPadding(Metrics.buttonPadding)
            .font(FontBook.paragraphBold)
    }()
    
    fileprivate var selectedAnswer: SpotPreset?
    
    init(viewModel: BetaNewAPIViewModeling = BetaNewAPIViewModel()) {
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
        
        navigationItem.rightBarButtonItem = settingsRightBarItem
        
        setupPicker()
        setupObservers()
    }
}

fileprivate extension BetaNewAPIVC {
    func setupViews() {
        view.backgroundColor = .white
        
        // Adding select preset button
        view.addSubview(btnSelectPreset)
        btnSelectPreset.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Metrics.verticalMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        view.addSubview(lblSpotId)
        lblSpotId.snp.makeConstraints { make in
            make.top.equalTo(btnSelectPreset.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        view.addSubview(txtFieldSpotId)
        txtFieldSpotId.snp.makeConstraints { make in
            make.centerY.equalTo(lblSpotId)
            make.leading.equalTo(lblSpotId.snp.trailing).offset(0.3*Metrics.horizontalMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
            make.height.equalTo(Metrics.textFieldHeight)
        }
        
        view.addSubview(lblPostId)
        lblPostId.snp.makeConstraints { make in
            make.top.equalTo(lblSpotId.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        view.addSubview(txtFieldPostId)
        txtFieldPostId.snp.makeConstraints { make in
            make.centerY.equalTo(lblPostId)
            make.leading.equalTo(lblPostId.snp.trailing).offset(0.3*Metrics.horizontalMargin)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.horizontalMargin)
            make.height.equalTo(Metrics.textFieldHeight)
        }
        
        // Adding UIFlows button
        view.addSubview(btnUIFlows)
        btnUIFlows.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(txtFieldPostId.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        // Adding UIViews button
        view.addSubview(btnUIViews)
        btnUIViews.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnUIFlows.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        // Adding miscellaneous button
        view.addSubview(btnMiscellaneous)
        btnMiscellaneous.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(Metrics.buttonHeight)
            make.top.equalTo(btnUIViews.snp.bottom).offset(Metrics.buttonVerticalMargin)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
        }
        
        // Setup preset picker and its container.
        view.addSubview(spotPresetSelectionView)
        spotPresetSelectionView.snp.makeConstraints { (make) in
            make.height.equalTo(Metrics.pickerHeight)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview().inset(-Metrics.pickerHeight)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title
        
        // Pre filled
        viewModel.outputs.preFilledSpotId
            .take(1)
            .bind(to: txtFieldSpotId.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.preFilledPostId
            .take(1)
            .bind(to: txtFieldPostId.rx.text)
            .disposed(by: disposeBag)
        
        // Dismiss keyboard
        txtFieldSpotId.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .subscribe(onNext: { [weak self] _ in
                self?.txtFieldSpotId.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        txtFieldPostId.rx.controlEvent([.editingDidEnd, .editingDidEndOnExit])
            .subscribe(onNext: { [weak self] _ in
                self?.txtFieldPostId.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        // Bind text fields
        txtFieldSpotId.rx.text
            .unwrap()
            .bind(to: viewModel.inputs.enteredSpotId)
            .disposed(by: disposeBag)
        
        txtFieldPostId.rx.text
            .unwrap()
            .bind(to: viewModel.inputs.enteredPostId)
            .disposed(by: disposeBag)
        
        // Bind buttons
        btnSelectPreset.rx.tap
            .bind(to: viewModel.inputs.selectPresetTapped)
            .disposed(by: disposeBag)
        
        viewModel.outputs.showSelectPreset
            .subscribe { [weak self] _ in
                guard let self = self else { return }

                self.view.endEditing(true)
                self.showPresetPicker(true)
            }
            .disposed(by: disposeBag)
        
        btnUIFlows.rx.tap
            .map { PresentationalModeCompact.push }
            .bind(to: viewModel.inputs.uiFlowsTapped)
            .disposed(by: disposeBag)
        
        viewModel.outputs.openUIFlows
            .subscribe(onNext: { [weak self] dataModel in
                guard let self = self else { return }
                let uiFlowsVM = UIFlowsViewModel(dataModel: dataModel)
                let uiFlowsVC = UIFlowsVC(viewModel: uiFlowsVM)
                self.navigationController?.pushViewController(uiFlowsVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        btnUIViews.rx.tap
            .map { PresentationalModeCompact.push }
            .bind(to: viewModel.inputs.uiViewsTapped)
            .disposed(by: disposeBag)
        
        viewModel.outputs.openUIViews
            .subscribe(onNext: { [weak self] dataModel in
                guard let self = self else { return }
                let uiFlowsVM = UIViewsViewModel(dataModel: dataModel)
                let uiFlowsVC = UIViewsVC(viewModel: uiFlowsVM)
                self.navigationController?.pushViewController(uiFlowsVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        btnMiscellaneous.rx.tap
            .map { PresentationalModeCompact.push }
            .bind(to: viewModel.inputs.miscellaneousTapped)
            .disposed(by: disposeBag)
        
        viewModel.outputs.openMiscellaneous
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let miscellaneousVM = MiscellaneousViewModel()
                let miscellaneousVC = MiscellaneousVC(viewModel: miscellaneousVM)
                self.navigationController?.pushViewController(miscellaneousVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func setupPicker() {
        presetPicker.dataSource = self
        presetPicker.delegate = self
    }
    
    @objc
    func showSettings() {
        viewModel.inputs.settingsTapped.onNext()
    }
    
    @objc
    func doneTapped() {
        if let selectedAnswer = self.selectedAnswer {
            txtFieldSpotId.rx.text.onNext(selectedAnswer.spotId)
            txtFieldPostId.rx.text.onNext(selectedAnswer.postId)
            self.selectedAnswer = nil
        }
        showPresetPicker(false)
    }
}

extension BetaNewAPIVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SpotPreset.mockModels.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return SpotPreset.mockModels[row].displayName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedAnswer = SpotPreset.mockModels[row]
    }
}

fileprivate extension BetaNewAPIVC {
    
    func showPresetPicker(_ isShown: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.spotPresetSelectionView.snp.updateConstraints { update in
                update.bottom.equalToSuperview().inset(isShown ? 0 : -Metrics.pickerHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
}

#endif
