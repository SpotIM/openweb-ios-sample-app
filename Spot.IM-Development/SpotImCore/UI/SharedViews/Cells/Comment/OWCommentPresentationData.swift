//
//  OWCommentPresentationData.swift
//  SpotImCore
//
//  Created by Alon Shprung on 21/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWCommentPresentationData: OWUpdaterProtocol {
    fileprivate var disposedBag = DisposeBag()

    var update: PublishSubject<Void> = PublishSubject()

    let id: String
    var repliesIds: [String]
    let totalRepliesCount: Int
    var repliesOffset: Int
    fileprivate(set) var repliesPresentation: [OWCommentPresentationData]

    init(
        id: String,
        repliesIds: [String],
        totalRepliesCount: Int,
        repliesOffset: Int,
        repliesPresentation: [OWCommentPresentationData]) {

        self.id = id
        self.repliesIds = repliesIds
        self.totalRepliesCount = totalRepliesCount
        self.repliesOffset = repliesOffset
        self.repliesPresentation = repliesPresentation
        self.updateRepliesPresentationObservers()
    }
}

extension OWCommentPresentationData: Equatable {
    static func == (lhs: OWCommentPresentationData, rhs: OWCommentPresentationData) -> Bool {
        return lhs.id == rhs.id &&
        lhs.repliesIds == rhs.repliesIds &&
        lhs.repliesPresentation == rhs.repliesPresentation &&
        lhs.repliesOffset == rhs.repliesOffset
    }
}

extension OWCommentPresentationData {
    func setRepliesPresentation(_ repliesPresentation: [OWCommentPresentationData]) {
        self.repliesPresentation = repliesPresentation
        self.updateRepliesPresentationObservers()
    }
}

fileprivate extension OWCommentPresentationData {
    func updateRepliesPresentationObservers() {
        disposedBag = DisposeBag()

        let repliesUpdateObservers = repliesPresentation.map { $0.update.asObservable() }

        Observable.merge(repliesUpdateObservers)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.update.onNext()
            })
            .disposed(by: disposedBag)
    }
}
