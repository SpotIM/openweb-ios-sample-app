//
//  OWToastView-preview.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 10/03/2025.
//

#if DEBUG
@testable import OpenWebSDK
import SnapKit

extension OWToastView {
    convenience init(type: OWToastType, action: OWToastAction, title: String) {
        let viewModel = OWToastViewModel(requiredData: OWToastRequiredData(type: type, action: action, title: title), completions: [:])
        self.init(viewModel: viewModel)
    }
}

@available(iOS 17.0, *)
#Preview {
    UIStackView(arrangedSubviews: [
        OWToastView(type: .warning, action: .tryAgain, title: "Oops! Something went wrong"),
        OWToastView(type: .information, action: .none, title: "All is well"),
        OWToastView(type: .error, action: .close, title: "Short error"),
        OWToastView(type: .error, action: .close, title: "Long error message that is longer than the other ones to test the multiline behavior, preferably well over two or three lines of text."), // swiftlint:disable:this line_length
        OWToastView(type: .success, action: .learnMore, title: "Nicely done"),
        OWToastView(type: .warning, action: .undo, title: "Nicely undone"),
    ])
    .axis(.vertical)
    .spacing(32)
    .padding(16)
}
#endif
