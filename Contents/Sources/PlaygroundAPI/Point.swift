//
//  Point.swift
//  Drawing
//
//  Created by Ken Orr on 4/8/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

import UIKit

/// A point on the canvas. It can be used for things like specifying the center point of an object.
///
///   - `x` The horizontal (left/right) component of this point.
///   - `y` The vertical (up/down) component of this point.
public struct Point {
    
    /// The horizontal (left/right) component of this point.
    public var x = 0.0
    
    /// The vertical (up/down) component of this point.
    public var y = 0.0
    
    internal var cgPoint: CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
    
    /// Creates a Point with the given x and y.
    ///
    /// `x` The horizontal (left/right) component of this point.
    /// `y` The vertical (up/down) component of this point.
    public init(x:Double, y: Double) {
        self.x = x
        self.y = y
    }
        
    internal init(_ cgPoint: CGPoint) {
        x = Double(cgPoint.x)
        y = Double(cgPoint.y)
    }
    
}

extension Point: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        get {
            return .text("x = \(x), y = \(y)")
        }
    }
}
