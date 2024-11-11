//
//  OWViewableTimeService.swift
//  OpenWeb-Development
//
//  Created by Yonat Sharon on 11/11/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import RxSwift

protocol OWViewableTimeConsumer: AnyObject, Equatable {}

protocol OWViewableTimeServicingInputs {
    func track<Consumer: OWViewableTimeConsumer>(consumer: Consumer, view: UIView)
    func endTracking<Consumer: OWViewableTimeConsumer>(consumer: Consumer)
}

protocol OWViewableTimeServicingOutputs {
    func viewabilityDidStart<Consumer: OWViewableTimeConsumer>(consumer: Consumer) -> Observable<Void> // (for debuggung) consumer is viewModel
    func viewabilityDidEnd<Consumer: OWViewableTimeConsumer>(consumer: Consumer) -> Observable<TimeInterval> // consumer is viewModel
}

protocol OWViewableTimeServicing {
    var inputs: OWViewableTimeServicingInputs { get }
    var outputs: OWViewableTimeServicingOutputs { get }
}

class OWViewableTimeService: OWViewableTimeServicing, OWViewableTimeServicingInputs, OWViewableTimeServicingOutputs {
    var inputs: OWViewableTimeServicingInputs { return self }
    var outputs: OWViewableTimeServicingOutputs { return self }

    func track<Consumer: OWViewableTimeConsumer>(consumer: Consumer, view: UIView) {
        cleanup()
        let tracker = ViewableTimeTracker()
        tracker.trackedView = view
        trackers[OWWeakEncapsulation(value: consumer)] = tracker
    }

    func endTracking<Consumer: OWViewableTimeConsumer>(consumer: Consumer) {
        trackers.removeValue(forKey: OWWeakEncapsulation(value: consumer))
        cleanup()
    }

    func viewabilityDidStart<Consumer: OWViewableTimeConsumer>(consumer: Consumer) -> Observable<Void> {
        if let tracker = trackers[OWWeakEncapsulation(value: consumer)] {
            return tracker.outputs.viewabilityDidStart
        } else {
            OWSharedServicesProvider.shared.logger().log(level: .medium, "viewabilityDidStart: missing tracker for consumer \(String(describing: type(of: consumer)))")
            return .empty()
        }
    }

    func viewabilityDidEnd<Consumer: OWViewableTimeConsumer>(consumer: Consumer) -> Observable<TimeInterval> {
        if let tracker = trackers[OWWeakEncapsulation(value: consumer)] {
            return tracker.outputs.viewabilityDidEnd
        } else {
            OWSharedServicesProvider.shared.logger().log(level: .medium, "viewabilityDidEnd: missing tracker for consumer \(String(describing: type(of: consumer)))")
            return .empty()
        }
    }

    /// maps weak references to `ViewableTimeConsumer`s to trackers
    private var trackers = [AnyHashable: ViewableTimeTracker]()
}

private extension OWViewableTimeService {
    func cleanup() {
        trackers = trackers.filter { $0.value.trackedView != nil }
    }
}
