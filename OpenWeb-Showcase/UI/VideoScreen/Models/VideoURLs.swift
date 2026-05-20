//
//  VideoURLs.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 11/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation

enum VideoURLs {
    static let all: [URL] = [
        "https://cdn.pixabay.com/video/2024/05/31/214669_small.mp4",
        "https://cdn.pixabay.com/video/2025/06/09/284568_small.mp4",
        "https://cdn.pixabay.com/video/2025/10/04/307864_small.mp4",
        "https://cdn.pixabay.com/video/2025/03/12/264272_small.mp4",
        "https://cdn.pixabay.com/video/2025/02/17/258799_small.mp4",
        "https://cdn.pixabay.com/video/2024/09/03/229521_small.mp4",
        "https://cdn.pixabay.com/video/2024/08/16/226795_small.mp4",
        "https://cdn.pixabay.com/video/2025/03/23/266987_small.mp4",
        "https://cdn.pixabay.com/video/2025/01/26/254787_small.mp4",
        "https://cdn.pixabay.com/video/2024/06/09/215936_small.mp4",
        "https://cdn.pixabay.com/video/2024/09/01/229272_small.mp4",
        "https://cdn.pixabay.com/video/2023/06/14/167196-836380675_small.mp4",
        "https://cdn.pixabay.com/video/2023/10/07/183967-872226594_small.mp4",
        "https://cdn.pixabay.com/video/2021/04/13/70957-536644224_small.mp4",
        "https://cdn.pixabay.com/video/2023/04/03/157299-814463044_small.mp4",
        "https://cdn.pixabay.com/video/2024/07/01/218958_small.mp4",
        "https://cdn.pixabay.com/video/2022/12/20/143635-784138054_small.mp4",
        "https://cdn.pixabay.com/video/2023/09/06/179346-861795824_small.mp4",
        "https://cdn.pixabay.com/video/2024/03/10/203660-921832585_small.mp4",
        "https://cdn.pixabay.com/video/2024/07/08/220158_small.mp4",
        "https://cdn.pixabay.com/video/2024/03/11/203768-922186965_small.mp4",
        "https://cdn.pixabay.com/video/2023/08/02/174233-851138165_small.mp4",
        "https://cdn.pixabay.com/video/2023/12/09/192576-892942889_small.mp4",
        "https://cdn.pixabay.com/video/2024/05/22/213040_small.mp4",
        "https://cdn.pixabay.com/video/2023/01/05/145452-787039507_small.mp4",
        "https://cdn.pixabay.com/video/2023/02/28/152622-803732492_small.mp4",
        "https://cdn.pixabay.com/video/2024/03/13/204035-923133963_small.mp4",
        "https://cdn.pixabay.com/video/2022/04/04/112834-697207944_small.mp4",
        "https://cdn.pixabay.com/video/2021/04/19/71570-538974134_small.mp4",
    ].compactMap { URL(string: $0) }

    static var shuffled: [URL] { all.shuffled() }
}
