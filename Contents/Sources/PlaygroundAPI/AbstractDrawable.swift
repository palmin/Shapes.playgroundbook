//
//  Shape.swift
//  Drawing
//
//  Created by Ken Orr on 4/6/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

/// An abstract drawable object that all concrete drawable objects derive from.
public class AbstractDrawable {
    
    // MARK: Display API
    
    // Question (sam page): Should the majority of these API have implicit animations behind them, i.e setting the size?
    
    /// The drop shadow for this object. The default is nil, which results in no shadow. To add a shadow, you can set this property, like this: `myObject.dropShadow = Shadow()`.
    public var dropShadow: Shadow? = nil {
        didSet {
            if let dropShadow = dropShadow {
                let xOffset = CGFloat(Canvas.shared.convertMagnitudeToScreen(modelMagnitude: dropShadow.offset.x))
                let yOffset = CGFloat(Canvas.shared.convertMagnitudeToScreen(modelMagnitude: dropShadow.offset.y) * (-1))
                backingView.layer.shadowOffset = CGSize(width: xOffset, height: yOffset)
                backingView.layer.shadowRadius = CGFloat(Canvas.shared.convertMagnitudeToScreen(modelMagnitude: dropShadow.blurRadius))
                backingView.layer.shadowOpacity = Float(dropShadow.opacity)
                backingView.layer.shadowColor = dropShadow.color.cgColor
            } else {
                backingView.layer.shadowOpacity = 0.0
            }
        }
    }
    
    /// The amount to grow or shrink the object. A value of 1.0 (the default) is the natural (unscaled) size. A value of 0.5 would be 1/2 the orginal size, while a value of 2.0 would be twice the original size.
    public var scale: Double = 1.0 {
        didSet {
            let scaleFloat = CGFloat(scale)
            scaleTransform = CGAffineTransform(scaleX: scaleFloat, y: scaleFloat)
        }
    }
    
    /// The angle in radians to rotate this object. Changing this rotates the object counter clockwise about it's center. A value of 0.0 (the default) means no rotation. A value of π (3.14159…) will rotate the object 180°, while 2π will rotate a full 360°.
    public var rotation: Double = 0.0 {
        didSet {
            let rotationFloat = CGFloat(rotation)
            rotationTransform = CGAffineTransform(rotationAngle: rotationFloat)
        }
    }
    
    /// Makes the object draggable with your finger on the canvas. The default value is false.
    public var draggable = false
    
    // MARK: Internal display
    
    private var scaleTransform: CGAffineTransform? = nil {
        didSet {
            updateDisplayForTransforms()
        }
    }
    
    private var rotationTransform: CGAffineTransform? = nil {
        didSet {
            updateDisplayForTransforms()
        }
    }
    
    internal func defaultRotationTransform() -> CGAffineTransform {
        return CGAffineTransform.identity
    }
    
    internal func updateDisplayForTransforms() {
        var transform = defaultRotationTransform()
        if let scaleTransform = scaleTransform {
            transform = transform.concat(scaleTransform)
        }
        if let rotationTransform = rotationTransform {
            transform = transform.concat(rotationTransform)
        }
        backingView.transform = transform
    }
    
    // MARK: Interaction API

    private var onTouchDownHandler: (() -> Void)?
    /// A handler for when a touch down is detected on this object.
    public func onTouchDown(_ handler: () -> Void) {
        onTouchDownHandler = handler
    }

    private var onTouchUpHandler: (() -> Void)?
    /// A handler for when a touch up is detected on this object.
    public func onTouchUp(_ handler: () -> Void) {
        onTouchUpHandler = handler
    }
    
    private var onTouchDragHandler: (() -> Void)?
    /// A handler for when a drag is detected on this object.
    public func onTouchDrag(_ handler: () -> Void) {
        onTouchDragHandler = handler
    }
    
    private var onTouchCancelledHandler: (() -> Void)?
    /// A handler for when a touch has been canceld on this object.
    public func onTouchCancelled(_ handler: () -> Void) {
        onTouchCancelledHandler = handler
    }
    
    // MARK: Internal
    
    internal let backingView: UIView
    
    internal var touchGestureRecognizer: TouchGestureRecognizer
    
    private var offsetFromTouchToCenter = Point(x: 0,y: 0)
    
    /// The center point of the object. Changing this moves the object.
    public var center: Point {
        get {
            return Canvas.shared.convertPointFromScreen(screenPoint: backingView.center)
        }
        set {
            let screenPoint = Canvas.shared.convertPointToScreen(modelPoint: newValue)
            backingView.center = screenPoint.cgPoint
        }
    }
    
    internal init(modelSize: Size, backingView: UIView) {
        
        self.backingView = backingView
        
        touchGestureRecognizer = TouchGestureRecognizer()
        touchGestureRecognizer.touchDelegate = self
        backingView.addGestureRecognizer(touchGestureRecognizer)
        
        updateBackingViewSizeFromModelSize(modelSize: modelSize)
        updateDisplayForTransforms()
        
        Canvas.shared.addDrawable(drawable: self)
    }
    
    internal func updateBackingViewSizeFromModelSize(modelSize: Size) {
        // adjust the size to be in points.
        var screenSize = modelSize
        screenSize.width *= Canvas.shared.numPointsPerUnit
        screenSize.height *= Canvas.shared.numPointsPerUnit
        
        // remove any transforms.
        backingView.transform = CGAffineTransform.identity
        
        udpateBackingViewSizeFromScreenSize(screenSize: screenSize)
        
        // add any transforms back.
        updateDisplayForTransforms()
    }
    
    internal func udpateBackingViewSizeFromScreenSize(screenSize: Size) {
        // remember the old center point.
        let oldCenter = backingView.center
        
        // set the default size on the view.
        backingView.frame.size = screenSize.cgSize
        
        // restore the center point.
        backingView.center = oldCenter
        
        // give subclasses a chance to react to the size change.
        self.sizeDidChange()
    }
    
    // QUESTION (ken orr): should we require subclasses to call super.sizeDidChange()?
    internal func sizeDidChange() {
        // nothing to do here -- hook for subclasses.
    }
}

extension AbstractDrawable: TouchGestureRecognizerDelegate {
    
    func touchesBegan(touches: Set<UITouch>, with event: UIEvent) {
        
        guard let touch = touches.first else { return }
        
        if (draggable) {
            // Bring the shape to the front.
            // Question: How should we expose z-ordering to the user?
            if let superview = self.backingView.superview {
                superview.bringSubview(toFront: self.backingView)
            }
            
            animate {
                self.scale = 1.15
                self.rotation = self.rotation + M_PI_4 / 4
            }
        }
        
        // remember the offset from the touch to our center point.
        let screenLocation = touch.location(in: Canvas.shared.backingView)
        let canvasPoint = Canvas.shared.convertPointFromScreen(screenPoint: screenLocation)
        offsetFromTouchToCenter = Point(x: canvasPoint.x - center.x, y: canvasPoint.y - center.y)
        
        // NOTE (ken orr): consider moving the above into a standard handler.
        
        // notify the handler of the touch-down.
        onTouchDownHandler?()
    }
    
    func touchesMoved(touches: Set<UITouch>, with event: UIEvent) {
        
        guard let touch = touches.first else { return }
        
        let screenLocation = touch.location(in: Canvas.shared.backingView)
        let canvasPoint = Canvas.shared.convertPointFromScreen(screenPoint: screenLocation)
        
        if (draggable) {
            var adjustedPoint = canvasPoint
            adjustedPoint.x = canvasPoint.x - offsetFromTouchToCenter.x
            adjustedPoint.y = canvasPoint.y - offsetFromTouchToCenter.y
            self.center = adjustedPoint
        }
        
        // notify the handler of the dragged touch.
        onTouchDragHandler?()
    }
    
    func touchesEnded(touches: Set<UITouch>, with event: UIEvent) {
        cleanupAfterTouchIfNecessary()
        
        // NOTE (ken orr): consider moving the above into a standard handler.
        
        // notify the handler of the touch-up.
        onTouchUpHandler?()
    }
    
    func touchesCancelled(touches: Set<UITouch>, with event: UIEvent) {
        cleanupAfterTouchIfNecessary()
        
        // notify the handler of the cancelled touch.
        onTouchCancelledHandler?()
    }
    
    func wantsTouch(touch: UITouch) -> Bool {
        // we only want touches if we have a handler.
        return draggable || onTouchDownHandler != nil || onTouchDragHandler != nil || onTouchUpHandler != nil || onTouchCancelledHandler != nil
    }
    
    private func cleanupAfterTouchIfNecessary() {
        guard draggable else { return }
        
        // Reset the scale and rotation when touch is lifted
        animate {
            self.scale = 1.0
            self.rotation = self.rotation - M_PI_4 / 4
        }
    }
}

// MARK: Animation API

// TODO: Expose further parameters with default values.

/// Animates any changes that occur in the `changesToAnimate` block. For example, if you change the `center` of an object in the `changesToAnimate` block, it will animate to its location.
/// 
///    - `duration` The length of the animation in seconds. The default value is 0.35.
///    - `delay` The amount of time in seconds before the animation starts. The default value is 0.0.
///    - `changesToAnimate` The block of code that should be animated.
public func animate(duration: Double = 0.35, delay: Double = 0.0, _ changesToAnimate: () -> Void) {
    UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.beginFromCurrentState, .allowUserInteraction], animations: changesToAnimate, completion:nil)
}

