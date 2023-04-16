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
    var repliesPresentation: [OWCommentPresentationData] {
        didSet(newRepliesPresentation) {
            disposedBag = DisposeBag()

            let repliesUpdateObservers = newRepliesPresentation.map { $0.update.asObservable() }

            Observable.merge(repliesUpdateObservers)
                .asObservable()
                .subscribe { [weak self] _ in
                    guard let self = self else { return }
                    self.update.onNext()
                }
                .disposed(by: disposedBag)
        }
    }

    init(
        id: String,
        repliesIds: [String] = [],
        totalRepliesCount: Int,
        repliesOffset: Int,
        repliesPresentation: [OWCommentPresentationData] = []) {

        self.id = id
        self.repliesIds = repliesIds
        self.totalRepliesCount = totalRepliesCount
        self.repliesOffset = repliesOffset
        self.repliesPresentation = repliesPresentation
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
