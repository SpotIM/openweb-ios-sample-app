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

@available(iOS 17.0, *)
#Preview {
    let checkBox = OWRoundCheckBox()
    var isSelected = false

    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
        isSelected.toggle()
        checkBox.setSelected.send(isSelected)
    }

    let themeInjectorView = ThemeInjectorView()
    themeInjectorView.addSubview(checkBox)
    checkBox.snp.makeConstraints { make in
        make.center.equalToSuperview()
    }
    return themeInjectorView
}
#endif
