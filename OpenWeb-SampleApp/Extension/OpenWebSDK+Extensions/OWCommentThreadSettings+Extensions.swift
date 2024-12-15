//
//  OWCommentThreadSettings+Extensions.swift
//  OpenWeb-Development
//
//  Created by Alon Shprung on 31/05/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK
#if !PUBLIC_DEMO_APP
    import OpenWeb_SampleApp_Internal_Configs
#endif

extension OWCommentThreadSettings {
    #if PUBLIC_DEMO_APP
    // TODO: change to some default comment id for the main public demo preset
    static var defaultCommentId = "sp_eCIlROSD_sdk1_c_2UOBeFUuZan6qSpJZUrAw8CBBF6_r_2UOBkTQqa2RMziIVSWLsaHJ7ifp"
    #else
    static var defaultCommentId = DevelopmentCommentThread.defaultCommentId
    #endif
}
