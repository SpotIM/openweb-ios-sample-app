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

    convenience init(conversationViewController: UIViewController) {
        self.init()
        setConversationViewController(conversationViewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        applyAccessibility()
    }

    func setConversationViewController(_ viewController: UIViewController) {
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        addConversationViewController(viewController)
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
    }

    func addConversationViewController(_ conversationViewController: UIViewController) {
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
