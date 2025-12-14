//
//  ConversationWrapperVC.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 09/11/2025.
//

import UIKit
import OpenWebSDK
import SnapKit
import Combine

class ConversationWrapperVC: UIViewController {

    private struct Metrics {
        static let identifier = "conversation_wrapper_vc_id"
        static let coloredViewHeight: CGFloat = 50
        static let loggerViewWidth: CGFloat = 300
        static let loggerViewHeight: CGFloat = 250
        static let loggerInitialTopPadding: CGFloat = 50
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

    private lazy var bottomResizeGripView = ResizeGripView()
    private lazy var topResizeGripView = ResizeGripView()

    private var cancellables = Set<AnyCancellable>()
    private var floatingLoggerView: OWFloatingView?

    convenience init(conversationViewController: UIViewController) {
        self.init()
        setConversationViewController(conversationViewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        applyAccessibility()
    }

    deinit {
        floatingLoggerView?.removeFromSuperview()
        cancellables.removeAll()
    }

    func setConversationViewController(_ viewController: UIViewController) {
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        addConversationViewController(viewController)
    }

    #if !PUBLIC_DEMO_APP
    func configureLogger(floatingViewModel: OWFloatingViewModeling,
                         loggerViewModel: UILoggerViewModeling,
                         loggerEnabled: AnyPublisher<Bool, Never>) {
        let loggerView = UILoggerView(viewModel: loggerViewModel)

        // Add floating view to the window immediately (hidden), then toggle via setting
        if self.floatingLoggerView == nil {
            let floatingView = OWFloatingView(viewModel: floatingViewModel)
            self.floatingLoggerView = floatingView

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                floatingView.isHidden = true
                keyWindow.addSubview(floatingView)
                floatingView.snp.makeConstraints { make in
                    make.width.equalTo(Metrics.loggerViewWidth)
                    make.height.equalTo(Metrics.loggerViewHeight)
                    make.top.equalToSuperview().offset(Metrics.loggerInitialTopPadding)
                    make.centerX.equalToSuperview()
                }
                floatingViewModel.inputs.setContentView.send(loggerView)
            }
        }

        loggerEnabled
            .delay(for: .milliseconds(10), scheduler: DispatchQueue.main) // swiftlint:disable:this no_magic_numbers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                guard let self else { return }
                self.floatingLoggerView?.isHidden = !enabled
            }
            .store(in: &cancellables)
    }
    #endif
}

private extension ConversationWrapperVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)

        // Add top colored view
        view.addSubview(topColoredView)
        var topHeightConstraint: Constraint?
        topColoredView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            topHeightConstraint = make.height.equalTo(Metrics.coloredViewHeight).constraint
        }
        topResizeGripView.attach(to: topColoredView, heightConstraint: topHeightConstraint!, position: .bottom)

        // Add bottom colored view
        view.addSubview(bottomColoredView)
        var bottomHeightConstraint: Constraint?
        bottomColoredView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            bottomHeightConstraint = make.height.equalTo(Metrics.coloredViewHeight).constraint
        }
        bottomResizeGripView.attach(to: bottomColoredView, heightConstraint: bottomHeightConstraint!)
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
