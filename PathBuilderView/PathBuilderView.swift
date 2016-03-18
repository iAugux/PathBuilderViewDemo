//
//  PathBuilderView.swift
//  PathBuilderViewDemo
//
//  Created by Augus on 3/18/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import UIKit

class PathBuilderView: UIView {
    
    private(set) var pathShapeView: ShapeView!
    private(set) var prospectivePathShapeView: ShapeView!
    private(set) var pointsShapeView: ShapeView!
    
    private let kDistanceThreshold: CGFloat = 10.0
    private let kPointDiameter: CGFloat = 7.0

    private var points: NSMutableArray!
    private var prospectivePointValue: NSValue!
    private var indexOfSelectedPoint: NSInteger!
    private var touchOffsetForSelectedPoint: CGVector!
    private var pressTimer: NSTimer!
    private var ignoreTouchEvents = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        points = NSMutableArray()
        multipleTouchEnabled = false
        indexOfSelectedPoint = NSNotFound
        pathShapeView = ShapeView()
        pathShapeView.shapeLayer.fillColor = nil
        pathShapeView.backgroundColor = UIColor.clearColor()
        pathShapeView.opaque = false
        pathShapeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pathShapeView)
        
        prospectivePathShapeView = ShapeView()
        prospectivePathShapeView.shapeLayer.fillColor = nil
        prospectivePathShapeView.backgroundColor = UIColor.clearColor()
        prospectivePathShapeView.opaque = false
        prospectivePathShapeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(prospectivePathShapeView)
        
        pointsShapeView = ShapeView()
        pointsShapeView.backgroundColor = UIColor.clearColor()
        pointsShapeView.opaque = false
        pointsShapeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pointsShapeView)
        
        let views: [String : AnyObject] = ["pathShapeView" : pathShapeView, "prospectivePathShapeView" : prospectivePathShapeView, "pointsShapeView" : pointsShapeView]
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[pathShapeView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[prospectivePathShapeView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[pointsShapeView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[pathShapeView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[prospectivePathShapeView]|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[pointsShapeView]|", options: [], metrics: nil, views: views))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        pointsShapeView.shapeLayer.fillColor = tintColor.CGColor
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard !ignoreTouchEvents else { return }
        
        let pointValue: NSValue = pointValueWithTouches(touches)
        
        let indexes: NSIndexSet = points.indexesOfObjectsPassingTest { (existingPointValue, idx, stop) -> Bool in
            let point: CGPoint = pointValue.CGPointValue()
            let existingPoint: CGPoint = existingPointValue.CGPointValue
            let distance: CGFloat = abs(point.x - existingPoint.x) + abs(point.y - existingPoint.y)
            return distance < self.kDistanceThreshold
        }
        
        if indexes.count > 0 {
            indexOfSelectedPoint = indexes.lastIndex
            let existingPointValue: NSValue = points[indexOfSelectedPoint] as! NSValue
            let point: CGPoint = pointValue.CGPointValue()
            let existingPoint: CGPoint = existingPointValue.CGPointValue()
            touchOffsetForSelectedPoint = CGVectorMake(point.x - existingPoint.x, point.y - existingPoint.y)
            pressTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "pressTimerFired:", userInfo: nil, repeats: false)
        }
        else {
            prospectivePointValue = pointValue
        }
        updatePaths()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard !ignoreTouchEvents else { return }
        
        pressTimer?.invalidate()
        pressTimer = nil
        let pointValue: NSValue = pointValueWithTouches(touches)
        if indexOfSelectedPoint != NSNotFound {
            let offsetPointValue: NSValue = pointValueByRemovingOffset(touchOffsetForSelectedPoint, fromPointValue: pointValue)
            points[indexOfSelectedPoint] = offsetPointValue
        }
        else {
            prospectivePointValue = pointValue
        }
        updatePaths()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        guard !ignoreTouchEvents  else {
            ignoreTouchEvents = false
            return
        }
        
        pressTimer?.invalidate()
        pressTimer = nil
        indexOfSelectedPoint = NSNotFound
        prospectivePointValue = nil
        updatePaths()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard !ignoreTouchEvents else {
            ignoreTouchEvents = false
            return
        }
        
        pressTimer?.invalidate()
        pressTimer = nil
        let pointValue: NSValue = pointValueWithTouches(touches)
        if indexOfSelectedPoint != NSNotFound {
            let offsetPointValue: NSValue = pointValueByRemovingOffset(touchOffsetForSelectedPoint, fromPointValue: pointValue)
            points[indexOfSelectedPoint] = offsetPointValue
            indexOfSelectedPoint = NSNotFound
        }
        else {
            points.addObject(pointValue)
            prospectivePointValue = nil
        }
        updatePaths()
    }
    
    // MARK: -  Action Methods
    internal func pressTimerFired(timer: NSTimer) {
        pressTimer?.invalidate()
        pressTimer = nil
        points.removeObjectAtIndex(indexOfSelectedPoint)
        indexOfSelectedPoint = NSNotFound
        ignoreTouchEvents = true
        updatePaths()
    }
    
    // MARK: - Helper Methods
    private func updatePaths() {
        
        let _ = {
            let path: UIBezierPath = UIBezierPath()
            for pointValue in points {
                let point: CGPoint = pointValue.CGPointValue
                path.appendPath(UIBezierPath(arcCenter: point, radius: kPointDiameter / 2.0, startAngle: 0.0, endAngle: CGFloat(2 * M_PI), clockwise: true))
            }
            pointsShapeView.shapeLayer.path = path.CGPath
        }()
        
        if points.count >= 2 {
            let path: UIBezierPath = UIBezierPath()
            path.moveToPoint(points.firstObject!.CGPointValue)
            let indexSet = NSIndexSet(indexesInRange: NSMakeRange(1, points.count - 1))
            
            points.enumerateObjectsAtIndexes(indexSet, options: NSEnumerationOptions(rawValue: 0), usingBlock: { (pointValue, idx, stop) -> Void in
                path.addLineToPoint(pointValue.CGPointValue)
            })
            pathShapeView.shapeLayer.path = path.CGPath
        }
        else {
            pathShapeView.shapeLayer.path = nil
        }
        if points.count >= 1 && prospectivePointValue != nil {
            let path: UIBezierPath = UIBezierPath()
            path.moveToPoint(points.lastObject!.CGPointValue)
            path.addLineToPoint(prospectivePointValue.CGPointValue())
            prospectivePathShapeView.shapeLayer.path = path.CGPath
        }
        else {
            prospectivePathShapeView.shapeLayer.path = nil
        }
    }
    
    func pointValueWithTouches(touches: Set<UITouch>) -> NSValue {
        let touch: UITouch = touches.first!
        let point: CGPoint = touch.locationInView(self)
        return NSValue(CGPoint: point)
    }
    
    func pointValueByRemovingOffset(offset: CGVector, fromPointValue pointValue: NSValue) -> NSValue {
        let point: CGPoint = pointValue.CGPointValue()
        let offsetPoint: CGPoint = CGPointMake(point.x - offset.dx, point.y - offset.dy)
        return NSValue(CGPoint: offsetPoint)
    }
}