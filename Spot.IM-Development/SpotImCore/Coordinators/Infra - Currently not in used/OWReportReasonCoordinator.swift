//
//  OWReportReasonCoordinator.swift
//  SpotImCore
//
//  Created by Refael Sommer on 20/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWReportReasonCoordinatorResult: OWCoordinatorResultProtocol {
    case loadedToScreen
    case popped
    case submitedReport(report: OWReportReason)

    var loadedToScreen: Bool {
        switch self {
        case .loadedToScreen:
            return true
        default:
            return false
        }
    }
}

class OWReportReasonCoordinator: OWBaseCoordinator<OWReportReasonCoordinatorResult> {
    fileprivate struct Metrics {
        static let fadeDuration: CGFloat = 0.3
        static let errorAlertActionKey = "GotIt"
    }

    fileprivate let commentId: OWCommentId
    fileprivate let router: OWRoutering?
    fileprivate let actionsCallbacks: OWViewActionsCallbacks?
    fileprivate lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: actionsCallbacks, viewSourceType: .reportReason)
    }()
    fileprivate let reportReasonPopped = PublishSubject<Void>()
    let presentationalMode: OWPresentationalModeCompact
    var reportReasonView: UIView?

    init(commentId: OWCommentId,
         router: OWRoutering? = nil,
         actionsCallbacks: OWViewActionsCallbacks?,
         presentationalMode: OWPresentationalModeCompact = .none) {
        self.commentId = commentId
        self.router = router
        self.actionsCallbacks = actionsCallbacks
        self.presentationalMode = presentationalMode
    }

    override func start(deepLinkOptions: OWDeepLinkOptions? = nil) -> Observable<OWReportReasonCoordinatorResult> {
        guard let router = router else { return .empty() }
        let reportReasonVM: OWReportReasonViewModeling = OWReportReasonViewModel(commentId: commentId,
                                                                                 viewableMode: .partOfFlow,
                                                                                 presentMode: self.presentationalMode)
        let reportReasonVC = OWReportReasonVC(viewModel: reportReasonVM)

        router.start()

        if router.isEmpty() {
            router.setRoot(reportReasonVC, animated: false, dismissCompletion: reportReasonPopped)
        } else {
            router.push(reportReasonVC,
                        pushStyle: .presentStyle,
                        animated: true,
                        popCompletion: reportReasonPopped)
        }

        setupObservers(forViewModel: reportReasonVM)
        setupViewActionsCallbacks(forViewModel: reportReasonVM.outputs.reportReasonViewViewModel)

        let reportReasonPoppedObservable = reportReasonPopped
            .map { OWReportReasonCoordinatorResult.popped }
            .asObservable()

        let reportReasonLoadedToScreenObservable = reportReasonVM.outputs.loadedToScreen
            .map { OWReportReasonCoordinatorResult.loadedToScreen }
            .asObservable()

        return Observable.merge(reportReasonPoppedObservable, reportReasonLoadedToScreenObservable)
    }

    override func showableComponent() -> Observable<OWShowable> {
        // TODO: Complete when we would like to support comment creation as a view
        let reportReasonViewVM: OWReportReasonViewViewModeling = OWReportReasonViewViewModel(commentId: commentId,
                                                                                             viewableMode: .independent,
                                                                                             presentationalMode: .none,
                                                                                             servicesProvider: OWSharedServicesProvider.shared)
        setupViewActionsCallbacks(forViewModel: reportReasonViewVM)

        let reportReasonView = OWReportReasonView(viewModel: reportReasonViewVM)
        self.reportReasonView = reportReasonView
        return .just(reportReasonView)
    }
}

fileprivate extension OWReportReasonCoordinator {
    func setupObservers(forViewModel viewModel: OWReportReasonViewModeling) {
        // Setting up general observers which affect app flow however not entirely inside the SDK
    }

    // swiftlint:disable function_body_length
    func setupViewActionsCallbacks(forViewModel viewModel: OWReportReasonViewViewModeling) {
    // swiftlint:enable function_body_length
        // Open Cancel - Independent
        viewModel.outputs.cancelReportReasonTapped
            .filter { viewModel.outputs.viewableMode == .independent }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let reportReasonCancelViewVM = OWReportReasonCancelViewViewModel()
                let reportReasonCancelView = OWReportReasonCancelView(viewModel: reportReasonCancelViewVM)

                reportReasonCancelView.alpha = 0
                self.reportReasonView?.addSubview(reportReasonCancelView)
                UIView.animate(withDuration: Metrics.fadeDuration) {
                    reportReasonCancelView.alpha = 1
                }
                reportReasonCancelView.OWSnp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }

                reportReasonCancelViewVM.closeReportReasonCancelTap
                    .subscribe(onNext: { _ in
                        UIView.animate(withDuration: Metrics.fadeDuration) {
                            reportReasonCancelView.alpha = 0
                        } completion: { _ in
                            reportReasonCancelView.removeFromSuperview()
                        }
                    })
                    .disposed(by: self.disposeBag)

                reportReasonCancelViewVM.cancelReportReasonCancelTap
                    .map { OWViewActionCallbackType.closeReportReason }
                    .subscribe { [weak self] viewActionType in
                        guard let self = self else { return }
                        self.viewActionsService.append(viewAction: viewActionType)
                    }
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)

        // Submit - Open Thanks Screen - Independent
        viewModel.outputs.submittedReportReasonObservable
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let reportReasonThanksViewVM = OWReportReasonThanksViewViewModel()
                let reportReasonThanksView = OWReportReasonThanksView(viewModel: reportReasonThanksViewVM)

                reportReasonThanksView.alpha = 0
                self.reportReasonView?.addSubview(reportReasonThanksView)
                UIView.animate(withDuration: Metrics.fadeDuration) {
                    reportReasonThanksView.alpha = 1
                }
                reportReasonThanksView.OWSnp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }

                reportReasonThanksViewVM.closeReportReasonThanksTap
                    .map { OWViewActionCallbackType.closeReportReason }
                    .subscribe { [weak self] viewActionType in
                        guard let self = self else { return }
                        self.viewActionsService.append(viewAction: viewActionType)
                    }
                    .disposed(by: disposeBag)
            })
            .disposed(by: disposeBag)

        // Submit - Open Thanks Screen - Flow
        viewModel.outputs.submittedReportReasonObservable
            .filter { _ in
                viewModel.outputs.viewableMode == .partOfFlow
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard let router = self.router else { return }
                let reportReasonThanksViewVM = OWReportReasonThanksViewViewModel()
                let reportReasonThanksVC = OWReportReasonThanksVC(reportReasonThanksViewViewModel: reportReasonThanksViewVM)
                reportReasonThanksVC.modalPresentationStyle = .fullScreen
                router.present(reportReasonThanksVC, animated: true, dismissCompletion: nil)

//                reportReasonThanksViewVM.closeReportReasonThanksTap
//                    .subscribe(onNext: { [weak self] _ in
//                        guard let self = self else { return }
//                        guard let router = self.router else { return }
//                        reportReasonThanksVC.dismiss(animated: true)
//                        router.pop(animated: false)
//                    })
//                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)

        let reportTextViewVM = viewModel.outputs.textViewVM

        // Open Additional information - Independent
        reportTextViewVM.outputs.textViewTapped
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .flatMap { _ -> Observable<(String, String)> in
                return Observable.combineLatest(reportTextViewVM.outputs.placeholderText,
                                                reportTextViewVM.outputs.textViewText)
                .take(1)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] placeholderText, textViewText in
                guard let self = self else { return }
                let additionalInfoViewVM = OWAdditionalInfoViewViewModel(viewableMode: viewModel.outputs.viewableMode,
                                                                         placeholderText: placeholderText,
                                                                         textViewText: textViewText,
                                                                         isTextRequired: viewModel.outputs.selectedReason.map { $0.requiredAdditionalInfo },
                                                                         submitInProgress: viewModel.outputs.submitInProgress)
                let additionalInfoView = OWAdditionalInfoView(viewModel: additionalInfoViewVM)

                additionalInfoView.alpha = 0
                self.reportReasonView?.addSubview(additionalInfoView)
                UIView.animate(withDuration: Metrics.fadeDuration) {
                    additionalInfoView.alpha = 1
                }
                additionalInfoView.OWSnp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }

                additionalInfoViewVM.outputs.cancelAdditionalInfoTapped
                    .take(1)
                    .subscribe(onNext: { _ in
                        UIView.animate(withDuration: Metrics.fadeDuration) {
                            additionalInfoView.alpha = 0
                        } completion: { _ in
                            additionalInfoView.removeFromSuperview()
                        }
                    })
                    .disposed(by: self.disposeBag)

                additionalInfoViewVM.outputs.submitAdditionalInfoTapped
                    .withLatestFrom(additionalInfoViewVM.outputs.textViewVM.outputs.textViewText)
                    .take(1)
                    .subscribe(onNext: { textViewText in
                        reportTextViewVM.inputs.textViewTextChange.onNext(textViewText)
                        UIView.animate(withDuration: Metrics.fadeDuration) {
                            additionalInfoView.alpha = 0
                        } completion: { _ in
                            additionalInfoView.removeFromSuperview()
                        }
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)

        // Additional information observable
        let additionalInformationObservable = reportTextViewVM.outputs.textViewTapped
            .flatMap { _ -> Observable<(String, String)> in
                return Observable.combineLatest(reportTextViewVM.outputs.placeholderText,
                                                reportTextViewVM.outputs.textViewText)
                .take(1)
            }
            .observe(on: MainScheduler.instance)
            .map { placeholderText, textViewText -> OWAdditionalInfoViewViewModel in
                return OWAdditionalInfoViewViewModel(viewableMode: viewModel.outputs.viewableMode,
                                                     placeholderText: placeholderText,
                                                     textViewText: textViewText,
                                                     isTextRequired: viewModel.outputs.selectedReason.map { $0.requiredAdditionalInfo },
                                                     submitInProgress: viewModel.outputs.submitInProgress)
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
                let additionalInfoViewVC = OWAdditionalInfoVC(additionalInfoViewViewModel: additionalInfoViewVM)
                router.push(additionalInfoViewVC, pushStyle: .regular, animated: true, popCompletion: nil)
            })
            .disposed(by: disposeBag)

        // Additional information cancel
        let additionalCancelObservable = additionalInformationObservable
            .flatMap { additionalInfoViewVM -> Observable<Void> in
                return additionalInfoViewVM.outputs.cancelAdditionalInfoTapped
            }

        // Additional information close
        let additionalCloseObservable = additionalInformationObservable
            .flatMap { additionalInfoViewVM -> Observable<Void> in
                return additionalInfoViewVM.outputs.closeReportReasonTapped
            }

        // Additional information text changed
        additionalInformationObservable
            .flatMap { additionalInfoViewVM -> Observable<String> in
                return additionalInfoViewVM.outputs.additionalInfoTextChanged
            }
            .bind(to: viewModel.inputs.textViewTextChange)
            .disposed(by: disposeBag)

        // Additional information submit
        additionalInformationObservable
            .flatMap { additionalInfoViewVM -> Observable<Void> in
                return additionalInfoViewVM.outputs.submitAdditionalInfoTapped
            }
            .bind(to: viewModel.inputs.submitReportReasonTap)
            .disposed(by: disposeBag)

        // Open cancel observable
        let cancelObservable = Observable.merge(viewModel.outputs.cancelReportReasonTapped,
                                                additionalCancelObservable)
        .map { _ -> OWReportReasonCancelViewViewModel in
            return OWReportReasonCancelViewViewModel()
        }
        .share()

        // Open cancel view - Flow
        cancelObservable
            .filter { _ in
                viewModel.outputs.viewableMode == .partOfFlow
            }
            .subscribe(onNext: { [weak self] reportReasonCancelViewVM in
                guard let self = self else { return }
                guard let router = self.router else { return }
                let reportReasonCancelVC = OWReportReasonCancelVC(reportReasonCancelViewViewModel: reportReasonCancelViewVM)
                reportReasonCancelVC.modalPresentationStyle = .fullScreen
                router.present(reportReasonCancelVC, animated: true, dismissCompletion: nil)
            })
            .disposed(by: disposeBag)

        cancelObservable
            .filter { _ in
                viewModel.outputs.viewableMode == .partOfFlow
            }
            .flatMap { reportReasonCancelViewVM -> Observable<Void> in
                return reportReasonCancelViewVM.outputs.closeReportReasonCancelTapped
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard let router = self.router else { return }
                router.navigationController?.visibleViewController?.dismiss(animated: true)
            })
            .disposed(by: self.disposeBag)

        let cancelReportCancelTapped = cancelObservable
            .flatMap { reportReasonCancelViewVM -> Observable<Void> in
                return reportReasonCancelViewVM.outputs.cancelReportReasonCancelTapped
            }

        // Close ReportReason observable
        let closeObservable = Observable.merge(viewModel.outputs.closeReportReasonTapped,
                                               additionalCloseObservable,
                                               cancelReportCancelTapped)
        .map { _ -> OWReportReasonCancelViewViewModel in
            return OWReportReasonCancelViewViewModel()
        }
        .share()

        // Close Report Reason - Flow
        closeObservable
            .filter { _ in
                viewModel.outputs.viewableMode == .partOfFlow
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard let router = self.router else { return }
                guard let controllerToPopTo = router.navigationController?.viewControllers.first(where: {
                    $0.isKind(of: OWReportReasonVC.self)
                }) else { return }
                let visableViewController = router.navigationController?.visibleViewController
                let isReportReasonVC = visableViewController?.isKind(of: OWReportReasonVC.self) ?? false

                if !isReportReasonVC {
                    visableViewController?.dismiss(animated: true)
                }

                router.pop(toViewController: controllerToPopTo, animated: false)
                router.pop(popStyle: .dismissStyle, animated: true)
            })
            .disposed(by: disposeBag)

        // Open Guidelines - Independent
        viewModel.outputs.learnMoreTapped
            .unwrap()
            .filter { _ in
                return viewModel.outputs.viewableMode == .independent
            }
            .subscribe(onNext: { [weak self] url in
                guard let self = self else { return }
                self.viewActionsService.append(viewAction: OWViewActionCallbackType.communityGuidelinesPressed(url: url))
            })
            .disposed(by: disposeBag)

        // Open Guidelines - Flow
        viewModel.outputs.learnMoreTapped
            .unwrap()
            .filter { _ in
                return viewModel.outputs.viewableMode == .partOfFlow
            }
            .flatMap { [weak self] url -> Observable<OWSafariTabCoordinatorResult> in
                guard let self = self else { return .empty() }
                guard let router = self.router else { return .empty() }
                let safariCoordinator = OWSafariTabCoordinator(router: router,
                                                               url: url,
                                                               actionsCallbacks: self.actionsCallbacks)
                return self.coordinate(to: safariCoordinator, deepLinkOptions: .none)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
