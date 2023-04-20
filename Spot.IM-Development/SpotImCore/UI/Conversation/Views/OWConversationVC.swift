//
//  OWConversationVC.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWConversationVC: UIViewController {
    fileprivate struct Metrics {
        static let navigationTitleFontSize: CGFloat = 18.0
    }

    fileprivate let viewModel: OWConversationViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var conversationView: OWConversationView = {
        return OWConversationView(viewModel: viewModel.outputs.conversationViewVM)
    }()

    fileprivate lazy var closeButton: UIButton = {
        let closeButton = UIButton()
            .image(UIImage(spNamed: "closeButton", supportDarkMode: true), state: .normal)
            .horizontalAlignment(.left)

        closeButton.addTarget(self, action: #selector(self.closeConversationTapped(_:)), for: .touchUpInside)
        return closeButton
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWConversationViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        super.loadView()
        setupUI()
        setupObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.inputs.viewDidLoad.onNext()
    }
}

fileprivate extension OWConversationVC {
    func setupUI() {
        view.addSubview(conversationView)
        conversationView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        setupNavControllerUI()
    }

    func setupNavControllerUI(_ style: OWThemeStyle = OWSharedServicesProvider.shared.themeStyleService().currentStyle) {
        let navController = self.navigationController

        // Setup close button
        if viewModel.outputs.shouldShowCloseButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        }

        title = LocalizationManager.localizedString(key: "Conversation")

        if viewModel.outputs.shouldCustomizeNavigationBar {
            navController?.navigationBar.isTranslucent = false
            let navigationBarBackgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: style)

            // Setup Title
            let navigationTitleTextAttributes = [
                NSAttributedString.Key.font: OWFontBook.shared.font(style: .bold, size: Metrics.navigationTitleFontSize),
                NSAttributedString.Key.foregroundColor: OWColorPalette.shared.color(type: .textColor1, themeStyle: style)
            ]

            if #available(iOS 13.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = navigationBarBackgroundColor
                appearance.titleTextAttributes = navigationTitleTextAttributes

                // Setup Back button
                let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
                backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
                appearance.backButtonAppearance = backButtonAppearance

                navController?.navigationBar.standardAppearance = appearance
                navController?.navigationBar.scrollEdgeAppearance = navController?.navigationBar.standardAppearance
            } else {
                navController?.navigationBar.backgroundColor = navigationBarBackgroundColor
                navController?.navigationBar.titleTextAttributes = navigationTitleTextAttributes
            }
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.closeButton.image(UIImage(spNamed: "closeButton", supportDarkMode: true), state: .normal)
                self.setupNavControllerUI(currentStyle)
            })
            .disposed(by: disposeBag)
    }

    @objc func closeConversationTapped(_ sender: UIBarButtonItem) {
        viewModel.inputs.closeConversationTapped.onNext()
    }
}
