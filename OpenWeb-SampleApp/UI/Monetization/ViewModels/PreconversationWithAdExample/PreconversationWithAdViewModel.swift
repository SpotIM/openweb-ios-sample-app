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

    var cells: Observable<[PreconversationWithAdCellOption]> = Observable.just(PreconversationWithAdCellOption.allCases)
    private let _articleImageURL = BehaviorSubject<URL?>(value: nil)
    var articleImageURL: Observable<URL> {
        return _articleImageURL
            .unwrap()
            .asObservable()
    }

    var preconversationCellViewModel: PreconversationCellViewModeling
    lazy var independentAdCellViewModel: IndependentAdCellViewModeling = {
        IndependentAdCellViewModel(postId: postId)
    }()

    lazy var title: String = {
        return NSLocalizedString("MockArticle", comment: "")
    }()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         silentSSOAuthentication: SilentSSOAuthenticationNewAPIProtocol = SilentSSOAuthenticationNewAPI(),
         commonCreatorService: CommonCreatorServicing = CommonCreatorService(),
         imageProviderAPI: ImageProviding = ImageProvider(),
         actionSettings: SDKUIFlowActionSettings,
         postId: OWPostId
    ) {
        self.imageProviderAPI = imageProviderAPI
        self.postId = postId
        self.preconversationCellViewModel = PreconversationCellViewModel(
            userDefaultsProvider: userDefaultsProvider,
            actionSettings: actionSettings,
            commonCreatorService: commonCreatorService
        )
        setupObservers()
    }
}

private extension PreconversationWithAdViewModel {
    func setupObservers() {
        let articleURL = imageProviderAPI.randomImageUrl()
        _articleImageURL.onNext(articleURL)
    }
}
