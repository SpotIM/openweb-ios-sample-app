//
//  OWRoundCheckBox-preview.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 10/03/2025.
//

#if DEBUG
@testable import OpenWebSDK
import SnapKit
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

@available(iOS 17.0, *)
#Preview {
    let checkBox = OWRoundCheckBox()
    var isSelected = false

    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
        isSelected.toggle()
        checkBox.setSelected.onNext(isSelected)
    }

    let themeInjectorView = ThemeInjectorView()
    themeInjectorView.addSubview(checkBox)
    checkBox.snp.makeConstraints { make in
        make.center.equalToSuperview()
    }
    return themeInjectorView
}
#endif
