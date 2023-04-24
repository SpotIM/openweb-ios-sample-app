//
//  UIPopoverPresentatiomController+Rx.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 18/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

extension Reactive where Base: UIPopoverPresentationController {
    static func show(onViewController viewController: UIViewController,
                     sourceView: UIView? = nil,
                     animated: Bool = true,
                     preferredStyle: UIAlertController.Style = .alert,
                     title: String,
                     message: String,
                     actions: [UIRxAlertAction]) -> Observable<UIAlertType> {

        return Observable.create { observer in
            // Map to regular UIAlertAction
//            let alertActions = actions.map { rxAlert in
//                UIAction(title: rxAlert.title,
//                              style: rxAlert.style) { _ in
//                    observer.onNext(.selected(action: rxAlert))
//                    observer.onCompleted()
//                }
//            }

            
//            let shareText = "Check out this photo I took!"
//            let shareImage = UIImage(named: "my-photo.jpg")

//            let activityViewController = UIActivityViewController(activityItems: ["alertActions"], applicationActivities: nil)
////            activityViewController.popoverPresentationController?.barButtonItem = sourceView // assuming that 'ellipsisButton' is the UIBarButtonItem that was created earlier
//            activityViewController.popoverPresentationController?.sourceView = sourceView
//            viewController.present(activityViewController, animated: true, completion: nil)

//            // Create UIAlertController
//            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
//            // Add the actions to the alertVC
//            alertActions.forEach { alertVC.addAction($0) }
//
//            alertVC.modalPresentationStyle = .popover
//
//            var showRect = CGRect()
//            if let sourceView = sourceView {
//                showRect = viewController.view.convert(sourceView.frame, to: viewController.view)
//            }
//            if let popoverController = alertVC.popoverPresentationController {
//                popoverController.sourceView = viewController.view
//                popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
//                popoverController.permittedArrowDirections = .any
//            }
////            let presentingViewController = viewController.presentingViewController ?? viewController

//            viewController.present(activityViewController, animated: animated) {
//                observer.onNext(.completion)
//            }

            return Disposables.create()
        }
    }




//    static func show(onViewController viewController: UIViewController,
//                     sourceView: UIView? = nil,
//                     animated: Bool = true,
//                     preferredStyle: UIAlertController.Style = .alert,
//                     title: String,
//                     message: String,
//                     actions: [UIRxAlertAction]) -> Observable<UIAlertType> {
//
//        return Observable.create { observer in
//            // Map to regular UIAlertAction
//            let alertActions = actions.map { rxAlert in
//                UIAlertAction(title: rxAlert.title,
//                              style: rxAlert.style) { _ in
//                    observer.onNext(.selected(action: rxAlert))
//                    observer.onCompleted()
//                }
//            }
//
//            // Create UIAlertController
////            let alertVC = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
////            let alertVC = UIViewController()
////            let stackview = UIStackView()
////            // Add the actions to the alertVC
////            alertActions.forEach {
////                stackview.addSubview($0.title?.button ?? UIButton())
//////                alertVC.addAction($0)
////            }
////            alertVC.view.addSubview(stackview)
////            stackview.OWSnp.makeConstraints { make in
////                make.center.equalToSuperview()
////            }
////
////            alertVC.modalPresentationStyle = .popover
////            alertVC.popoverPresentationController?.sourceView = viewController.view
////            var showRect = CGRect()
////            if let frame = sourceView?.frame {
////                showRect = viewController.view.convert(frame, to: viewController.view)
////            }
////            alertVC.popoverPresentationController?.sourceRect = showRect
////            alertVC.popoverPresentationController?.delegate = viewController
////            alertVC.popoverPresentationController?.permittedArrowDirections = .any
//
//
//
//
////            let frame = sourceView?.frame ?? CGRect.zero
////
////            let popoverContentController = PopoverConetntViewController()
////            popoverContentController.modalPresentationStyle = .popover
////
////            // Present popover
////            if let popoverPresentationController = popoverContentController.popoverPresentationController {
////                popoverPresentationController.permittedArrowDirections = .up
////                popoverPresentationController.sourceView = viewController.view
////                popoverPresentationController.sourceRect = frame
////                popoverPresentationController.delegate = viewController
////                viewController.present(popoverContentController, animated: true, completion: nil)
////            }
//
//            //open popover view
//            var showRect = CGRect()
//            if let sourceView = sourceView {
//                showRect = viewController.view.convert(sourceView.frame, to: viewController.view)
//            }
//            let popVC = PopoverConetntViewController()
//            popVC.modalPresentationStyle = .popover
//            //Assign Delegate self
//            popVC.popoverPresentationController?.delegate = viewController
//            //Show the arrow upside, left side, right side and down side
//            popVC.popoverPresentationController?.permittedArrowDirections = .up
//            //assing base view
//            popVC.popoverPresentationController?.sourceView = viewController.view
//            //rect from where pop over will shown have generate above
//            popVC.popoverPresentationController?.sourceRect = showRect
//            popVC.preferredContentSize = CGSize(width: 200, height: 200)
//
//            viewController.present(popVC, animated: true, completion: nil)
//
//            return Disposables.create()
//        }
//    }
}

extension UIViewController: UIPopoverPresentationControllerDelegate {
//    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
//        return .none
//    }

//    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
//
//    }
//
//    public func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
//        return true
//    }
}

class PopoverConetntViewController: UIViewController {
    fileprivate lazy var text: UILabel = {
        return UILabel()
            .text("This is my label for the popover")
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        self.view.addSubview(text)
        text.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.view.backgroundColor = UIColor.white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
