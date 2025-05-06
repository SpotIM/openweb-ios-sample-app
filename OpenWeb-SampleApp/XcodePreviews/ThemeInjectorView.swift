//
//  ThemeInjectorView.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 04/05/2025.
//

#if DEBUG
@testable import OpenWebSDK
import UIKit

class ThemeInjectorView: UIView, OWThemeStyleInjectorProtocol {
    override init(frame: CGRect) {
        super.init(frame: frame)
        useAsThemeStyleInjector()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
