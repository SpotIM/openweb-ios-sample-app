//
//  OWNetworkExtended.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

/// Type that acts as a generic extension point for all `OWNetworkExtended` types.
struct OWNetworkExtension<ExtendedType> {
    /// Stores the type or meta-type of any extended type.
    private(set) var type: ExtendedType

    /// Create an instance from the provided value.
    ///
    /// - Parameter type: Instance being extended.
    init(_ type: ExtendedType) {
        self.type = type
    }
}

/// Protocol describing the `af` extension points for OWNetwork extended types.
protocol OWNetworkExtended {
    /// Type being extended.
    associatedtype ExtendedType

    /// Static OWNetwork extension point.
    static var owNetwork: OWNetworkExtension<ExtendedType>.Type { get set }
    /// Instance OWNetwork extension point.
    var owNetwork: OWNetworkExtension<ExtendedType> { get set }
}

extension OWNetworkExtended {
    /// Static OWNetwork extension point.
    static var owNetwork: OWNetworkExtension<Self>.Type {
        get { OWNetworkExtension<Self>.self }
        set {} // swiftlint:disable:this unused_setter_value
    }

    /// Instance OWNetwork extension point.
    var owNetwork: OWNetworkExtension<Self> {
        get { OWNetworkExtension(self) }
        set {} // swiftlint:disable:this unused_setter_value
    }
}
