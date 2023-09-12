//
//  OWTableView.swift
//  SpotImCore
//
//  Created by Refael Sommer on 12/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift
import Foundation

class OWTableView: UITableView {
    fileprivate var height = BehaviorSubject<CGFloat>(value: 0)
    fileprivate lazy var heightChanged: Observable<CGFloat> = {
        return height
            .distinctUntilChanged()
            .asObservable()
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        height.onNext(self.frame.size.height)
    }
}

extension Reactive where Base: OWTableView {
    var height: Observable<CGFloat> {
        return base.heightChanged
    }
}
