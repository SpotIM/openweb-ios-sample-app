//
//  ResourceItem.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//

import Foundation

struct ResourceItem: Identifiable {
    let id = UUID()
    var title: String
    var description: String?
    var icon: String
    var url: URL?
}
