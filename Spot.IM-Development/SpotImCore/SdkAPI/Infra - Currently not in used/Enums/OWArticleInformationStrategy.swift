//
//  OWArticleInformationStrategy.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 23/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWArticleInformationStrategy: Codable {
    case server
    case local(url: URL, title: String, subtitle: String?, thumbnailUrl: URL?)

    // TODO: ?
    public var url: URL {
        switch self {
        case .server: return URL(fileURLWithPath: "")
        case .local(let url, _, _, _): return url
        }
    }
    public var title: String {
        switch self {
        case .server: return ""
        case .local(_, let title, _, _): return title
        }
    }
    public var subtitle: String? {
        switch self {
        case .server: return nil
        case .local(_, _, let subtitle, _): return subtitle
        }
    }
    public var thumbnailUrl: URL? {
        switch self {
        case .server: return nil
        case .local(_, _, _, let thumbnailUrl): return thumbnailUrl
        }
    }

//    private var extraData: SPConversationExtraDataRM? = nil
//    var serverUrl: URL = URL(fileURLWithPath: "")
//    var serverTitle: String = ""
//    var serverSubtitle: String? = nil
//    var serverThumbnailUrl: URL? = nil
//    func setServerData(url: URL, title: String, subtitle: String?, thumbnailUrl: URL?) {
//        serverUrl = url
//        serverTitle = title
//        serverSubtitle = subtitle
//        serverThumbnailUrl = thumbnailUrl
//    }
}
#else
enum OWArticleInformationStrategy {
    case server
    case local(url: URL, title: String, subtitle: String?, thumbnailUrl: URL?)

    var url: URL {
        switch self {
        case .server: return URL(fileURLWithPath: "")
        case .local(let url, _, _, _): return url
        }
    }
    var title: String {
        switch self {
        case .server: return ""
        case .local(_, let title, _, _): return title
        }
    }
    var subtitle: String? {
        switch self {
        case .server: return nil
        case .local(_, _, let subtitle, _): return subtitle
        }
    }
    var thumbnailUrl: URL? {
        switch self {
        case .server: return nil
        case .local(_, _, _, let thumbnailUrl): return thumbnailUrl
        }
    }
}
#endif

