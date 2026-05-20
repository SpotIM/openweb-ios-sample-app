//
//  String+Extensions.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 09/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation

extension String {
    func markdown() -> AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        return (try? AttributedString(markdown: self, options: options)) ?? AttributedString(self)
    }
}
