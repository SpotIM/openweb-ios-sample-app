//
//  OWBlockerService.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 14/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWBlockerServicing {
    func add(blocker: OWBlockerActionProtocol)
    func removeBlocker(perType blockerType: OWBlockerActionType)
    func waitForNonBlocker(for blockersTypes: [OWBlockerActionType]) -> Observable<Void>

    // Utility function to support multiple spotIds for the SampleApp
    func invalidateAllBlockers()
}

extension OWBlockerServicing {
    func waitForNonBlocker() -> Observable<Void> {
        return self.waitForNonBlocker(for: OWBlockerActionType.allCases)
    }
}

class OWBlockerService: OWBlockerServicing {
    private let _blockersMapper = BehaviorSubject<[OWBlockerActionType: OWBlockerActionProtocol]>(value: [:])
    private var blockersMapper: Observable<[OWBlockerActionType: OWBlockerActionProtocol]> {
        return _blockersMapper
            .asObservable()
    }

    func add(blocker: OWBlockerActionProtocol) {
        _ = blockersMapper
            .take(1)
            .subscribe(onNext: { [weak self] mapper in
                var newMapper = mapper
                newMapper[blocker.blockerType] = blocker
                self?._blockersMapper.onNext(newMapper)
            })
    }

    func removeBlocker(perType blockerType: OWBlockerActionType) {
        _ = blockersMapper
            .take(1)
            .subscribe(onNext: { [weak self] mapper in
                var newMapper = mapper
                newMapper.removeValue(forKey: blockerType)
                self?._blockersMapper.onNext(newMapper)
            })
    }

    func waitForNonBlocker(for blockersTypes: [OWBlockerActionType]) -> Observable<Void> {
        return blockersMapper
            .map { mapper -> [OWBlockerActionType: OWBlockerActionProtocol] in
                guard blockersTypes != OWBlockerActionType.allCases else { return mapper }
                // Filtering only the types which we are interesting in
                let newMapper: [OWBlockerActionType: OWBlockerActionProtocol]
                newMapper = mapper.filter { blockersTypes.contains($0.key) }
                return newMapper
            }
            .filter { mapper in
                // Continue only if there arent any blockers
                return mapper.isEmpty
            }
            .voidify()
            .take(1)
    }

    func invalidateAllBlockers() {
        _blockersMapper.onNext([:])
    }
}
