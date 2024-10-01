//
//  OWCommenterAppealCoordinator.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 01/11/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

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
    fileprivate let viewActionsCallbacks: OWViewActionsCallbacks?
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: viewActionsCallbacks, viewSourceType: .commenterAppeal)
    }()

    let presentationalMode: OWPresentationalModeCompact
    let popAppealWithAnimation = PublishSubject<Void>()

    fileprivate let data: OWAppealRequiredData
    fileprivate var commenterAppealView: UIView?

    init(router: OWRoutering? = nil,
         appealData: OWAppealRequiredData,
         viewActionsCallbacks: OWViewActionsCallbacks?,
         presentationalMode: OWPresentationalModeCompact = .none) {
        self.router = router
        self.viewActionsCallbacks = viewActionsCallbacks
        self.presentationalMode = presentationalMode
        self.data = appealData
    }

    override func start(coordinatorData: OWCoordinatorData? = nil) -> Observable<OWCommenterAppealCoordinatorResult> {
        guard let router = router else { return .empty() }
        let commenterAppealVM: OWCommenterAppealViewModeling = OWCommenterAppealVM(
            data: data,
            viewableMode: .partOfFlow,
            presentationalMode: presentationalMode
        )
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
        let commenterAppealViewVM: OWCommenterAppealViewViewModeling = OWCommenterAppealViewVM(
            data: data,
            viewableMode: .independent,
            presentationalMode: presentationalMode
        )
        setupViewActionsCallbacks(forViewModel: commenterAppealViewVM)
        setupObservers(for: commenterAppealViewVM)

        let commenterAppealView = OWCommenterAppealView(viewModel: commenterAppealViewVM)
        self.commenterAppealView = commenterAppealView
        return .just(commenterAppealView)
    }
}

fileprivate extension OWCommenterAppealCoordinator {
    // swiftlint:disable function_body_length
    func setupObservers(for viewModel: OWCommenterAppealViewViewModeling) {
        // Appeal OWTextViewVM - General
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
            .delay(.milliseconds(Metrics.delayTapForOpenAdditionalInfo), scheduler: MainScheduler.asyncInstance)
            .map { placeholderText, textViewText -> OWAdditionalInfoViewViewModel in
                return OWAdditionalInfoViewViewModel(viewableMode: viewModel.outputs.viewableMode,
                                                     placeholderText: placeholderText,
                                                     textViewText: textViewText,
                                                     textViewMaxCharecters: viewModel.outputs.textViewVM.outputs.textViewMaxCharecters,
                                                     charectersLimitEnabled: true,
                                                     showCharectersLimit: true,
                                                     isTextRequired: viewModel.outputs.selectedReason.map { $0.requiredAdditionalInfo },
                                                     minimumTextLength: Observable.just(0),
                                                     submitInProgress: viewModel.outputs.submitInProgress,
                                                     submitText: viewModel.outputs.submitButtonText)
            }
            .share()

        // Open Additional information - Flow
        additionalInformationObservable
            .filter { _ in
                viewModel.outputs.viewableMode == .partOfFlow
            }
            .subscribe(onNext: { [weak self] additionalInfoViewVM in
                guard let self = self else { return }
                guard let router = self.router else { return }
                OWScheduler.runOnMainThreadIfNeeded {
                    let additionalInfoViewVC = OWAdditionalInfoVC(additionalInfoViewViewModel: additionalInfoViewVM)
                    router.push(additionalInfoViewVC, pushStyle: .regular, animated: true, popCompletion: nil)
                }
            })
            .disposed(by: disposeBag)

        // Open Additional information - Independent
        let additionalInformationViewObservable = additionalInformationObservable
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .map { [weak self] additionalInfoViewVM -> OWAdditionalInfoView? in
                guard let self = self else { return nil }
                var additionalInfoView: OWAdditionalInfoView?
                OWScheduler.runOnMainThreadIfNeeded {
                    additionalInfoView = OWAdditionalInfoView(viewModel: additionalInfoViewVM)
                    self.displayViewWithAnimation(view: additionalInfoView!)
                }
                return additionalInfoView
            }
            .unwrap()
            .share()

        additionalInformationViewObservable
            .subscribe()
            .disposed(by: disposeBag)

        // Close Additional information tapped - Independent
        additionalInformationObservable
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .flatMap { additionalInfoViewVM -> Observable<Void> in
                return additionalInfoViewVM.outputs.closeAdditionalInfoTapped
            }
            .withLatestFrom(additionalInformationViewObservable)
            .subscribe(onNext: { additionalInformationView in
                OWScheduler.runOnMainThreadIfNeeded { [weak self] in
                    self?.removeViewWithAnimation(view: additionalInformationView)
                }
            })
            .disposed(by: disposeBag)

        // Additional information cancel - General
        let cancelAdditionalInfoTapped = additionalInformationObservable
            .flatMap { additionalInfoViewVM -> Observable<Void> in
                return additionalInfoViewVM.outputs.cancelAdditionalInfoTapped
            }

        // Additional information empty text close - General
        let additionalInfoCloseAppealTapped = additionalInformationObservable
            .flatMap { additionalInfoViewVM -> Observable<Void> in
                return additionalInfoViewVM.outputs.closeReportReasonTapped
            }

        // Close Additional information - Independed
        let closeAdditionalInfoCallbackObservable = additionalInfoCloseAppealTapped
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .map { OWViewActionCallbackType.closeClarityDetails }

        // Close Additional information - Flow
        additionalInfoCloseAppealTapped
            .filter { _ in
                viewModel.outputs.viewableMode == .partOfFlow
            }
            .do(onNext: { [weak self] in
                guard let self = self,
                      let router = router else { return }

                // dismiss additional info VC
                router.pop(popStyle: .dismiss, animated: false)
            })
            .bind(to: self.popAppealWithAnimation)
            .disposed(by: disposeBag)

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

        // Open cancel observable - General
        let cancelAppeal = Observable.merge(viewModel.outputs.cancelAppeal,
                                            cancelAdditionalInfoTapped)
            .map { _ -> OWCancelViewViewModel in
                return OWCancelViewViewModel(type: .commenterAppeal)
            }
            .share()

        // Open cancel view - Flow
        cancelAppeal
            .filter { _ in
                viewModel.outputs.viewableMode == .partOfFlow
            }
            .subscribe(onNext: { [weak self] vm in
                guard let self = self else { return }
                guard let router = self.router else { return }
                let cancelVM = OWCancelViewModel(cancelViewViewModel: vm)
                let cancelVC = OWCancelVC(cancelViewModel: cancelVM)

                router.push(cancelVC, pushStyle: .present, animated: true, popCompletion: nil)
            })
            .disposed(by: disposeBag)

        // Open cancel view - Independent
        let cancelViewObservable = cancelAppeal
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .map { [weak self] vm -> OWCancelView? in
                guard let self = self else { return nil }
                var cancelView: OWCancelView?
                OWScheduler.runOnMainThreadIfNeeded {
                    cancelView = OWCancelView(viewModel: vm)
                    self.displayViewWithAnimation(view: cancelView!)
                }
                return cancelView
            }
            .unwrap()
            .share()

        // Subscribe to above - Independed
        cancelViewObservable
            .subscribe()
            .disposed(by: disposeBag)

        // Close cancel screen - Flow
        cancelAppeal
            .filter { _ in
                viewModel.outputs.viewableMode == .partOfFlow
            }
            .flatMap { cancelViewVM -> Observable<Void> in
                return cancelViewVM.outputs.closeTapped
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard let router = self.router else { return }

                router.pop(popStyle: .dismiss, animated: true)
            })
            .disposed(by: disposeBag)

        // Close cancel screen - Independed
        cancelAppeal
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .flatMap { cancelViewVM -> Observable<Void> in
                return cancelViewVM.outputs.closeTapped
            }
            .withLatestFrom(cancelViewObservable)
            .subscribe(onNext: { cancelView in
                OWScheduler.runOnMainThreadIfNeeded { [weak self] in
                    self?.removeViewWithAnimation(view: cancelView)
                }
            })
            .disposed(by: disposeBag)

        // Cancel Appeal - Flow
        cancelAppeal
            .filter { _ in
                viewModel.outputs.viewableMode == .partOfFlow
            }
            .flatMap { cancelViewVM -> Observable<Void> in
                return cancelViewVM.outputs.cancelTapped
            }
            .do(onNext: { [weak self] in
                guard let self = self else { return }

                // dismiss cancel appeal VC
                self.router?.pop(popStyle: .dismiss, animated: false)
            })
            .bind(to: self.popAppealWithAnimation)
            .disposed(by: disposeBag)

        // Cancel Appeal - independent
        let closeAppealCallbackObservable = cancelAppeal
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .flatMap { cancelViewVM -> Observable<Void> in
                cancelViewVM.outputs.cancelTapped
            }
            .map { OWViewActionCallbackType.closeClarityDetails }

        // Open submitted observable - Flow
        let closeSubmitted = Observable.merge(viewModel.outputs.appealSubmittedSuccessfully)
            .filter { _ in
                viewModel.outputs.viewableMode == .partOfFlow
            }
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                guard let router = self.router else { return .empty() }
                let submittedViewVM = OWSubmittedViewViewModel(type: .commenterAppeal)
                let submittedVC = OWSubmittedVC(submittedViewViewModel: submittedViewVM)

                router.push(submittedVC, pushStyle: .present, animated: true, popCompletion: nil)
                return submittedViewVM.outputs.closeSubmittedTapped
            }

        // Open Submitted Screen - Independent
        let closeSubmittedViewTapped = viewModel.outputs.appealSubmittedSuccessfully
            .filter { _ in viewModel.outputs.viewableMode == .independent }
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                let submittedViewVM = OWSubmittedViewViewModel(type: .commenterAppeal)

                OWScheduler.runOnMainThreadIfNeeded {
                    let submittedView = OWSubmittedView(viewModel: submittedViewVM)
                    self.displayViewWithAnimation(view: submittedView)
                }

                return submittedViewVM.outputs.closeSubmittedTapped
            }

        // Close from Submitted Screen
        let closeSubmittedCallbackObservable = closeSubmittedViewTapped
            .map { OWViewActionCallbackType.closeClarityDetails }

        // Close submitted
        closeSubmitted
            .do(onNext: { [weak self] in
                guard let self = self,
                      let router = router else { return }

                // dismiss submitted appeal VC
                router.pop(popStyle: .dismiss, animated: false)

                let visableViewController = router.navigationController?.visibleViewController
                let isAppealVC = visableViewController?.isKind(of: OWCommenterAppealVC.self) ?? false

                // For dismissing details screen
                if !isAppealVC {
                    router.pop(popStyle: .dismiss, animated: false)
                }
            })
            .bind(to: self.popAppealWithAnimation)
            .disposed(by: disposeBag)

        // Setup view actions callbacks - Independent mode only
        Observable.merge(closeAppealCallbackObservable,
                         closeAdditionalInfoCallbackObservable,
                         closeSubmittedCallbackObservable)
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .subscribe(onNext: { [weak self] viewAction in
                guard let self = self else { return }
                self.viewActionsService.append(viewAction: viewAction)
            })
            .disposed(by: disposeBag)
    }
    // swiftlint:enable function_body_length

    func setupViewActionsCallbacks(forViewModel viewModel: OWCommenterAppealViewViewModeling) {
        guard viewModel.outputs.viewableMode == .independent else { return }

        guard viewActionsCallbacks != nil else { return } // Make sure actions callbacks are available/provided

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

    // Use to display screens in independed mode
    func displayViewWithAnimation(view: UIView) {
        view.alpha = 0
        self.commenterAppealView?.addSubview(view)
        UIView.animate(withDuration: Metrics.fadeDuration) {
            view.alpha = 1
        }
        view.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func removeViewWithAnimation(view: UIView) {
        UIView.animate(withDuration: Metrics.fadeDuration) {
            view.alpha = 0
        } completion: { _ in
            view.removeFromSuperview()
        }
    }
}
