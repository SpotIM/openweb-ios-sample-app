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

    let id: OWCommentId
    var repliesIds: [OWCommentId]
    var totalRepliesCount: Int
    var repliesOffset: Int
    var spacing: CGFloat
    fileprivate(set) var repliesPresentation: [OWCommentPresentationData]

    init(
        id: OWCommentId,
        repliesIds: [OWCommentId],
        totalRepliesCount: Int,
        repliesOffset: Int,
        spacing: CGFloat,
        repliesPresentation: [OWCommentPresentationData]) {

        self.id = id
        self.repliesIds = repliesIds
        self.totalRepliesCount = totalRepliesCount
        self.repliesOffset = repliesOffset
        self.spacing = spacing
        self.repliesPresentation = repliesPresentation
        self.updateRepliesPresentationObservers()
    }

    init(id: OWCommentId) {
        self.id = id
        self.repliesIds = []
        self.totalRepliesCount = 0
        self.repliesOffset = 0
        self.spacing = 0
        self.repliesPresentation = []
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

    func setTotalRepliesCount(_ count: Int) {
        self.totalRepliesCount = count
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
