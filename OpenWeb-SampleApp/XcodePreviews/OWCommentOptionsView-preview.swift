//
//  OWCommentOptionsView-preview.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 11/05/2025.
//

#if DEBUG
@testable import OpenWebSDK

@available(iOS 17.0, *)
#Preview {
    let viewModel = OWCommentOptionsViewModel()
    viewModel.inputs.isCommentOfActiveUser.send(false)

    let optionsView = OWCommentOptionsView()
    optionsView.configure(with: viewModel)

    optionsView.layer.borderWidth = 1
    optionsView.layer.borderColor = UIColor.red.cgColor

    return optionsView
}
#endif
