//
//  OWCommentLabelViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 15/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

typealias CommentLabelsSectionsConfig = Dictionary<String, SPCommentLabelsSectionConfiguration>

protocol OWCommentLabelViewModelingInputs {
    // TODO: click ?
}

protocol OWCommentLabelViewModelingOutputs {
    var commentLabelSettings: Observable<OWCommentLabelSettings?> { get }
    var state: Observable<LabelState> { get }
}

protocol OWCommentLabelViewModeling {
    var inputs: OWCommentLabelViewModelingInputs { get }
    var outputs: OWCommentLabelViewModelingOutputs { get }
}

class OWCommentLabelViewModel: OWCommentLabelViewModeling,
                               OWCommentLabelViewModelingInputs,
                               OWCommentLabelViewModelingOutputs {

    var inputs: OWCommentLabelViewModelingInputs { return self }
    var outputs: OWCommentLabelViewModelingOutputs { return self }
        
    fileprivate let _comment = BehaviorSubject<SPComment?>(value: nil)
    
    init(comment: SPComment) {
        _comment.onNext(comment)
    }
    init() {}
    
    fileprivate var _commentLabelsSectionsConfig: Observable<CommentLabelsSectionsConfig> {
        OWSharedServicesProvider.shared.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> CommentLabelsSectionsConfig? in
                guard let sharedConfig = config.shared,
                      sharedConfig.enableCommentLabels == true
                else { return nil }
                
                return sharedConfig.commentLabels
            }
            .unwrap()
    }
    
    var commentLabelSettings: Observable<OWCommentLabelSettings?> {
        Observable.combineLatest(_comment, _commentLabelsSectionsConfig) { [weak self] comment, commentLabelsSectionsConfig in
            guard let self = self,
                  let comment = comment
            else { return nil }
            return self.getCommentLabel(comment: comment, commentLabelsSectionsConfig: commentLabelsSectionsConfig)
        }
    }
    
    var state: Observable<LabelState> {
        _comment
            // TODO: for now only implement read only mode for displaying label. When create comment is developed should add selected & not selected by clicks
            .map { _ in return .readOnly }
            .asObservable()
    }
}

fileprivate extension OWCommentLabelViewModel {
    func getCommentLabel(comment: SPComment, commentLabelsSectionsConfig: CommentLabelsSectionsConfig) -> OWCommentLabelSettings? {
        guard let commentLabelConfig = getCommentLabelFromConfig(comment: comment, commentLabelsSectionsConfig: commentLabelsSectionsConfig),
              let color = UIColor.color(rgb: commentLabelConfig.color),
              let iconUrl = commentLabelConfig.getIconUrl()
        else { return nil }
        
        return OWCommentLabelSettings(
            id: commentLabelConfig.id,
            text: commentLabelConfig.text,
            iconUrl: iconUrl,
            color: color)

    }
    
    func getCommentLabelFromConfig(comment: SPComment, commentLabelsSectionsConfig: CommentLabelsSectionsConfig) -> SPLabelConfiguration? {
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
            // For now - we are only displaying one selected comment label
            return selectedCommentLabelsConfiguration[0]
        }
        
        return nil
    }
}
