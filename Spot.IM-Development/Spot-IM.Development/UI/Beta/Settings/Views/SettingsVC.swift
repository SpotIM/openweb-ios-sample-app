//
//  SettingsVC.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 18/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

#if NEW_API

class SettingsVC: UIViewController {

    fileprivate struct Metrics {
        static let identifier = "settings_vc_id"
        static let verticalOffset: CGFloat = 40
    }

    fileprivate lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    fileprivate lazy var settingViews: [UIView] = {
        let views = viewModel.outputs.settingsVMs.map { SettingsViewsFactory.factor(from: ($0)) }.unwrap()
        return views
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
        applyAccessibility()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

fileprivate extension SettingsVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)

        title = viewModel.outputs.title

        // Adding scroll view
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }

        var previousView: UIView? = nil
        for (index, settingsView) in settingViews.enumerated() {
            scrollView.addSubview(settingsView)
            settingsView.snp.makeConstraints { make in
                make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
                if let topView = previousView {
                    // This is an intermidiate settingsView, Set the top constraint to previous settingsView
                    make.top.equalTo(topView.snp.bottom).offset(Metrics.verticalOffset)
                } else {
                    // Telling the scroll view that this is the first settingsView
                    make.top.equalTo(scrollView.contentLayoutGuide).offset(Metrics.verticalOffset)
                }
                if index == settingViews.count - 1 {
                    // Telling the scroll view that this is the last settingsView
                    make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-Metrics.verticalOffset)
                }
                previousView = settingsView
            }
        }
    }

//    func view(forType type: SettingsGroupType) -> UIView {
//        let userDefaultsProvider = viewModel.outputs.userDefaultsProvider
//        let manager = viewModel.outputs.manager
//        switch type {
//        case .general:
//            return GeneralSettingsView(viewModel: GeneralSettingsVM(userDefaultsProvider: userDefaultsProvider, manager: manager))
//        case .preConversation:
//            return PreConversationSettingsView(viewModel: PreConversationSettingsVM(userDefaultsProvider: userDefaultsProvider))
//        case .conversation:
//            return ConversationSettingsView(viewModel: ConversationSettingsVM(userDefaultsProvider: userDefaultsProvider))
//        case .commentCreation:
//            return CommentCreationSettingsView(viewModel: CommentCreationSettingsVM(userDefaultsProvider: userDefaultsProvider))
//        case .iau:
//            return IAUSettingsView(viewModel: IAUSettingsVM(userDefaultsProvider: userDefaultsProvider))
//        }
//    }
}
#endif
