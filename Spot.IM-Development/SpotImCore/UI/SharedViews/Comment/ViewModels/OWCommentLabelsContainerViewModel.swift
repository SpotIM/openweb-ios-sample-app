//
//  OWCommentLabelsContainerViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 10/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

protocol OWCommentLabelsContainerViewModelingInputs {
    // TODO: click ?
}

protocol OWCommentLabelsContainerViewModelingOutputs {
    var commentLabelsViewModels: Observable<[OWCommentLabelViewModeling]> { get }
}

protocol OWCommentLabelsContainerViewModeling {
    var inputs: OWCommentLabelsContainerViewModelingInputs { get }
    var outputs: OWCommentLabelsContainerViewModelingOutputs { get }
}

class OWCommentLabelsContainerViewModel: OWCommentLabelsContainerViewModeling,
                                         OWCommentLabelsContainerViewModelingInputs,
                                         OWCommentLabelsContainerViewModelingOutputs {

    var inputs: OWCommentLabelsContainerViewModelingInputs { return self }
    var outputs: OWCommentLabelsContainerViewModelingOutputs { return self }

    fileprivate let _comment = BehaviorSubject<SPComment?>(value: nil)

    fileprivate let _maxVisibleCommentLabels = 3 // TODO: do we want to keep it that way?
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let disposeBag = DisposeBag()

    init(comment: SPComment, servicerProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicerProvider
        _comment.onNext(comment)
    }
    init(servicerProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicerProvider
    }

    fileprivate var _commentLabelsSectionsConfig: Observable<CommentLabelsSectionsConfig> {
        self.servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> CommentLabelsSectionsConfig? in
                guard let sharedConfig = config.shared,
                      sharedConfig.enableCommentLabels == true
                else { return nil }

                return sharedConfig.commentLabels
            }
            .unwrap()
    }

    fileprivate var _commentLabelsSettings: Observable<[OWCommentLabelSettings]> {
        Observable.combineLatest(_comment, _commentLabelsSectionsConfig) { [weak self] comment, commentLabelsSectionsConfig in
            guard let self = self,
                  let comment = comment
            else { return nil }
            return self.getCommentLabels(comment: comment, commentLabelsSectionsConfig: commentLabelsSectionsConfig)
        }.unwrap()
    }

    var commentLabelsViewModels: Observable<[OWCommentLabelViewModeling]> {
        _commentLabelsSettings
            .map { setttings -> [OWCommentLabelViewModel] in
                return setttings.map { commentLabelSetting in
                    OWCommentLabelViewModel(commentLabelSettings: commentLabelSetting)
                }
            }
            .asObservable()
    }

    func setupObservers() {
        commentLabelsViewModels
            .flatMapLatest { viewModels -> Observable<OWCommentLabelViewModeling> in
                let clickOutputObservers: [Observable<OWCommentLabelViewModeling>] = viewModels
                    .map { vm in
                        return vm.outputs.labelClickedOutput.map { vm }
                    }
                return Observable.merge(clickOutputObservers)
            }
            .subscribe(onNext: { _ in
                // TODO: Handle click on label if needed
            })
            .disposed(by: disposeBag)
    }
}

fileprivate extension OWCommentLabelsContainerViewModel {
    func getCommentLabels(comment: SPComment, commentLabelsSectionsConfig: CommentLabelsSectionsConfig) -> [OWCommentLabelSettings]? {
        guard let commentLabelsConfig = getCommentLabelsFromConfig(comment: comment, commentLabelsSectionsConfig: commentLabelsSectionsConfig) else { return nil }

        let labelsSettings: [OWCommentLabelSettings] = commentLabelsConfig.map { commentLabelConfig in
            guard let color = UIColor.color(rgb: commentLabelConfig.color),
                  let iconUrl = commentLabelConfig.getIconUrl() else { return nil }

            return OWCommentLabelSettings(
                id: commentLabelConfig.id,
                text: commentLabelConfig.text,
                iconUrl: iconUrl,
                color: color)
        }.unwrap()

        return Array(labelsSettings.prefix(_maxVisibleCommentLabels))
    }

    func getCommentLabelsFromConfig(comment: SPComment, commentLabelsSectionsConfig: CommentLabelsSectionsConfig) -> [SPLabelConfiguration]? {
        // cross given commentLabels to appConfig labels
        if let commentLabels = comment.additionalData?.labels,
           let labelIds = commentLabels.ids, labelIds.count > 0,
           let section = commentLabels.section,
           let sectionLabels = commentLabelsSectionsConfig[section] {
            var selectedCommentLabelsConfiguration: [SPLabelConfiguration] = []
            for labelId in labelIds {
                if let selectedCommentLabelConfiguration = sectionLabels.getLabelById(labelId: labelId) {
                    selectedCommentLabelsConfiguration.append(selectedCommentLabelConfiguration)
                }
            }

            return selectedCommentLabelsConfiguration
        }

        return nil
    }
}
