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
    func updateEditedCommentLocally(_ comment: OWComment)
    func update(comment: OWComment)
}

protocol OWCommentLabelsContainerViewModelingOutputs {
    var commentLabelsTitle: Observable<String?> { get }
    var commentLabelsViewModels: Observable<[OWCommentLabelViewModeling]> { get }
    var selectedLabelIds: Observable<[String]> { get }
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

    fileprivate let _comment = BehaviorSubject<OWComment?>(value: nil)

    fileprivate let _maxVisibleCommentLabels = 3 // TODO: do we want to keep it that way?

    fileprivate let section: String

    fileprivate var _selectedLabelIds = BehaviorSubject<Set<String>>(value: [])
    var selectedLabelIds: Observable<[String]> {
        _selectedLabelIds
            .map { Array($0) }
            .asObservable()
    }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let disposeBag = DisposeBag()

    init(comment: OWComment? = nil, section: String, servicerProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicerProvider
        self.section = section
        if let comment = comment {
            _comment.onNext(comment)
        }
        self.setupObservers()
    }

    func update(comment: OWComment) {
        _comment.onNext(comment)
    }

    func updateEditedCommentLocally(_ comment: OWComment) {
        _comment.onNext(comment)
    }

    init(servicerProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicerProvider
        self.section = ""
    }

    fileprivate lazy var _commentLabelsSection: Observable<SPCommentLabelsSectionConfiguration> = {
        self.servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> CommentLabelsSectionsConfig? in
                guard let sharedConfig = config.shared,
                      sharedConfig.enableCommentLabels == true
                else { return nil }

                return sharedConfig.commentLabels
            }
            .unwrap()
            .map { [weak self] commentLabelsSectionsConfig in
                guard let self = self else { return nil }
                return commentLabelsSectionsConfig[self.section]
            }
            .unwrap()
    }()

    fileprivate lazy var _commentLabelsSettings: Observable<[OWCommentLabelSettings]> = {
        Observable.combineLatest(_comment, _commentLabelsSection) { [weak self] comment, commentLabelsSection in
            guard let self = self else { return nil }
            return self.getCommentLabels(comment: comment, commentLabelsSection: commentLabelsSection)
        }.unwrap()
    }()

    lazy var commentLabelsViewModels: Observable<[OWCommentLabelViewModeling]> = {
        Observable.combineLatest(_comment, _commentLabelsSettings, _selectedLabelIds)
            .map { comment, setttings, selectedIds -> [OWCommentLabelViewModel] in
                return setttings.map { commentLabelSetting in
                    let stateForSelectedId: OWLabelState = selectedIds.contains(commentLabelSetting.id) ? .selected : .notSelected
                    return OWCommentLabelViewModel(commentLabelSettings: commentLabelSetting, state: comment != nil ? .readOnly : stateForSelectedId)
                }
            }
            .asObservable()
            .share(replay: 1)
    }()

    fileprivate var _commentLabelsTitle: Observable<String?> {
        Observable.combineLatest(_comment, _commentLabelsSection) { comment, commentLabelsSection in
            guard comment == nil else { return nil }
            return commentLabelsSection.guidelineText
        }
    }

    var commentLabelsTitle: Observable<String?> {
        _commentLabelsTitle
            .asObservable()
    }
}

fileprivate extension OWCommentLabelsContainerViewModel {
    func setupObservers() {
        commentLabelsViewModels
            .flatMapLatest { viewModels -> Observable<OWCommentLabelViewModeling> in
                let clickOutputObservers: [Observable<OWCommentLabelViewModeling>] = viewModels
                    .map { vm in
                        return vm.outputs.labelClickedOutput
                            .map { vm }
                    }
                return Observable.merge(clickOutputObservers)
            }
            .flatMapLatest { vm -> Observable<(OWLabelState, OWCommentLabelSettings)> in
                return Observable.combineLatest(vm.outputs.state, vm.outputs.commentLabelSettings)
            }
            .withLatestFrom(_commentLabelsSection) { ($0.0, $0.1, $1) }
            .withLatestFrom(_selectedLabelIds) { ($0.0, $0.1, $0.2, $1) }
            .subscribe(onNext: { [weak self] (state, settings, sectionSettings, selectedLabelIds) in
                guard let self = self else { return }
                switch state {
                case .notSelected:
                    var selectedLabelIdsCopy = selectedLabelIds
                    switch (sectionSettings.maxSelected, selectedLabelIdsCopy.count) {
                    case (1, 1):
                        // replace existing selected label
                        selectedLabelIdsCopy.removeAll()
                        selectedLabelIdsCopy.insert(settings.id)
                    case (_, _) where sectionSettings.maxSelected == selectedLabelIdsCopy.count:
                        // max exceeded
                        break
                    default:
                        selectedLabelIdsCopy.insert(settings.id)
                    }
                    self._selectedLabelIds.onNext(selectedLabelIdsCopy)
                case .selected:
                    // remove selection
                    self._selectedLabelIds.onNext(selectedLabelIds.filter { $0 != settings.id })
                case .readOnly:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}

fileprivate extension OWCommentLabelsContainerViewModel {
    func getCommentLabels(comment: OWComment?, commentLabelsSection: SPCommentLabelsSectionConfiguration) -> [OWCommentLabelSettings] {
        var commentLabelsConfig: [SPLabelConfiguration]
        if let comment = comment {
            commentLabelsConfig = getCommentLabelsOfComment(comment: comment, commentLabelsSection: commentLabelsSection)
        } else {
            commentLabelsConfig = commentLabelsSection.labels
        }

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

    func getCommentLabelsOfComment(comment: OWComment, commentLabelsSection: SPCommentLabelsSectionConfiguration) -> [SPLabelConfiguration] {
        var selectedCommentLabelsConfiguration: [SPLabelConfiguration] = []

        if let commentLabels = comment.additionalData?.labels,
           let labelIds = commentLabels.ids, labelIds.count > 0 {
            for labelId in labelIds {
                if let selectedCommentLabelConfiguration = commentLabelsSection.getLabelById(labelId: labelId) {
                    selectedCommentLabelsConfiguration.append(selectedCommentLabelConfiguration)
                }
            }
        }

        return selectedCommentLabelsConfiguration
    }
}
