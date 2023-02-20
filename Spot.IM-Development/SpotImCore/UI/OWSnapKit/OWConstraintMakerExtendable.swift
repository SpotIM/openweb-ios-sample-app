//
//  OWConstraintMakerExtendable.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

class OWConstraintMakerExtendable: OWConstraintMakerRelatable {

    var left: OWConstraintMakerExtendable {
        self.description.attributes += .left
        return self
    }

    var top: OWConstraintMakerExtendable {
        self.description.attributes += .top
        return self
    }

    var bottom: OWConstraintMakerExtendable {
        self.description.attributes += .bottom
        return self
    }

    var right: OWConstraintMakerExtendable {
        self.description.attributes += .right
        return self
    }

    var leading: OWConstraintMakerExtendable {
        self.description.attributes += .leading
        return self
    }

    var trailing: OWConstraintMakerExtendable {
        self.description.attributes += .trailing
        return self
    }

    var width: OWConstraintMakerExtendable {
        self.description.attributes += .width
        return self
    }

    var height: OWConstraintMakerExtendable {
        self.description.attributes += .height
        return self
    }

    var centerX: OWConstraintMakerExtendable {
        self.description.attributes += .centerX
        return self
    }

    var centerY: OWConstraintMakerExtendable {
        self.description.attributes += .centerY
        return self
    }

    var lastBaseline: OWConstraintMakerExtendable {
        self.description.attributes += .lastBaseline
        return self
    }

    var firstBaseline: OWConstraintMakerExtendable {
        self.description.attributes += .firstBaseline
        return self
    }

    var leftMargin: OWConstraintMakerExtendable {
        self.description.attributes += .leftMargin
        return self
    }

    var rightMargin: OWConstraintMakerExtendable {
        self.description.attributes += .rightMargin
        return self
    }

    var topMargin: OWConstraintMakerExtendable {
        self.description.attributes += .topMargin
        return self
    }

    var bottomMargin: OWConstraintMakerExtendable {
        self.description.attributes += .bottomMargin
        return self
    }

    var leadingMargin: OWConstraintMakerExtendable {
        self.description.attributes += .leadingMargin
        return self
    }

    var trailingMargin: OWConstraintMakerExtendable {
        self.description.attributes += .trailingMargin
        return self
    }

    var centerXWithinMargins: OWConstraintMakerExtendable {
        self.description.attributes += .centerXWithinMargins
        return self
    }

    var centerYWithinMargins: OWConstraintMakerExtendable {
        self.description.attributes += .centerYWithinMargins
        return self
    }

    var edges: OWConstraintMakerExtendable {
        self.description.attributes += .edges
        return self
    }
    var horizontalEdges: OWConstraintMakerExtendable {
        self.description.attributes += .horizontalEdges
        return self
    }
    var verticalEdges: OWConstraintMakerExtendable {
        self.description.attributes += .verticalEdges
        return self
    }
    var directionalEdges: OWConstraintMakerExtendable {
        self.description.attributes += .directionalEdges
        return self
    }
    var directionalHorizontalEdges: OWConstraintMakerExtendable {
        self.description.attributes += .directionalHorizontalEdges
        return self
    }
    var directionalVerticalEdges: OWConstraintMakerExtendable {
        self.description.attributes += .directionalVerticalEdges
        return self
    }
    var size: OWConstraintMakerExtendable {
        self.description.attributes += .size
        return self
    }

    var margins: OWConstraintMakerExtendable {
        self.description.attributes += .margins
        return self
    }

    var directionalMargins: OWConstraintMakerExtendable {
      self.description.attributes += .directionalMargins
      return self
    }

    var centerWithinMargins: OWConstraintMakerExtendable {
        self.description.attributes += .centerWithinMargins
        return self
    }
}
