//
//  SPReplyViewController.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/7/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

final class SPReplyCreationViewController: CommentReplyViewController<SPReplyCreationModel> {
    
    private lazy var commentHeaderView = SPCommentHeaderView()
    
    internal override func updateModelData() {
        configureModelHandlers()
        topContainerView.addSubview(commentHeaderView)
        commentHeaderView.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        commentHeaderView.configure(with: CommentDataModel(author: model?.dataModel.authorName,
                                                           comment: model?.dataModel.comment)
        )
        commentHeaderView.pinEdges(to: topContainerView)
        textInputViewContainer.configureCommentType(.reply)
        textInputViewContainer.updateText(model?.commentText ?? "")
        
        model?.fetchNavigationAvatar { [weak self] image, _ in
            guard
                let self = self,
                let image = image
                else { return }
            
            self.updateUserIcon(image: image)
            self.textInputViewContainer.updateAvatar(image)
        }
    }
    
    private func configureModelHandlers() {
        model?.postCompletionHandler = { [weak self] reply in
            guard let self = self else { return }

            if reply.status == .block || !reply.published {
                self.delegate?.commentReplyDidBlock(with: reply.content?.first?.text)
            } else {
                self.delegate?.commentReplyDidCreate(reply)
            }
            self.dismissController()
        }
        
        model?.postErrorHandler = { [weak self] error in
            guard let self = self else { return }

            self.hideLoader()
            self.showAlert(
                title: NSLocalizedString("Oops...", bundle: Bundle.spot, comment: "oops"),
                message: error.localizedDescription
            )
        }
    }
}
