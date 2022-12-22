//
//  SettingsVC.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 18/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

class SettingsVC: UIViewController {
    
    fileprivate struct Metrics {
        static let verticalOffset: CGFloat = 50
        static let horizontalOffset: CGFloat = 10
    }
    
    fileprivate lazy var titleLbl: UILabel = {
        let lbl = UILabel()
            .font(FontBook.mainHeadingBold)
        
        return lbl
    }()
    
    fileprivate lazy var switchHideArticleHeader: SwitchSetting = {
        return SwitchSetting(title: viewModel.outputs.hideArticleHeaderTitle)
    }()
    
    fileprivate lazy var switchCommentCreationNewDesign: SwitchSetting = {
        return SwitchSetting(title: viewModel.outputs.commentCreationNewDesignTitle)
    }()
    
    fileprivate lazy var segmentedReadOnlyMode: SegmentedControlSetting = {
        let title = viewModel.outputs.readOnlyTitle
        let items = viewModel.outputs.readOnlySettings
        
        return SegmentedControlSetting(title: title, items: items)
    }()
    
    fileprivate lazy var segmentedThemeMode: SegmentedControlSetting = {
        let title = viewModel.outputs.themeModeTitle
        let items = viewModel.outputs.themeModeSettings
        
        return SegmentedControlSetting(title: title, items: items)
    }()
    
    fileprivate lazy var segmentedModalStyle: SegmentedControlSetting = {
        let title = viewModel.outputs.modalStyleTitle
        let items = viewModel.outputs.modalStyleSettings
        
        return SegmentedControlSetting(title: title, items: items)
    }()
    
    fileprivate let viewModel: SettingsViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    init(viewModel: SettingsViewModeling) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

fileprivate extension SettingsVC {
    func setupViews() {
        view.backgroundColor = .white
        
        titleLbl.text = viewModel.outputs.title
        
        view.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Metrics.verticalOffset)
        }
        
        view.addSubview(switchHideArticleHeader)
        switchHideArticleHeader.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLbl.snp.bottom).offset(Metrics.verticalOffset)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalOffset)
        }
        
        view.addSubview(switchCommentCreationNewDesign)
        switchCommentCreationNewDesign.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(switchHideArticleHeader.snp.bottom).offset(Metrics.verticalOffset)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalOffset)
        }
        
        view.addSubview(segmentedReadOnlyMode)
        segmentedReadOnlyMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(switchCommentCreationNewDesign.snp.bottom).offset(Metrics.verticalOffset)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalOffset)
        }
        
        view.addSubview(segmentedThemeMode)
        segmentedThemeMode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(segmentedReadOnlyMode.snp.bottom).offset(Metrics.verticalOffset)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalOffset)
        }
        
        view.addSubview(segmentedModalStyle)
        segmentedModalStyle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(segmentedThemeMode.snp.bottom).offset(Metrics.verticalOffset)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalOffset)
        }
    }
    
    func setupObservers() {
        
        switchHideArticleHeader.rx.value
            .bind(to: viewModel.inputs.hideArticleHeaderToggled)
            .disposed(by: disposeBag)
        
        switchCommentCreationNewDesign.rx.value
            .bind(to: viewModel.inputs.hideArticleHeaderToggled)
            .disposed(by: disposeBag)
        
        segmentedReadOnlyMode.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.readOnlyModeSelectedIndex)
            .disposed(by: disposeBag)
        
        segmentedThemeMode.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.themeModeSelectedIndex)
            .disposed(by: disposeBag)
        
        segmentedModalStyle.rx.selectedSegmentIndex
            .bind(to: viewModel.inputs.modalStyleSelectedIndex)
            .disposed(by: disposeBag)
    }
}
