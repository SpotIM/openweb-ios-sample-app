//
//  OWCommentCreationView-preview.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 09/03/2025.
//

@testable import OpenWebSDK

@available(iOS 17.0, *)
#Preview {
    OWCommentCreationView(
        viewModel: OWCommentCreationViewViewModel(
            commentCreationData: OWCommentCreationRequiredData(
                article: OWArticle(
                    articleInformationStrategy: .local(data: OWArticleExtraData(
                        url: URL(string: "https://test.com")!,
                        title: "This is a placeholder for the article title. The container is limited to two lines of text to avoid interface overwhelming but will show the context",
                        subtitle: "News Category",
                        thumbnailUrl: URL(string: "https://53.fs1.hubspotusercontent-na1.net/hub/53/hubfs/parts-url.jpg?width=595&height=400&name=parts-url.jpg")!)
                    ),
                    additionalSettings: OWArticleSettings(section: "default")
                ),
                settings: OWAdditionalSettings(),
                commentCreationType: .comment,
                presentationalStyle: .none
            ),
            viewableMode: .independent
        )
    )
}
