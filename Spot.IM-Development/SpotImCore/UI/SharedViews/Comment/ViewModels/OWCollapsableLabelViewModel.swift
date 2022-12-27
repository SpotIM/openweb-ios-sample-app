//
//  OWCollapsableLabelViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 27/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWCollapsableLabelViewModelingInputs {
    var width: PublishSubject<CGFloat> { get }
}

protocol OWCollapsableLabelViewModelingOutputs {
//    var text: Observable<String?> { get }
//    var attributedString: Observable<NSMutableAttributedString?> { get }
//    var gifUrl: Observable<String?> { get }
//    var imageUrl: Observable<URL?> { get }
//    var mediaSize: Observable<CGSize?> { get }
    var collapsedNumberOfLines: Observable<Int> { get }
}

protocol OWCollapsableLabelViewModeling {
    var inputs: OWCollapsableLabelViewModelingInputs { get }
    var outputs: OWCollapsableLabelViewModelingOutputs { get }
}

class OWCollapsableLabelViewModel: OWCollapsableLabelViewModeling,
                                   OWCollapsableLabelViewModelingInputs,
                                   OWCollapsableLabelViewModelingOutputs {
    
    var inputs: OWCollapsableLabelViewModelingInputs { return self }
    var outputs: OWCollapsableLabelViewModelingOutputs { return self }
    
    fileprivate let _lineLimit = BehaviorSubject<Int>(value: 0)
    
    var collapsedNumberOfLines: Observable<Int> {
        _lineLimit
            .map {$0}
    }
    
    var width = PublishSubject<CGFloat>()
    
    init(text: NSMutableAttributedString, lineLimit: Int) {
        _lineLimit.onNext(lineLimit)
    }
}
    
