//
//  OWCommentCreationView-preview.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 09/03/2025.
//

#if DEBUG
@testable import OpenWebSDK
import SnapKit
import UIKit

extension OWCommentCreationRequiredData {
    static func mock(commentCreationStyle: OWCommentCreationStyle) -> OWCommentCreationRequiredData {
        return OWCommentCreationRequiredData(
            article: OWArticle(
                articleInformationStrategy: .local(data: OWArticleExtraData(
                    url: URL(string: "https://test.com")!,
                    title: "This is a placeholder for the article title. The container is limited to two lines of text to avoid interface overwhelming but will show the context",
                    subtitle: "News Category",
                    thumbnailUrl: URL(string: "https://53.fs1.hubspotusercontent-na1.net/hub/53/hubfs/parts-url.jpg?width=595&height=400&name=parts-url.jpg")!)
                ),
                additionalSettings: OWArticleSettings(section: "default",
                                                      starRatingEnabled: true)
            ),
            settings: OWAdditionalSettings(commentCreationSettings: OWCommentCreationSettings(style: commentCreationStyle)),
            commentCreationType: .comment,
            presentationalStyle: .none,
            postId: "",
            openKeyboardType: .instant
        )
    }
}

@available(iOS 17.0, *)
#Preview("regular") {
    OWCommentCreationView(
        viewModel: OWCommentCreationViewViewModel(
            commentCreationData: .mock(commentCreationStyle: .regular),
            viewableMode: .independent
        )
    )
}

@available(iOS 17.0, *)
#Preview("light") {
    OWCommentCreationView(
        viewModel: OWCommentCreationViewViewModel(
            commentCreationData: .mock(commentCreationStyle: .light),
            viewableMode: .independent
        )
    )
}

@available(iOS 17.0, *)
#Preview("floating") {
    let viewController = UIViewController() // ensure full screen
    viewController.view.backgroundColor = .secondarySystemBackground

    let commentCreationData = OWCommentCreationRequiredData.mock(commentCreationStyle: .floatingKeyboard)
    OWSharedServicesProvider.shared.readOnlyService().set(readOnlyMode: .disable, postId: commentCreationData.postId)

    let mockKeyboardView = UIImageView(image: UIImage(systemName: "keyboard"))
    mockKeyboardView.contentMode = .scaleAspectFit
    mockKeyboardView.tintColor = .systemBackground
    mockKeyboardView.backgroundColor = .placeholderText
    viewController.view.addSubview(mockKeyboardView)
    mockKeyboardView.snp.makeConstraints { make in
        make.leading.trailing.bottom.equalToSuperview()
        make.height.equalTo(300)
    }

    let commentCreationView = OWCommentCreationView(
        viewModel: OWCommentCreationViewViewModel(
            commentCreationData: commentCreationData,
            viewableMode: .independent
        )
    )

    viewController.view.addSubview(commentCreationView)
    commentCreationView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview()
        make.bottom.equalTo(mockKeyboardView.snp.top)
    }

    viewController.view.bringSubviewToFront(mockKeyboardView)
    return viewController
}


@available(iOS 17.0, *)
#Preview("regular with nudge") {
    let viewModel = OWCommentCreationViewViewModel(
        commentCreationData: .mock(commentCreationStyle: .regular),
        viewableMode: .independent
    )

    let nudgeData = OWCommentCreationErrorResponse(verdict: .pending, tags: [.toxicity])
    viewModel.outputs.commentCreationRegularViewVm.inputs.showModerationNudge.send(nudgeData)

    return OWCommentCreationView(viewModel: viewModel)
}

@available(iOS 17.0, *)
#Preview("light with nudge") {
    let viewModel = OWCommentCreationViewViewModel(
        commentCreationData: .mock(commentCreationStyle: .light),
        viewableMode: .independent
    )

    let nudgeData = OWCommentCreationErrorResponse(verdict: .pending, tags: [.toxicity])
    viewModel.outputs.commentCreationLightViewVm.inputs.showModerationNudge.send(nudgeData)

    return OWCommentCreationView(viewModel: viewModel)
}

@available(iOS 17.0, *)
#Preview("floating with nudge") {
    let viewController = UIViewController() // ensure full screen
    viewController.view.backgroundColor = .secondarySystemBackground

    let commentCreationData = OWCommentCreationRequiredData.mock(commentCreationStyle: .floatingKeyboard)
    OWSharedServicesProvider.shared.readOnlyService().set(readOnlyMode: .disable, postId: commentCreationData.postId)

    let mockKeyboardView = UIImageView(image: UIImage(systemName: "keyboard"))
    mockKeyboardView.contentMode = .scaleAspectFit
    mockKeyboardView.tintColor = .systemBackground
    mockKeyboardView.backgroundColor = .placeholderText
    viewController.view.addSubview(mockKeyboardView)
    mockKeyboardView.snp.makeConstraints { make in
        make.leading.trailing.bottom.equalToSuperview()
        make.height.equalTo(300)
    }

    let viewModel = OWCommentCreationViewViewModel(
        commentCreationData: commentCreationData,
        viewableMode: .independent
    )

    let nudgeData = OWCommentCreationErrorResponse(verdict: .pending, tags: [.toxicity])
    viewModel.outputs.commentCreationFloatingKeyboardViewVm.inputs.showModerationNudge.send(nudgeData)

    let commentCreationView = OWCommentCreationView(viewModel: viewModel)

    viewController.view.addSubview(commentCreationView)
    commentCreationView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview()
        make.bottom.equalTo(mockKeyboardView.snp.top)
    }

    viewController.view.bringSubviewToFront(mockKeyboardView)
    return viewController
}
#endif
