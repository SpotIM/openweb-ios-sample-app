//
//  OWSkeletonShimmeringService.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

protocol OWSkeletonShimmeringServicing {
    func addSkeleton(to view: UIView)
    func removeSkeleton(from view: UIView)
    func removeAllSkeletons()
}

class OWSkeletonShimmeringService: OWSkeletonShimmeringServicing {
    fileprivate let config: OWSkeletonShimmeringConfiguration
    fileprivate let scheduler: SchedulerType
    fileprivate var weakViews: [OWWeakEncapsulation<UIView>] = []
    fileprivate var disposeBag: DisposeBag!
    fileprivate let isServiceRunning = BehaviorSubject<Bool>(value: false)
    
    init(config: OWSkeletonShimmeringConfiguration,
         scheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: "OpenWebSDKSkeletonShimmeringServiceQueue")) {
        self.config = config
        self.scheduler = scheduler
    }
    
    func addSkeleton(to view: UIView) {
        guard let skeletonLayer = view.getSkeletonLayer(),
              let shimmeringLayer = view.getShimmeringLayer() else { return }
        
        skeletonLayer.backgroundColor = config.backgroundColor.cgColor
        shimmeringLayer.colors = [config.backgroundColor.cgColor, config.highlightColor.cgColor, config.backgroundColor.cgColor]
        shimmeringLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        shimmeringLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        let weakView = OWWeakEncapsulation(value: view)
        weakViews.append(weakView)
        
        _ = isServiceRunning
            .take(1)
            .observe(on: scheduler)
            .filter { !$0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.isServiceRunning.onNext(true)
                self.startService()
            })
    }
    
    func removeSkeleton(from view: UIView) {
         guard let weakViewIndex = weakViews.firstIndex(where: { weakView in
            guard let aView = weakView.value() else { return false }
            return aView === view
         }) else { return }
        
        weakViews.remove(at: weakViewIndex)
        
        // Stop service if we removed the last skeleton view
        if weakViews.isEmpty {
            _ = isServiceRunning
                .take(1)
                .observe(on: scheduler)
                .filter { $0 }
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.stopService()
                    self.isServiceRunning.onNext(false)
                })
        }
    }
    
    func removeAllSkeletons() {
        weakViews.forEach { weakView in
            guard let view = weakView.value() else { return }
            (view as? OWSkeletonShimmeringProtocol)?.removeSkeletonShimmering()
        }
        weakViews.removeAll()
        stopService()
    }
}

fileprivate extension OWSkeletonShimmeringService {
    func stopService() {
        _ = Observable.just(())
            .take(1)
                .observe(on: scheduler)
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.disposeBag = nil // Cancel existing run of the service
                    self.isServiceRunning.onNext(false)
                })
    }
    
    func startService() {
        disposeBag = DisposeBag()
        
        Observable<Int>
            .interval(.milliseconds(100), scheduler: scheduler)
            .observe(on: scheduler)
            .filter { [weak self] num in
                guard let self = self else { return false }
                let intervalInSeconds = TimeInterval(num + 1) / 10 // Interval passed so far
                let reminder = intervalInSeconds.truncatingRemainder(dividingBy: self.config.duration)
                // Return true if the time which passed so far is a multiplier of the config duration
                return Double.equal(reminder, 0.0, precise: 10)
            }
            .startWith(0) // Start immediately
            .voidify()
            .delay(.milliseconds(10), scheduler: scheduler) // 10 milliseconds delay cause usually when we will start the service, a few skeleton views will be created, so let's sync their shimmering
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                // Apply animation on each skeletone view
                self.weakViews.forEach { weakView in
                    guard let skeletonShimmeringView = weakView.value(),
                          let shimmeringLayer = skeletonShimmeringView.getShimmeringLayer() else { return }

                    let animation = CABasicAnimation(keyPath: "transform.translation.x")
                    animation.duration = self.config.duration
                    let viewWidth = skeletonShimmeringView.frame.width
                    animation.fromValue = self.config.shimmeringDirection == .leftToRight ? viewWidth : -viewWidth
                    animation.toValue = self.config.shimmeringDirection == .leftToRight ? -viewWidth : viewWidth
                    animation.repeatCount = .zero
                    animation.autoreverses = false
                    animation.fillMode = CAMediaTimingFillMode.forwards
                    shimmeringLayer.add(animation, forKey: OWAssociatedSkeletonShimmering.shimmeringLayerAnimationIdentifier)
                }
            })
            .disposed(by: disposeBag)
    }
}
