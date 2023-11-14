//
//  OWNavigationPlaceholderVC.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 13/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

class OWNavigationPlaceholderVC: UIViewController {

    fileprivate let onFirstChild: () -> Void
    fileprivate var timer: Timer? = nil

    init(onFirstChild: @escaping () -> Void) {
        self.onFirstChild = onFirstChild
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func navigationSet() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if let topVC = self.navigationController?.topViewController, topVC != self {
                self.onFirstChild()
                // Once new VC added no need to have this empty VC so it is removed
                if var viewControllers = self.navigationController?.viewControllers,
                   let index = viewControllers.firstIndex(of: self) {
                    viewControllers.remove(at: index)
                    self.navigationController?.viewControllers = viewControllers
                }
                self.timer?.invalidate()
                self.dismiss(animated: false)
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
}
