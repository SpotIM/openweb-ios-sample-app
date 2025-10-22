//
//  UIFlowsConversationBelowVideoVC.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 28/09/2025.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit
import OpenWebSDK

class UIFlowsConversationBelowVideoVC: UIViewController {
    private struct Metrics {
        static let identifier = "uiflows_examples_vc_id"
    }

    private let viewModel: UIFlowsConversationBelowVideoViewModeling
    private var cancellables = Set<AnyCancellable>()

    private lazy var videoPlayerContainer: UIView = {
        let view = VideoExampleView(viewModel: viewModel.outputs.videoExampleViewModel)
        return view
    }()

    init(viewModel: UIFlowsConversationBelowVideoViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        applyAccessibility()
        setupObservers()
        viewModel.outputs.videoExampleViewModel.inputs.play()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

private extension UIFlowsConversationBelowVideoVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        self.navigationItem.largeTitleDisplayMode = .never

        // Adding video player view
        view.addSubview(videoPlayerContainer)
        videoPlayerContainer.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        // Showing error if needed
        viewModel.outputs.componentRetrievingError
            .sink(receiveValue: { [weak self] err in
                self?.showError(message: err.description)
            })
            .store(in: &cancellables)

        viewModel.outputs.conversationRetrieved
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] conversationVc in
                guard let self else { return }
                self.view.addSubview(conversationVc.view)
                self.addChild(conversationVc)

                conversationVc.view.snp.makeConstraints { make in
                    make.top.equalTo(self.videoPlayerContainer.snp.bottom)
                    make.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
                }
                conversationVc.didMove(toParent: self)
            })
            .store(in: &cancellables)

        viewModel.outputs.openAuthentication
            .flatMap { [weak self] result -> AnyPublisher<OWBasicCompletion, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let spotId = result.0
                let completion = result.1
                let authenticationVM = AuthenticationPlaygroundViewModel(filterBySpotId: spotId)
                let authenticationVC = AuthenticationPlaygroundVC(viewModel: authenticationVM)
                self.navigationController?.present(authenticationVC, animated: true)

                return authenticationVM.outputs.dismissed
                    .prefix(1)
                    .map { completion }
                    .eraseToAnyPublisher()
            }
            .sink(receiveValue: { completion in
                completion()
            })
            .store(in: &cancellables)
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error retrieving component", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
