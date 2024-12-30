//
//  PreconversationWithAdViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 11/12/2024.
//

import RxSwift
import OpenWebSDK

protocol PreconversationWithAdViewModelingInputs {}

protocol PreconversationWithAdViewModelingOutputs {
    var title: String { get }
    var articleImageURL: Observable<URL> { get }
    var preconversationCellViewModel: PreconversationCellViewModeling { get }
    var independentAdCellViewModel: IndependentAdCellViewModeling { get }
    var cells: Observable<[PreconversationWithAdCellOption]> { get }
    var loggerEnabled: Observable<Bool> { get }
    var floatingViewViewModel: OWFloatingViewModeling { get }
    var loggerViewModel: UILoggerViewModeling { get }
}

protocol PreconversationWithAdViewModeling {
    var inputs: PreconversationWithAdViewModelingInputs { get }
    var outputs: PreconversationWithAdViewModelingOutputs { get }
}

class PreconversationWithAdViewModel: PreconversationWithAdViewModeling, PreconversationWithAdViewModelingInputs, PreconversationWithAdViewModelingOutputs {

    var inputs: PreconversationWithAdViewModelingInputs { return self }
    var outputs: PreconversationWithAdViewModelingOutputs { return self }

    private let disposeBag = DisposeBag()
    private let imageProviderAPI: ImageProviding
    private let postId: OWPostId
    private let userDefaultsProvider: UserDefaultsProviderProtocol
    private let actionSettings: SDKUIFlowActionSettings
    private let commonCreatorService: CommonCreatorServicing
    private let _articleImageURL = BehaviorSubject<URL?>(value: nil)
    var cells: Observable<[PreconversationWithAdCellOption]> = Observable.just(PreconversationWithAdCellOption.allCases)
    var articleImageURL: Observable<URL> {
        return _articleImageURL
            .unwrap()
            .asObservable()
    }

    lazy var preconversationCellViewModel: PreconversationCellViewModeling = {
        PreconversationCellViewModel(
            userDefaultsProvider: userDefaultsProvider,
            actionSettings: actionSettings,
            commonCreatorService: commonCreatorService
        )
    }()

    lazy var independentAdCellViewModel: IndependentAdCellViewModeling = {
        IndependentAdCellViewModel(postId: postId)
    }()

    lazy var title: String = {
        return NSLocalizedString("MockArticle", comment: "")
    }()

    var loggerEnabled: Observable<Bool> {
        return preconversationCellViewModel.outputs.loggerEnabled
    }

    var loggerViewModel: UILoggerViewModeling {
        return preconversationCellViewModel.outputs.loggerViewModel
    }

    lazy var floatingViewViewModel: OWFloatingViewModeling = {
        return OWFloatingViewModel()
    }()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         silentSSOAuthentication: SilentSSOAuthenticationNewAPIProtocol = SilentSSOAuthenticationNewAPI(),
         commonCreatorService: CommonCreatorServicing = CommonCreatorService(),
         imageProviderAPI: ImageProviding = ImageProvider(),
         actionSettings: SDKUIFlowActionSettings,
         postId: OWPostId
    ) {
        self.userDefaultsProvider = userDefaultsProvider
        self.commonCreatorService = commonCreatorService
        self.imageProviderAPI = imageProviderAPI
        self.actionSettings = actionSettings
        self.postId = postId

        setupObservers()
    }
}

private extension PreconversationWithAdViewModel {
    func setupObservers() {
        let articleURL = imageProviderAPI.randomImageUrl()
        _articleImageURL.onNext(articleURL)
    }
}
