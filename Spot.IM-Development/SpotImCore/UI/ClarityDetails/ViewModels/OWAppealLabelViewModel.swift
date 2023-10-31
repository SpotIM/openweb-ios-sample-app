//
//  OWAppealLabelViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 31/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol OWAppealLabelViewModelingInputs {
}

protocol OWAppealLabelViewModelingOutputs {
    var viewType: Observable<OWAppealLabelViewType> { get }
    var backgroundColor: Observable<UIColor> { get }
    var borderColor: Observable<UIColor> { get }
}

protocol OWAppealLabelViewModeling {
    var inputs: OWAppealLabelViewModelingInputs { get }
    var outputs: OWAppealLabelViewModelingOutputs { get }
}

class OWAppealLabelViewModel: OWAppealLabelViewModeling,
                              OWAppealLabelViewModelingInputs,
                              OWAppealLabelViewModelingOutputs {

    var inputs: OWAppealLabelViewModelingInputs { return self }
    var outputs: OWAppealLabelViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding

    fileprivate var _viewType = BehaviorSubject<OWAppealLabelViewType>(value: .skeleton)
    var viewType: Observable<OWAppealLabelViewType> {
        _viewType
            .asObservable()
    }

    var borderColor: Observable<UIColor> {
        Observable.combineLatest(
            viewType,
            servicesProvider.themeStyleService().style
        ) { type, theme in
            switch type {
            case .skeleton, .appealRejected, .default, .unavailable:
                return OWColorPalette.shared.color(type: .separatorColor3, themeStyle: theme)
            case .error:
                return OWColorPalette.shared.color(type: .errorColor, themeStyle: theme)
            }
        }
    }

    var backgroundColor: Observable<UIColor> {
        Observable.combineLatest(
            viewType,
            servicesProvider.themeStyleService().style
        ) { type, theme in
            switch type {
            case .skeleton, .appealRejected, .default, .unavailable:
                return OWDesignColors.D1
            case .error:
                return .clear
            }
        }
    }


    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }
}

enum OWAppealLabelViewType {
    case skeleton
    case appealRejected
    case `default`
    case error
    case unavailable
}
