//
//  UIControl+Combine.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 04/02/2025.
//

import UIKit
import Combine

extension UIControl {
    func publisher(for events: UIControl.Event) -> AnyPublisher<Void, Never> {
        UIControlPublisher(control: self, events: events).eraseToAnyPublisher()
    }
}

struct UIControlPublisher: Publisher {
    typealias Output = Void
    typealias Failure = Never

    private let control: UIControl
    private let events: UIControl.Event

    init(control: UIControl, events: UIControl.Event) {
        self.control = control
        self.events = events
    }

    func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Void == S.Input {
        let subscription = UIControlSubscription(subscriber: subscriber, control: control, events: events)
        subscriber.receive(subscription: subscription)
    }
}

private final class UIControlSubscription<S: Subscriber>: Subscription where S.Input == Void, S.Failure == Never {
    private var subscriber: S?
    private let control: UIControl
    private let events: UIControl.Event

    init(subscriber: S, control: UIControl, events: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        self.events = events

        control.addTarget(self, action: #selector(handleEvent), for: events)
    }

    func request(_ demand: Subscribers.Demand) {
        // We do nothing here as we only want to send events when they occur, not on demand.
    }

    func cancel() {
        subscriber = nil
        control.removeTarget(self, action: #selector(handleEvent), for: events)
    }

    @objc private func handleEvent() {
        _ = subscriber?.receive(())
    }
}
