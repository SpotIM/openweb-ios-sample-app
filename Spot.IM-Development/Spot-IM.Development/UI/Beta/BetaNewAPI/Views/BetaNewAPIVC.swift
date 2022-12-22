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
        static let toolbarPickerHeight: CGFloat = 50
        static let animatePickerDuration: CGFloat = 0.6
        static let animatePickerDamping: CGFloat = 0.5
        static let animatePickerVelocity: CGFloat = 0.5
    }
    
    fileprivate let viewModel: BetaNewAPIViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate lazy var settingsRightBarItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "settingsIcon"),
                               style: .plain,
                               target: nil,
                               action: nil)
    }()
    
    fileprivate lazy var conversationPresetSelectionView: UIView = {
        let spotPresetSelection = UIView()
        spotPresetSelection.backgroundColor = ColorPalette.midGrey
        
        spotPresetSelection.addSubview(toolbarPicker)
        toolbarPicker.snp.makeConstraints { (make) in
            make.height.equalTo(Metrics.toolbarPickerHeight)
            make.top.leading.trailing.equalToSuperview()
        }
        
        spotPresetSelection.addSubview(presetPicker)
        presetPicker.snp.makeConstraints { (make) in
            make.width.bottom.leading.trailing.equalToSuperview()
            make.top.equalTo(toolbarPicker.snp.bottom)
        }
        
        return spotPresetSelection
    }()

    fileprivate lazy var presetPicker: UIPickerView = {
        return UIPickerView()
    }()

    fileprivate lazy var toolbarPicker: UIToolbar = {
        var toolbar = UIToolbar()
        toolbar.barTintColor = ColorPalette.darkGrey
        toolbar.tintColor = ColorPalette.blackish
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let title = NSLocalizedString("PresetSelection", comment: "").label
            .font(FontBook.paragraphBold)
            .barButtonItem
        
        toolbar.setItems([spaceButton, title, spaceButton, btnDone.barButtonItem], animated: false)
        return toolbar
    }()
    
    fileprivate lazy var btnDone: UIButton = {
        let txt = NSLocalizedString("Done", comment: "")
        
        return txt
            .button
            .backgroundColor(ColorPalette.blue)
            .textColor(ColorPalette.extraLightGrey)
            .font(FontBook.paragraphBold)
            .corner(radius: Metrics.buttonCorners)
            .withPadding(Metrics.buttonPadding)
    }()
    
    fileprivate lazy var btnSelectPreset: UIButton = {
        let txt = NSLocalizedString("SelectPreset", comment: "")

        return txt
            .button
            .backgroundColor(ColorPalette.darkGrey)
            .textColor(ColorPalette.white)
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
    
    fileprivate var selectedAnswer: ConversationPreset?
    
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
        view.addSubview(conversationPresetSelectionView)
        conversationPresetSelectionView.snp.makeConstraints { (make) in
            make.height.equalTo(Metrics.pickerHeight)
            make.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview().inset(-Metrics.pickerHeight)
        }
    }
    
    func setupObservers() {
        title = viewModel.outputs.title

        viewModel.outputs.spotId
            .bind(to: txtFieldSpotId.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.postId
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
        
        btnUIFlows.rx.tap
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
            .bind(to: viewModel.inputs.uiViewsTapped)
            .disposed(by: disposeBag)
        
        viewModel.outputs.openUIViews
            .subscribe(onNext: { [weak self] dataModel in
                guard let self = self else { return }
                let uiViewsVM = UIViewsViewModel(dataModel: dataModel)
                let uiViewsVC = UIViewsVC(viewModel: uiViewsVM)
                self.navigationController?.pushViewController(uiViewsVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        btnMiscellaneous.rx.tap
            .bind(to: viewModel.inputs.miscellaneousTapped)
            .disposed(by: disposeBag)
        
        viewModel.outputs.openMiscellaneous
            .subscribe(onNext: { [weak self] dataModel in
                guard let self = self else { return }
                let miscellaneousVM = MiscellaneousViewModel(dataModel: dataModel)
                let miscellaneousVC = MiscellaneousVC(viewModel: miscellaneousVM)
                self.navigationController?.pushViewController(miscellaneousVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        settingsRightBarItem.rx.tap
            .bind(to: viewModel.inputs.settingsTapped)
            .disposed(by: disposeBag)
        
        viewModel.outputs.openSettings
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let settingsVM = SettingsViewModel()
                let settingsVC = SettingsVC(viewModel: settingsVM)
                self.navigationController?.present(settingsVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        // Bind select preset
        viewModel.outputs.shouldShowSelectPreset
            .skip(1)
            .subscribe { [weak self] in self?.showPresetPicker($0) }
            .disposed(by: disposeBag)
        
        btnDone.rx.tap
            .map { false }
            .voidify()
            .bind(to: viewModel.inputs.doneSelectPresetTapped)
            .disposed(by: disposeBag)
        
        // Bind picker
        presetPicker.rx.itemSelected
            .map { event in
                return event.row
            }
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.selectedConversationPresetIndex)
            .disposed(by: disposeBag)
        
        viewModel.outputs.conversationPresets
            .map { options in
                return options.map { $0.displayName }
            }
            .bind(to: presetPicker.rx.itemTitles) { _, item in
                return item
            }
            .disposed(by: disposeBag)
    }
}

fileprivate extension BetaNewAPIVC {
    
    func showPresetPicker(_ isShown: Bool) {
        if isShown {
            // Dismiss keyboard
            self.view.endEditing(true)
        }
        UIView.animate(withDuration: Metrics.animatePickerDuration,
                       delay: 0.0,
                       usingSpringWithDamping: Metrics.animatePickerDamping,
                       initialSpringVelocity: Metrics.animatePickerVelocity) {
            self.conversationPresetSelectionView.snp.updateConstraints { update in
                update.bottom.equalToSuperview().inset(isShown ? 0 : -Metrics.pickerHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
}

#endif
