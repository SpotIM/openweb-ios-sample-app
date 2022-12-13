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
    fileprivate var serviceDisposeBag: DisposeBag!
    fileprivate let generalDisposeBag = DisposeBag()
    fileprivate let isServiceRunning = BehaviorSubject<Bool>(value: false)
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    
    fileprivate struct Metrics {
        static var animationKey = "transform.translation.x"
    }
    
    init(config: OWSkeletonShimmeringConfiguration,
         scheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: "OpenWebSDKSkeletonShimmeringServiceQueue"),
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.config = config
        self.scheduler = scheduler
        self.servicesProvider = servicesProvider
        
        setupObservers()
    }
    
    func addSkeleton(to view: UIView) {
        guard let skeletonLayer = view.getSkeletonLayer(),
              let shimmeringLayer = view.getShimmeringLayer() else { return }
        
        let currentStyle = servicesProvider.themeStyleService().currentStyle
        let backgroundColor = OWColorPalette.shared.color(type: config.backgroundColor,
                                                          themeStyle: currentStyle)
        let highlightColor = OWColorPalette.shared.color(type: config.highlightColor,
                                                         themeStyle: currentStyle)
        
        skeletonLayer.backgroundColor = backgroundColor.cgColor
        shimmeringLayer.colors = [backgroundColor.cgColor, highlightColor.cgColor, backgroundColor.cgColor]
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
                self.serviceDisposeBag = nil // Cancel existing run of the service
                self.isServiceRunning.onNext(false)
            })
    }
    
    func startService() {
        serviceDisposeBag = DisposeBag()
        
        Observable<Int>
            .interval(.milliseconds(config.duration), scheduler: scheduler)
            .observe(on: scheduler)
            .startWith(0) // Start immediately
            .voidify()
            .delay(.milliseconds(10), scheduler: scheduler) // 10 milliseconds delay cause usually when we will start the service, a few skeleton views will be created, so let's sync their shimmering
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                // Apply animation on each skeleton view
                self.weakViews.forEach { weakView in
                    guard let skeletonShimmeringView = weakView.value(),
                          let shimmeringLayer = skeletonShimmeringView.getShimmeringLayer() else { return }
                    
                    let animation = CABasicAnimation(keyPath: Metrics.animationKey)
                    animation.duration = CFTimeInterval(self.config.duration / 1000) // Convert to seconds
                    let viewWidth = skeletonShimmeringView.frame.width
                    animation.fromValue = self.config.shimmeringDirection == .leftToRight ? viewWidth : -viewWidth
                    animation.toValue = self.config.shimmeringDirection == .leftToRight ? -viewWidth : viewWidth
                    animation.repeatCount = .zero
                    animation.autoreverses = false
                    animation.fillMode = CAMediaTimingFillMode.forwards
                    shimmeringLayer.add(animation, forKey: OWAssociatedSkeletonShimmering.shimmeringLayerAnimationIdentifier)
                }
            })
            .disposed(by: serviceDisposeBag)
    }
    
    func setupObservers() {
        servicesProvider.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] style in
                guard let self = self else { return }
                let backgroundColor = OWColorPalette.shared.color(type: self.config.backgroundColor,
                                                                  themeStyle: style)
                let highlightColor = OWColorPalette.shared.color(type: self.config.highlightColor,
                                                                 themeStyle: style)
                
                self.weakViews.forEach { weakView in
                    guard let skeletonShimmeringView = weakView.value(),
                          let skeletonLayer = skeletonShimmeringView.getSkeletonLayer(),
                          let shimmeringLayer = skeletonShimmeringView.getShimmeringLayer() else { return }
                    
                    skeletonLayer.backgroundColor = backgroundColor.cgColor
                    shimmeringLayer.colors = [backgroundColor.cgColor, highlightColor.cgColor, backgroundColor.cgColor]
                }
            })
            .disposed(by: generalDisposeBag)
    }
}
