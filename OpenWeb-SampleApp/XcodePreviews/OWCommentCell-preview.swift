//
//  OWCommentCell-preview.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 19/06/2025.
//

#if DEBUG
@testable import OpenWebSDK
import RxSwift
import UIKit

extension OWCommentCellViewModel {
    convenience init(comment: OWComment, user: SPUser, depth: Int = 0) {
        let commentRequiredData = OWCommentRequiredData(
            comment: comment,
            user: user,
            replyToUser: nil,
            collapsableTextLineLimit: 5,
            section: "",
            postId: "somePostId"
        )

        self.init(commentRequiredData: commentRequiredData, spacing: .zero, viewableMode: .partOfFlow)
    }
}

extension OWContent {
    static func text(_ text: String) -> OWContent {
        let json = """
        {
            "id": "content1",
            "type": "text",
            "text": "\(text)"
        }
        """.data(using: .utf8)!

        // swiftlint:disable:next force_try
        return try! JSONDecoder().decode(OWContent.self, from: json)
    }
}

extension OWComment {
    static func mock(
        _ content: String,
        depth: Int = 0,
        status: String = "approve",
        edited: Bool = false,
        deleted: Bool = false,
        reported: Bool = false,
        stars: Int? = nil
    ) -> OWComment {
        return OWComment(
            id: UUID().uuidString,
            depth: depth,
            userId: "u_123456",
            repliesCount: Int.random(in: 0...15),
            rawStatus: status,
            edited: edited,
            deleted: deleted,
            reported: reported,
            content: [
                OWContent.text(content)
            ],
            stars: stars
        )
    }
}

extension SPUser {
    static func mock(
        id: String = "u_123456",
        displayName: String = "John Doe",
        imageId: String = "#Blue-Toast"
    ) -> SPUser {
        let user = SPUser()
        user.userId = id
        user.displayName = displayName
        user.imageId = imageId
        return user
    }
}

class CommentPreviewTableView: UITableView, UITableViewDataSource {
    let cellIdentifier = "OWCommentCell"
    let comments: [OWComment]

    let authors = [
        SPUser.mock(id: "u_kirk", displayName: "James T. Kirk", imageId: "#Gold-Toast"),
        SPUser.mock(id: "u_spock", displayName: "Spock", imageId: "#Blue-Toast"),
        SPUser.mock(id: "u_mccoy", displayName: "Leonard McCoy", imageId: "#Blue-Toast"),
        SPUser.mock(id: "u_picard", displayName: "Jean-Luc Picard", imageId: "#Red-Toast"),
        SPUser.mock(id: "u_data", displayName: "Data", imageId: "#Gold-Toast"),
    ]

    init(comments: [OWComment]) {
        self.comments = comments
        super.init(frame: .zero, style: .plain)
        self.register(OWCommentCell.self, forCellReuseIdentifier: cellIdentifier)
        self.separatorStyle = .none
        self.backgroundColor = OWColorPalette.shared.dynamicColor(type: .backgroundColor2)
        self.estimatedRowHeight = 200
        self.rowHeight = UITableView.automaticDimension
        self.dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OWCommentCell

        let viewModel = OWCommentCellViewModel(
            comment: comments[indexPath.row],
            user: authors[indexPath.row % authors.count],
            depth: comments[indexPath.row].depth ?? 0
        )
        cell.configure(with: viewModel)
        return cell
    }
}

@available(iOS 17.0, *)
#Preview {
    CommentPreviewTableView(comments: [
        OWComment.mock("Sample comment text that demonstrates how comments appear in the OpenWeb SDK.", depth: 0, status: "approved", stars: 5),
        OWComment.mock("Reply to the first comment.", depth: 1, stars: 1),
        // swiftlint:disable:next line_length
        OWComment.mock("Nested reply with a longer text that will likely wrap to multiple lines. Let's see how the cell handles this kind of content with proper wrapping and spacing.", depth: 2, edited: true),
        OWComment.mock("Pending comment that's awaiting moderation.", status: "pending", stars: 5),
        OWComment.mock("Rejected comment that has been moderated.", status: "reject", deleted: true, stars: 2),
        OWComment.mock("Reported comment.", status: "report", reported: true, stars: 3),
        OWComment.mock("Blocked comment.", status: "block", stars: 4),
    ])
}
#endif
