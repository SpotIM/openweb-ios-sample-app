import Combine
import Foundation
import UIKit

final class ConversationWrapperFlowCoordinator: BaseCoordinator<Void> {

    private let router: Routering
    private var viewModel: MockArticleFlowsPartialScreenViewModeling?

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> AnyPublisher<Void, Never> {

        guard let data = coordinatorData,
              case CoordinatorData.actionsFlowPartialScreenSettings(let settings) = data,
              case .fullConversation = settings.actionType else {
            fatalError("ConversationWrapperFlowCoordinator requires coordinatorData from `CoordinatorData.actionsFlowPartialScreenSettings` with `.fullConversation` action type")
        }

        let completion = PassthroughSubject<Void, Never>()
        let wrapperVC = ConversationWrapperVC()

        let viewModel: MockArticleFlowsPartialScreenViewModeling = MockArticleFlowsPartialScreenViewModel(actionSettings: settings)
        self.viewModel = viewModel
        viewModel.inputs.setPresentationalVC(wrapperVC)

        viewModel.outputs.showFullConversation
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak wrapperVC] conversationViewController in
                wrapperVC?.setConversationViewController(conversationViewController)
            })
            .store(in: &cancellables)

        viewModel.outputs.showError
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak wrapperVC] message in
                guard let wrapperVC else { return }
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                wrapperVC.present(alert, animated: true)
            })
            .store(in: &cancellables)

        #if !PUBLIC_DEMO_APP
        wrapperVC.configureLogger(
            floatingViewModel: viewModel.outputs.floatingViewViewModel,
            loggerViewModel: viewModel.outputs.loggerViewModel,
            loggerEnabled: viewModel.outputs.loggerEnabled
        )
        #endif

        router.push(wrapperVC,
                    animated: true,
                    completion: completion)

        return completion
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.viewModel = nil
            })
            .eraseToAnyPublisher()
    }
}
