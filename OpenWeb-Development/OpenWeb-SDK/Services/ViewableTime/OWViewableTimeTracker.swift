//
//  OWViewableTimeTracker.swift
//  OpenWebSDK
//
//  Created by Yonat Sharon on 10/11/2024.
//

import UIKit
import RxSwift
import RxCocoa

protocol OWViewableTimeTrackingInputs {
    var trackedView: UIView? { get set }
}

protocol OWViewableTimeTrackingOutputs {
    var viewabilityDidStart: Observable<Void> { get }
    var viewabilityDidEnd: Observable<TimeInterval> { get }
}

protocol OWViewableTimeTracking {
    var inputs: OWViewableTimeTrackingInputs { get }
    var outputs: OWViewableTimeTrackingOutputs { get }
}

class OWViewableTimeTracker: OWViewableTimeTracking, OWViewableTimeTrackingInputs, OWViewableTimeTrackingOutputs {
    var inputs: OWViewableTimeTrackingInputs { return self }
    var outputs: OWViewableTimeTrackingOutputs { return self }

    private enum Metrics {
        /// Minimum height and width that needs to be visible for a view to be considered viewable
        static let minimumViewableLength: CGFloat = 1
    }

    weak var trackedView: UIView? {
        didSet {
            // perform async to allow collection view cells to be properly added to the view and window
            DispatchQueue.main.async { [weak self] in
                self?.track()
            }
        }
    }

    private let _viewabilityDidStart = PublishSubject<Void>()
    var viewabilityDidStart: Observable<Void> {
        return _viewabilityDidStart
            .asObservable()
    }

    private let _viewabilityDidEnd = PublishSubject<TimeInterval>()
    var viewabilityDidEnd: Observable<TimeInterval> {
        return _viewabilityDidEnd
            .asObservable()
    }

    init() {
        setupObservers()
    }

    deinit {
        if isViewable {
            endViewability()
        }
    }

    private let disposeBag = DisposeBag()
    private var viewHierarchyDisposeBag = DisposeBag()
    private var viewabilityStartTime: DispatchTime?
}

private extension OWViewableTimeTracker {
    var isViewable: Bool {
        get { viewabilityStartTime != nil }
        set {
            guard newValue != isViewable else { return }
            if newValue {
                viewabilityStartTime = .now()
                _viewabilityDidStart.onNext(())
            } else {
                endViewability()
            }
        }
    }

    func track() {
        viewabilityStartTime = nil
        updateViewHierarchy()
    }

    func endViewability() {
        guard let viewabilityStartTime else { return }
        let duration = viewabilityStartTime.timeInterval(to: .now())
        self.viewabilityStartTime = nil
        _viewabilityDidEnd.onNext(duration)
    }

    func setupObservers() {
        UIApplication.rx.didBecomeActive
            .subscribe(onNext: { [weak self] in
                self?.updateViewability()
            })
            .disposed(by: disposeBag)
        UIApplication.rx.didEnterBackground
            .subscribe(onNext: { [weak self] in
                self?.isViewable = false
            })
            .disposed(by: disposeBag)
    }

    func setupViewHierarchyObservers() {
        guard let trackedView else { return }

        // VC appear/disappear
        if let vc = trackedView.parentViewController {
            vc.rx.viewDidAppear
                .subscribe(onNext: { [weak self] in
                    self?.updateViewability()
                })
                .disposed(by: viewHierarchyDisposeBag)

            vc.rx.viewWillDisappear
                .subscribe(onNext: { [weak self] in
                    self?.isViewable = false
                })
                .disposed(by: viewHierarchyDisposeBag)
        }

        let superviews = trackedView.superviews

        // superview hierarchy changes - must come before other rx property changes, otherwise we get a KVO conflict error
        let hierarchyEvents = superviews.map { $0.rx.didMoveToSuperview.voidify() }
        Observable.merge(hierarchyEvents)
            .debounce(.milliseconds(0), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.updateViewHierarchy()
            })
            .disposed(by: viewHierarchyDisposeBag)

        // superview scrolling
        let containingScrollViews = superviews.compactMap { $0 as? UIScrollView }
        if !containingScrollViews.isEmpty {
            let scrollEvents = containingScrollViews.map { $0.rx.contentOffset.voidify() }
            Observable.merge(scrollEvents)
                .subscribe(onNext: { [weak self] in
                    self?.updateViewability()
                })
                .disposed(by: viewHierarchyDisposeBag)
        }

        // visibility changes
        let visibilityEvents = superviews.map { $0.rx.didChangeVisibility }
        Observable.merge(visibilityEvents)
            .debounce(.milliseconds(0), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.updateViewability()
            })
            .disposed(by: viewHierarchyDisposeBag)
    }

    func updateViewability() {
        isViewable = trackedView?.isViewable(minimumLength: Metrics.minimumViewableLength) ?? false
    }

    func updateViewHierarchy() {
        viewHierarchyDisposeBag = DisposeBag()
        updateViewability()
        setupViewHierarchyObservers()
    }
}

private extension UIView {
    var isVisible: Bool {
        return !isHidden
            && alpha > 0.1
            && nil != (window ?? (self as? UIWindow))
            && UIApplication.shared.applicationState != .background
    }

    /// Check if the view is exposed with at least `minimumLength` height and width
    func isViewable(minimumLength: CGFloat = 1) -> Bool {
        guard isVisible else { return false }

        let superviews = self.superviews
        for view in superviews {
            if !view.isVisible {
                return false
            }
            if view.clipsToBounds && !isPortionVisible(in: view, greaterThan: minimumLength) {
                return false
            }
        }

        return isExposedToTouches()
    }

    func isPortionVisible(in view: UIView, greaterThan length: CGFloat) -> Bool {
        let visiblePortion = intersection(with: view)
        return visiblePortion.width > length && visiblePortion.height > length
    }

    func intersection(with view: UIView) -> CGRect {
        let frameInViewCoordinates = convert(bounds, to: view)
        return frameInViewCoordinates.intersection(view.bounds)
    }

    /// Check if the view is exposed to touches (i.e. not covered by bars)
    /// - Returns: `true` if any of the view's `exposureCheckPoints` is exposed,
    ///  or if it doesn't accept touches (`isUserInteractionEnabled` is `false`).
    func isExposedToTouches() -> Bool {
        guard let window, isUserInteractionEnabled else { return true }
        let visiblePortion = intersection(with: window)
        for checkPoint in visiblePortion.exposureCheckPoints {
            guard let view = window.hitTest(checkPoint, with: nil) else { continue }
            if view.isDescendant(of: self) { return true }
        }
        return false
    }
}

private extension CGRect {
    var exposureCheckPoints: [CGPoint] {
        return [
            origin,
            CGPoint(x: maxX, y: minY),
            CGPoint(x: maxX, y: maxY),
            CGPoint(x: minX, y: maxY),
            CGPoint(x: midX, y: midY),
            CGPoint(x: midX, y: minY),
            CGPoint(x: midX, y: maxY),
            CGPoint(x: minX, y: midY),
            CGPoint(x: maxX, y: midY)
        ]
    }
}
