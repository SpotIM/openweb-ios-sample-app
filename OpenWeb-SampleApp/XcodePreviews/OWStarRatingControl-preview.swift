//
//  OWStarRatingControl-preview.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 30/06/2025.
//

#if DEBUG
@testable import OpenWebSDK
import SwiftUI

private extension UIStackView {
    func addArrangedSubview(_ view: UIView, title: String) {
        let label = UILabel().text(title)
        addArrangedSubview(label)
        addArrangedSubview(view)
        setCustomSpacing(spacing / 2, after: label)
    }
    
}

@available(iOS 17.0, *)
#Preview {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .leading
    stackView.spacing = 32

    stackView.addArrangedSubview(OWStarRatingControl(), title: "Default")

    let valueControl = OWStarRatingControl()
    valueControl.value = 3.5
    stackView.addArrangedSubview(valueControl, title: "With Value (3.5)")

    let minValueControl = OWStarRatingControl()
    minValueControl.minValue = 1
    minValueControl.value = 3
    stackView.addArrangedSubview(minValueControl, title: "Min Value 1 (3)")

    let customMaxControl = OWStarRatingControl()
    customMaxControl.maxValue = 10
    customMaxControl.value = 7
    stackView.addArrangedSubview(customMaxControl, title: "Custom Max (10) (7)")

    let customImagesControl = OWStarRatingControl()
    customImagesControl.emptyImage = UIImage(systemName: "heart")!
    customImagesControl.image = UIImage(systemName: "heart.fill")!
    customImagesControl.value = 3
    customImagesControl.tintColor = .red
    stackView.addArrangedSubview(customImagesControl, title: "Custom Images and tint (red hearts) (3)")

    return stackView
}

struct UIViewPreviewContainer<T: UIView>: UIViewRepresentable {
    let viewBuilder: () -> T
    
    init(_ viewBuilder: @escaping () -> T) {
        self.viewBuilder = viewBuilder
    }
    
    func makeUIView(context: Context) -> T {
        return viewBuilder()
    }
    
    func updateUIView(_ uiView: T, context: Context) {}
}
#endif
