//
//  VFSwitch.swift
//  VFSwitch
//
//  Created by Faceless Void on 14/6/17.
//  Copyright (c) 2014年 VoidFaceless. All rights reserved.
//

import Cocoa
import QuartzCore

class VFSwitch : NSControl {
    let kAnimationDuration = 0.4
    let kBorderLineWidth:CGFloat = 1.0
    let kGoldenRatio:CGFloat = 1.6180339875
    let kDecreasedGoldenRatio:CGFloat = 1.38
    let kEnabledOpacity:Float = 1.0
    let kDisabledOpacity:Float = 0.5
    let kKnobBackgroundColor = NSColor(calibratedWhite:1.0, alpha: 1.0)
    let kDisabledBorderColor = NSColor(calibratedWhite: 0.0, alpha: 0.2)
    let kDisabledBackgroundColor = NSColor.clearColor()
    let kDefaultTintColor = NSColor(calibratedRed:0.27, green: 0.86, blue: 0.36, alpha: 1.0)
    let kInactiveBackgroundColor = NSColor(calibratedWhite: 0.0, alpha:0.3)

    // gets or sets the switches state
    var isOn:Bool = true

    // gets or sets the switches tint
    var tintColor: NSColor = NSColor.shadowColor()

    // gets or sets the switch is disabled
    var enaled:Bool = true


    var isActive:Bool = false
    var hasDragged:Bool  = false
    var isDraggingTowardsOn:Bool = false

    var rootLayer:CALayer?
    var backgroundLayer:CALayer?
    var knobLayer: CALayer?
    var knobInsideLayer: CALayer?

    init(coder:NSCoder) {
        super.init(coder: coder)

        setup()
    }

    init(frame:NSRect) {
        super.init(frame: frame);

        setup()
    }

    func setup() {
        enabled = true

        setupLayers()
    }

    func setupLayers() {
        rootLayer = CALayer()
        layer = rootLayer

        wantsLayer = true

        backgroundLayer = CALayer()
        backgroundLayer!.autoresizingMask = CAAutoresizingMask.LayerWidthSizable | CAAutoresizingMask.LayerHeightSizable;
        backgroundLayer!.bounds = rootLayer!.bounds
        backgroundLayer!.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        backgroundLayer!.borderWidth = kBorderLineWidth

        rootLayer!.addSublayer(backgroundLayer)

        knobLayer = CALayer()
        knobLayer!.frame = rectForKnob()
        knobLayer!.autoresizingMask = CAAutoresizingMask.LayerHeightSizable
        knobLayer!.backgroundColor = kKnobBackgroundColor.CGColor
        knobLayer!.shadowColor = NSColor.blackColor().CGColor
        knobLayer!.shadowOffset = CGSize(width:0.0, height:-2.0)
        knobLayer!.shadowRadius = 1.0
        knobLayer!.shadowOpacity = 0.3
        rootLayer!.addSublayer(knobLayer)

        knobInsideLayer = CALayer()
        knobInsideLayer!.frame = knobLayer!.bounds
        knobInsideLayer!.autoresizingMask = CAAutoresizingMask.LayerHeightSizable | CAAutoresizingMask.LayerWidthSizable

        knobInsideLayer!.shadowColor = NSColor.blackColor().CGColor
        knobInsideLayer!.shadowOffset = CGSize(width:0.0, height:0.0)
        knobInsideLayer!.shadowRadius = 1.0
        knobInsideLayer!.shadowOpacity = 0.35
        knobLayer!.addSublayer(knobInsideLayer)

        reloadLayerSize()
        reloadLayer()
    }

    func reloadLayerSize() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        knobLayer!.frame = rectForKnob()
        knobInsideLayer!.frame = knobLayer!.bounds

        backgroundLayer!.cornerRadius = backgroundLayer!.bounds.size.height / 2.0
        knobLayer!.cornerRadius = knobLayer!.bounds.size.height / 2.0
        knobInsideLayer!.cornerRadius = knobLayer!.bounds.size.height / 2.0

        CATransaction.commit()
    }

    func reloadLayer() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(kAnimationDuration)

        if (hasDragged && isDraggingTowardsOn) || (!hasDragged && isOn) {
            backgroundLayer!.borderColor = tintColor.CGColor
            backgroundLayer!.backgroundColor = tintColor.CGColor
        }
        else {
            backgroundLayer!.borderColor = kDisabledBorderColor.CGColor
            backgroundLayer!.backgroundColor = kDisabledBackgroundColor.CGColor
        }

        if enabled {
            rootLayer!.opacity = kEnabledOpacity
        }
        else {
            rootLayer!.opacity = kDisabledOpacity
        }

        if hasDragged {
            var function = CAMediaTimingFunction(controlPoints: 0.25, 1.5, 0.5, 1)
            CATransaction.setAnimationTimingFunction(function)
        }

        knobLayer!.frame = rectForKnob()
        knobInsideLayer!.frame = knobLayer!.bounds

        CATransaction.commit()
    }

    func knobHeightForSize(size:NSSize) -> CGFloat {
        return size.height - kBorderLineWidth * 2.0;
    }

    func rectForKnob()->CGRect {
        var height = knobHeightForSize(backgroundLayer!.bounds.size)
        var width = 0.0

        var bounds: CGRect = backgroundLayer!.bounds

        if  isActive {
            width = (bounds.width - 2.0 * kBorderLineWidth) / kGoldenRatio
        }
        else {
            width = (bounds.width - 2.0 * kBorderLineWidth) / kDecreasedGoldenRatio
        }

        var x:CGFloat = 0
        if (!hasDragged && !isOn) || (hasDragged && !isDraggingTowardsOn) {
            x = kBorderLineWidth
        }
        else {
            x = bounds.width - width - kBorderLineWidth
        }

        return CGRect(x: x, y: kBorderLineWidth, width: width, height: height)
    }

    override func setFrameSize(newSize: NSSize) {
        super.setFrameSize(newSize)

        reloadLayerSize()
    }

    override func acceptsFirstMouse(theEvent: NSEvent!) -> Bool {
        return true
    }

    func acceptsFirstResponder() -> Bool {
        return true
    }

    override func mouseDown(theEvent: NSEvent!) {
        if !enabled {
            return
        }

        isActive = true
        reloadLayer()
    }

    override func mouseDragged(theEvent: NSEvent!) {
        if !enabled {
            return
        }

        hasDragged = true

        var draggingPoint = convertPoint(theEvent.locationInWindow, fromView: nil)
        isDraggingTowardsOn = draggingPoint.x > bounds.width  / 2.0
        reloadLayer()
    }

    override func mouseUp(theEvent: NSEvent!) {
        if !enabled {
            return
        }

        var on = isOn
        isActive = false
        if hasDragged {
            on = isDraggingTowardsOn
        }
        else {
            on = !isOn
        }

        if isOn != on {
            //invokeTargetAction()
        }

        isOn = on

        hasDragged = false
        isDraggingTowardsOn = false

        reloadLayer()
    }
    /*
    func invokeTargetAction() {
    var sign = target!.class.instanceMethodSignatureForSelector(action)
    var invocation = NSInvocation.invocationWithMethodSignature(sign)
    
    invocation.target = target
    invocation.selector = self.action
    invocation.setArgument(self, atIndex:2)
    
    invocation.invoke()
    }
    */
}
