//
//  AlamofireExtended.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

/// Type that acts as a generic extension point for all `AlamofireExtended` types.
struct AlamofireExtension<ExtendedType> {
    /// Stores the type or meta-type of any extended type.
    private(set) var type: ExtendedType

    /// Create an instance from the provided value.
    ///
    /// - Parameter type: Instance being extended.
    init(_ type: ExtendedType) {
        self.type = type
    }
}

/// Protocol describing the `af` extension points for Alamofire extended types.
protocol AlamofireExtended {
    /// Type being extended.
    associatedtype ExtendedType

    /// Static Alamofire extension point.
    static var af: AlamofireExtension<ExtendedType>.Type { get set }
    /// Instance Alamofire extension point.
    var af: AlamofireExtension<ExtendedType> { get set }
}

extension AlamofireExtended {
    /// Static Alamofire extension point.
    static var af: AlamofireExtension<Self>.Type {
        get { AlamofireExtension<Self>.self }
        set {}
    }

    /// Instance Alamofire extension point.
    var af: AlamofireExtension<Self> {
        get { AlamofireExtension(self) }
        set {}
    }
}
