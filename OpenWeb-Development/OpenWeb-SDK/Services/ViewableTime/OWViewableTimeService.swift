//
//  OWViewableTimeService.swift
//  OpenWeb-Development
//
//  Created by Yonat Sharon on 11/11/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import RxSwift

protocol OWAnalyticEventSender {
    func sendEvent(for eventType: OWAnalyticEventType)
}

/// Add conformance for view models that should be tracked for viewability, and implement `sendEvent(for:)`.
protocol OWViewableTimeConsumer: AnyObject, Equatable, OWAnalyticEventSender {}

/// Add conformance for `UIView`s that should be tracked for viewability. Then
/// call `trackViewability(viewModel:)` in `setupObservers()` or on cell reuse (no need to implement it),
/// and call `endTrackingViewability()` in `deinit` or on ending cell reuse (no need to implement it).
protocol OWViewabilityTrackable {
    func trackViewability(viewModel: any OWViewableTimeConsumer)
    func endTrackingViewability(viewModel: any OWViewableTimeConsumer)
}

protocol OWViewableTimeServicingInputs {
    func track<Consumer: OWViewableTimeConsumer>(consumer: Consumer, view: UIView)
    func endTracking<Consumer: OWViewableTimeConsumer>(consumer: Consumer)
}

protocol OWViewableTimeServicingOutputs {
    /// For debugging purposes. Emits when the tracked view becomes viewable.
    func viewabilityDidStart<Consumer: OWViewableTimeConsumer>(consumer: Consumer) -> Observable<Void>

    /// Emits the duration that the tracked view was viewable, when it disappears or scrolls off the screen.
    func viewabilityDidEnd<Consumer: OWViewableTimeConsumer>(consumer: Consumer) -> Observable<TimeInterval>
}

protocol OWViewableTimeServicing {
    var inputs: OWViewableTimeServicingInputs { get }
    var outputs: OWViewableTimeServicingOutputs { get }
}

class OWViewableTimeService: OWViewableTimeServicing, OWViewableTimeServicingInputs, OWViewableTimeServicingOutputs {
    var inputs: OWViewableTimeServicingInputs { return self }
    var outputs: OWViewableTimeServicingOutputs { return self }

    /// maps weak references of `OWViewableTimeConsumer`s to trackers
    private var trackers = [AnyHashable: ViewableTimeTracker]()
    private let disposeBag = DisposeBag()

    func track<Consumer: OWViewableTimeConsumer>(consumer: Consumer, view: UIView) {
        cleanup()
        let tracker = ViewableTimeTracker()
        tracker.trackedView = view
        trackers[OWWeakEncapsulation(value: consumer)] = tracker
        tracker.viewabilityDidEnd
            .subscribe(onNext: { [weak consumer] duration in
                consumer?.sendEvent(for: .viewableTime(timeInS: duration))
            })
            .disposed(by: disposeBag)
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
}

private extension OWViewableTimeService {
    func cleanup() {
        trackers = trackers.filter { $0.value.trackedView != nil }
        if trackers.isEmpty {
            disposeBag = DisposeBag()
        }
    }
}

extension OWViewabilityTrackable where Self: UIView {
    func trackViewability(viewModel: any OWViewableTimeConsumer) {
        OWSharedServicesProvider.shared.viewableTimeService().inputs
            .track(consumer: viewModel, view: self)
    }

    func endTrackingViewability(viewModel: any OWViewableTimeConsumer) {
        OWSharedServicesProvider.shared.viewableTimeService().inputs
            .endTracking(consumer: viewModel)
    }
}

extension OWViewableTimeConsumer {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs === rhs
    }
}
