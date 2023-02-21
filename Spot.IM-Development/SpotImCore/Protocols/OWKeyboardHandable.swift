//
//  KeyboardHandable.swift
//  TCPA-M
//

import UIKit

protocol OWKeyboardHandable {

    func keyboardWillShow(_ notification: Notification)
    func keyboardDidShow(_ notification: Notification)
    func keyboardWillHide(_ notification: Notification)
    func keyboardDidHide(_ notification: Notification)
    func keyboardWillChangeFrame(_ notification: Notification)
    func keyboardDidChangeFrame(_ notification: Notification)

    func registerForKeyboardNotifications()
    func unregisterFromKeyboardNotifications()

}

extension OWKeyboardHandable where Self: UIViewController {

    func keyboardWillShow(_ notification: Notification) {}
    func keyboardDidShow(_ notification: Notification) {}
    func keyboardWillHide(_ notification: Notification) {}
    func keyboardDidHide(_ notification: Notification) {}
    func keyboardWillChangeFrame(_ notification: Notification) {}
    func keyboardDidChangeFrame(_ notification: Notification) {}

    func registerForKeyboardNotifications() {
        _ = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: nil) { [weak self] notification in
                self?.keyboardWillShow(notification)
        }

        _ = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardDidShowNotification,
            object: nil,
            queue: nil) { [weak self] notification in
                self?.keyboardDidShow(notification)
        }

        _ = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: nil) { [weak self] notification in
                self?.keyboardWillHide(notification)
        }

        _ = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardDidHideNotification,
            object: nil,
            queue: nil) { [weak self] notification in
                self?.keyboardDidHide(notification)
        }

        _ = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: nil) { [weak self] notification in
                self?.keyboardWillChangeFrame(notification)
        }

        _ = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardDidChangeFrameNotification,
            object: nil,
            queue: nil) { [weak self] notification in
                self?.keyboardDidChangeFrame(notification)
        }
    }

    func unregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardDidShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardDidHideNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillChangeFrameNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardDidChangeFrameNotification,
                                                  object: nil)
    }

}
