//
//  ConversationWrapperVC.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 09/11/2025.
//

import UIKit
import OpenWebSDK
import SnapKit

class ConversationWrapperVC: UIViewController {

    private struct Metrics {
        static let identifier = "conversation_wrapper_vc_id"
        static let coloredViewHeight: CGFloat = 50
    }

    private let conversationViewController: UIViewController

    private lazy var topColoredView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()

    private lazy var bottomColoredView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()

    init(conversationViewController: UIViewController) {
        self.conversationViewController = conversationViewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        applyAccessibility()
    }
}

private extension ConversationWrapperVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)

        // Add top colored view
        view.addSubview(topColoredView)
        topColoredView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.coloredViewHeight)
        }

        // Add bottom colored view
        view.addSubview(bottomColoredView)
        bottomColoredView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(Metrics.coloredViewHeight)
        }

        // Add conversation view controller as child
        addChild(conversationViewController)
        view.addSubview(conversationViewController.view)
        conversationViewController.view.snp.makeConstraints { make in
            make.top.equalTo(topColoredView.snp.bottom)
            make.bottom.equalTo(bottomColoredView.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        conversationViewController.didMove(toParent: self)
    }
}
