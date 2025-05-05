//
//  OWTypingAnimationView-preview.swift
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
    let typingView = OWTypingAnimationView(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
    typingView.startAnimating()

    let previewContainer = UIView()
    previewContainer.backgroundColor = .systemBackground
    previewContainer.addSubview(typingView)
    typingView.snp.makeConstraints { make in
        make.center.equalToSuperview()
        make.width.equalTo(60)
        make.height.equalTo(20)
    }
    return previewContainer
}
#endif
