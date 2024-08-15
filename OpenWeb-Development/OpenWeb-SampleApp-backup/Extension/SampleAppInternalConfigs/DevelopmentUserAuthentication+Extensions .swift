//
//  DevelopmentUserAuthentication+Extensions .swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 15/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

#if !PUBLIC_DEMO_APP
import Foundation
import OpenWeb_SampleApp_Internal_Configs

extension DevelopmentUserAuthentication {
    func toUserAuthentication () -> UserAuthentication {
        return UserAuthentication(username: self.username,
                                  password: self.password,
                                  userId: self.userId)
    }
}

#endif
