//
//  Shadow.swift
//  Drawing
//
//  Created by Ken Orr on 4/6/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

import UIKit

/// A shadow that can be applied to an object.
///
///   - `offset` The offset from the center of the object where the shadow should be cast. For example, an offset of (1, -1) would cast a shadow down and to the right. The default is (1, -1).
///   - `blurRadius` The amount to blur the shadow. The default is 1.0.
///   - `opacity` The opacity of the shadow. A value of 1.0 means no transparency, while a value of 0.0 means fully transparent. The default value is 0.3.
///   - `color` The color of the shadow. The default value is black.
public struct Shadow {
    
    /// The offset from the center of the object where the shadow should be cast. For example, an offset of (1, -1) would cast a shadow down and to the right. The default is (1, -1).
    var offset = Point(x: 1.0, y: -1.0)
    
    /// The amount to blur the shadow. The default is 1.0.
    var blurRadius = 1.0
    
    /// The opacity of the shadow. A value of 1.0 means no transparency, while a value of 0.0 means fully transparent. The default value is 0.3.
    var opacity = 0.3
    
    /// The color of the shadow. The default value is black.
    var color = Color.black
    
    public init() {
        // nothing to do here.
    }
}

extension Shadow: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        get {
            return .text("Offset = \(offset), blur radius = \(blurRadius), opacity = \(opacity)")
        }
    }
}
