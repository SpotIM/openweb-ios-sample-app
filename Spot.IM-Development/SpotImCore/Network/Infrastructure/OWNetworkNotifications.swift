//
//  Notifications.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

extension OWNetworkRequest {
    /// Posted when a `Request` is resumed. The `Notification` contains the resumed `Request`.
    static let didResumeNotification = Notification.Name(rawValue: "org.OpenWebSDKNetwork.notification.name.request.didResume")
    /// Posted when a `Request` is suspended. The `Notification` contains the suspended `Request`.
    static let didSuspendNotification = Notification.Name(rawValue: "org.OpenWebSDKNetwork.notification.name.request.didSuspend")
    /// Posted when a `Request` is cancelled. The `Notification` contains the cancelled `Request`.
    static let didCancelNotification = Notification.Name(rawValue: "org.OpenWebSDKNetwork.notification.name.request.didCancel")
    /// Posted when a `Request` is finished. The `Notification` contains the completed `Request`.
    static let didFinishNotification = Notification.Name(rawValue: "org.OpenWebSDKNetwork.notification.name.request.didFinish")

    /// Posted when a `URLSessionTask` is resumed. The `Notification` contains the `Request` associated with the `URLSessionTask`.
    static let didResumeTaskNotification = Notification.Name(rawValue: "org.OpenWebSDKNetwork.notification.name.request.didResumeTask")
    /// Posted when a `URLSessionTask` is suspended. The `Notification` contains the `Request` associated with the `URLSessionTask`.
    static let didSuspendTaskNotification = Notification.Name(rawValue: "org.OpenWebSDKNetwork.notification.name.request.didSuspendTask")
    /// Posted when a `URLSessionTask` is cancelled. The `Notification` contains the `Request` associated with the `URLSessionTask`.
    static let didCancelTaskNotification = Notification.Name(rawValue: "org.OpenWebSDKNetwork.notification.name.request.didCancelTask")
    /// Posted when a `URLSessionTask` is completed. The `Notification` contains the `Request` associated with the `URLSessionTask`.
    static let didCompleteTaskNotification = Notification.Name(rawValue: "org.OpenWebSDKNetwork.notification.name.request.didCompleteTask")
}

// MARK: -

extension Notification {
    /// The `Request` contained by the instance's `userInfo`, `nil` otherwise.
    var request: OWNetworkRequest? {
        userInfo?[String.requestKey] as? OWNetworkRequest
    }

    /// Convenience initializer for a `Notification` containing a `Request` payload.
    ///
    /// - Parameters:
    ///   - name:    The name of the notification.
    ///   - request: The `Request` payload.
    init(name: Notification.Name, request: OWNetworkRequest) {
        self.init(name: name, object: nil, userInfo: [String.requestKey: request])
    }
}

extension NotificationCenter {
    /// Convenience function for posting notifications with `Request` payloads.
    ///
    /// - Parameters:
    ///   - name:    The name of the notification.
    ///   - request: The `Request` payload.
    func postNotification(named name: Notification.Name, with request: OWNetworkRequest) {
        let notification = Notification(name: name, request: request)
        post(notification)
    }
}

extension String {
    /// User info dictionary key representing the `Request` associated with the notification.
    fileprivate static let requestKey = "org.OpenWebSDKNetwork.notification.key.request"
}

/// `EventMonitor` that provides OWNetwork's notifications.
class OWNetworkNotifications: OWNetworkEventMonitor {
    func requestDidResume(_ request: OWNetworkRequest) {
        NotificationCenter.default.postNotification(named: OWNetworkRequest.didResumeNotification, with: request)
    }

    func requestDidSuspend(_ request: OWNetworkRequest) {
        NotificationCenter.default.postNotification(named: OWNetworkRequest.didSuspendNotification, with: request)
    }

    func requestDidCancel(_ request: OWNetworkRequest) {
        NotificationCenter.default.postNotification(named: OWNetworkRequest.didCancelNotification, with: request)
    }

    func requestDidFinish(_ request: OWNetworkRequest) {
        NotificationCenter.default.postNotification(named: OWNetworkRequest.didFinishNotification, with: request)
    }

    func request(_ request: OWNetworkRequest, didResumeTask task: URLSessionTask) {
        NotificationCenter.default.postNotification(named: OWNetworkRequest.didResumeTaskNotification, with: request)
    }

    func request(_ request: OWNetworkRequest, didSuspendTask task: URLSessionTask) {
        NotificationCenter.default.postNotification(named: OWNetworkRequest.didSuspendTaskNotification, with: request)
    }

    func request(_ request: OWNetworkRequest, didCancelTask task: URLSessionTask) {
        NotificationCenter.default.postNotification(named: OWNetworkRequest.didCancelTaskNotification, with: request)
    }

    func request(_ request: OWNetworkRequest, didCompleteTask task: URLSessionTask, with error: OWNetworkError?) {
        NotificationCenter.default.postNotification(named: OWNetworkRequest.didCompleteTaskNotification, with: request)
    }
}
