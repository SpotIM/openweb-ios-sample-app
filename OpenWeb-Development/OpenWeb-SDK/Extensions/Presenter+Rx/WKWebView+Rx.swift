//
//  WKWebView+Rx.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 15/01/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import WebKit

extension Reactive where Base: WKWebView {

    var canGoBack: Observable<Bool> {
        return observe(Bool.self, "canGoBack")
            .unwrap()
    }

    var title: Observable<String?> {
        return observe(String.self, "title")
    }
}
