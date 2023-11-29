//
//  OWCommenterAppealCoordinator.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 01/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWCommenterAppealCoordinatorResult: OWCoordinatorResultProtocol {
    case loadedToScreen
    case popped

    var loadedToScreen: Bool {
        switch self {
        case .loadedToScreen:
            return true
        default:
            return false
        }
    }
}

class OWCommenterAppealCoordinator: OWBaseCoordinator<OWCommenterAppealCoordinatorResult> {
    fileprivate struct Metrics {
        static let fadeDuration: CGFloat = 0.3
        static let delayTapForOpenAdditionalInfo = 100 // Time in ms
    }

    fileprivate let router: OWRoutering?
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: actionsCallbacks, viewSourceType: .commenterAppeal)
    }()

    let presentationalMode: OWPresentationalModeCompact
    let popAppealWithAnimation = PublishSubject<Void>()

    fileprivate let data: OWAppealRequiredData

    init(router: OWRoutering? = nil,
         appealData: OWAppealRequiredData,
         actionsCallbacks: OWViewActionsCallbacks?,
         presentationalMode: OWPresentationalModeCompact = .none) {
        self.router = router
        self.actionsCallbacks = actionsCallbacks
        self.presentationalMode = presentationalMode
        self.data = appealData
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWCommenterAppealCoordinatorResult> {
        guard let router = router else { return .empty() }
        let commenterAppealVM: OWCommenterAppealViewModeling = OWCommenterAppealVM(commentId: data.commentId)
        let commenterAppealVC = OWCommenterAppealVC(viewModel: commenterAppealVM)

        setupObservers(for: commenterAppealVM.outputs.commenterAppealViewViewModel)

        let commenterAppealPopped = PublishSubject<Void>()
        router.push(commenterAppealVC,
                    pushStyle: .present,
                    animated: true,
                    popCompletion: commenterAppealPopped)

        setupViewActionsCallbacks(forViewModel: commenterAppealVM.outputs.commenterAppealViewViewModel)

        let poppedFromCloseButtonObservable = commenterAppealVM.outputs.commenterAppealViewViewModel
            .outputs.closeButtonPopped
            .asObservable()

        let loadedToScreenObservable = commenterAppealVM.outputs.loadedToScreen
            .map { OWCommenterAppealCoordinatorResult.loadedToScreen }
            .asObservable()

        let resultsWithPopAnimation = Observable.merge(
            poppedFromCloseButtonObservable,
            commenterAppealVM.outputs.commenterAppealViewViewModel.outputs.closeButtonPopped,
            popAppealWithAnimation.asObservable()
        )
            .map { OWCommenterAppealCoordinatorResult.popped }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.router?.pop(popStyle: .dismiss, animated: true)
            })

        let resultWithoutPopAnimation = commenterAppealPopped
                .asObservable()
                .map { OWCommenterAppealCoordinatorResult.popped }

        return Observable.merge(resultsWithPopAnimation, loadedToScreenObservable, resultWithoutPopAnimation)
    }

    override func showableComponent() -> Observable<OWShowable> {
        let commenterAppealViewVM: OWCommenterAppealViewViewModeling = OWCommenterAppealViewVM(commentId: data.commentId)
        setupViewActionsCallbacks(forViewModel: commenterAppealViewVM)

        let commenterAppealView = OWCommenterAppealView(viewModel: commenterAppealViewVM)
        return .just(commenterAppealView)
    }
}

fileprivate extension OWCommenterAppealCoordinator {
    func setupObservers(for viewModel: OWCommenterAppealViewViewModeling) {
        // ReportReaon OWTextViewVM - General
        let textViewVM = viewModel.outputs.textViewVM

        // Additional information observable - General
        let additionalInformationObservable = textViewVM.outputs.textViewTapped
            .flatMap { _ -> Observable<String> in
                return textViewVM.outputs.placeholderText
                    .take(1)
            }
            .flatMap({ placeholderText -> Observable<(String, String)> in
                return textViewVM.outputs.textViewText
                    .map { (placeholderText, $0) }
                    .take(1)
            })
//            .flatMap({ placeholderText, textViewText -> Observable<(String, String, Bool)> in
//                return viewModel.outputs.reportReasonsCharectersLimitEnabled
//                    .map { (placeholderText, textViewText, $0) }
//                    .take(1)
//            })
            .delay(.milliseconds(Metrics.delayTapForOpenAdditionalInfo), scheduler: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.instance)
            .map { placeholderText, textViewText -> OWAdditionalInfoViewViewModel in
                return OWAdditionalInfoViewViewModel(viewableMode: .partOfFlow, // TODO: viewModel.outputs.viewableMode,
                                                     placeholderText: placeholderText,
                                                     textViewText: textViewText,
                                                     textViewMaxCharecters: viewModel.outputs.textViewVM.outputs.textViewMaxCharecters,
                                                     charectersLimitEnabled: true, // TODO: ?
                                                     isTextRequired: viewModel.outputs.selectedReason.map { $0.requiredAdditionalInfo },
                                                     submitInProgress: viewModel.outputs.submitInProgress,
                                                     submitText: viewModel.outputs.submitButtonText)
            }
            .share()

        // Open Additional information - Flow
        additionalInformationObservable
//            .filter { _ in
//                viewModel.outputs.viewableMode == .partOfFlow
//            }
            .subscribe(onNext: { [weak self] additionalInfoViewVM in
                guard let self = self else { return }
                guard let router = self.router else { return }
                let additionalInfoViewVC = OWAdditionalInfoVC(additionalInfoViewViewModel: additionalInfoViewVM)
                router.push(additionalInfoViewVC, pushStyle: .regular, animated: true, popCompletion: nil)
            })
            .disposed(by: disposeBag)

        // Additional information cancel - General
        let cancelAdditionalInfoTapped = additionalInformationObservable
            .flatMap { additionalInfoViewVM -> Observable<Void> in
                return additionalInfoViewVM.outputs.cancelAdditionalInfoTapped
            }

        // Additional information empty text close - General
        let additionalInfoCloseReportReasonTapped = additionalInformationObservable
            .flatMap { additionalInfoViewVM -> Observable<Void> in
                return additionalInfoViewVM.outputs.closeReportReasonTapped
            }

        // Additional information text changed - General
        additionalInformationObservable
            .flatMap { additionalInformationViewVM -> Observable<String> in
                return additionalInformationViewVM.outputs.additionalInfoTextChanged
            }
            .bind(to: viewModel.inputs.textViewTextChange)
            .disposed(by: disposeBag)

        // Additional information submit - General
        additionalInformationObservable
            .flatMap { additionalInformationViewVM -> Observable<Void> in
                return additionalInformationViewVM.outputs.submitAdditionalInfoTapped
            }
            .bind(to: viewModel.inputs.submitAppealTap)
            .disposed(by: disposeBag)

        // TODO: independed

        // Open cancel observable - General
        let cancelAppeal = Observable.merge(viewModel.outputs.cancelAppeal,
                                            cancelAdditionalInfoTapped)
            .map { _ -> OWCancelViewViewModel in
                return OWCancelViewViewModel(type: .commenterAppeal)
            }
            .share()

        // Open cancel view - Flow
        cancelAppeal
//            .filter { _ in
//                viewModel.outputs.viewableMode == .partOfFlow
//            }
            .subscribe(onNext: { [weak self] vm in
                guard let self = self else { return }
                guard let router = self.router else { return }
                let cancelVM = OWCancelViewModel(cancelViewViewModel: vm)
                let cancelVC = OWCancelVC(cancelViewModel: cancelVM)
                switch self.presentationalMode {
                case .present(style: .fullScreen):
                    cancelVC.modalPresentationStyle = .fullScreen
                case .present(style: .pageSheet):
                    cancelVC.modalPresentationStyle = .pageSheet
                default:
                    cancelVC.modalPresentationStyle = .fullScreen
                }
                router.present(cancelVC, animated: true, dismissCompletion: nil)
            })
            .disposed(by: disposeBag)

        // Close cancel screen - Flow
        cancelAppeal
//            .filter { _ in
//                viewModel.outputs.viewableMode == .partOfFlow
//            }
            .flatMap { cancelViewVM -> Observable<Void> in
                return cancelViewVM.outputs.closeTapped
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard let router = self.router else { return }
                router.navigationController?.visibleViewController?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        // Cancel Appeal - Flow
        cancelAppeal
            .flatMap { cancelViewVM -> Observable<Void> in
                return cancelViewVM.outputs.cancelTapped
            }
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                let visableViewController = self.router?.navigationController?.visibleViewController

                // dismiss cancel appeal VC
                visableViewController?.dismiss(animated: false)
            })
            .bind(to: self.popAppealWithAnimation)
            .disposed(by: disposeBag)
    }

    func setupViewActionsCallbacks(forViewModel viewModel: OWCommenterAppealViewViewModeling) {
//        guard viewModel.outputs.viewableMode == .independent else { return } // TODO: 
        guard actionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided

        let closeButtonClick = viewModel.outputs.closeButtonPopped
            .map { OWViewActionCallbackType.closeClarityDetails }

        Observable.merge(
            closeButtonClick
        )
        .subscribe(onNext: { [weak self] viewActionType in
            self?.viewActionsService.append(viewAction: viewActionType)
        })
        .disposed(by: disposeBag)
    }
}
