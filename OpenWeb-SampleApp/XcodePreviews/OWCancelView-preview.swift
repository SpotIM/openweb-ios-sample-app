//
//  OWCancelView-preview.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 11/05/2025.
//

#if DEBUG
@testable import OpenWebSDK
import UIKit

@available(iOS 17.0, *)
#Preview("Report Reason") {
    OWCancelView(viewModel: OWCancelViewViewModel(type: .reportReason))
}

@available(iOS 17.0, *)
#Preview("Commenter Appeal") {
    OWCancelView(viewModel: OWCancelViewViewModel(type: .commenterAppeal))
}
#endif
