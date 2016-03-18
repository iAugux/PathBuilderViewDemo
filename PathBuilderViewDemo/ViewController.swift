//
//  ViewController.swift
//  PathBuilderViewDemo
//
//  Created by Augus on 3/18/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import UIKit


let kDuration: CFTimeInterval = 2.0

let kInitialTimeOffset: CFTimeInterval = 2.0

class ViewController: UIViewController {
    
    private var pathBuilderView: PathBuilderView {
        get {
            return view as! PathBuilderView
        }
    }
    
    override func loadView() {
        view = PathBuilderView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        pathBuilderView.pathShapeView.shapeLayer.strokeColor = UIColor.blackColor().CGColor
        pathBuilderView.prospectivePathShapeView.shapeLayer.strokeColor = UIColor.grayColor().CGColor
        pathBuilderView.pointsShapeView.shapeLayer.strokeColor = UIColor.blackColor().CGColor
        let animation: CABasicAnimation = CABasicAnimation(keyPath: NSStringFromSelector("strokeEnd"))
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.removedOnCompletion = false
        animation.duration = kDuration
        pathBuilderView.pathShapeView.shapeLayer.addAnimation(animation, forKey: NSStringFromSelector("strokeEnd"))
        pathBuilderView.pathShapeView.shapeLayer.speed = 0
        pathBuilderView.pathShapeView.shapeLayer.timeOffset = 0.0
        CATransaction.flush()
        pathBuilderView.pathShapeView.shapeLayer.timeOffset = kInitialTimeOffset
        
        
        let showDotsSwitch: UISwitch = UISwitch()
        showDotsSwitch.on = true
        showDotsSwitch.addTarget(self, action: "showDotsSwitchValueChanged:", forControlEvents: .ValueChanged)
        showDotsSwitch.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(showDotsSwitch)
        let showDotsLabel: UILabel = UILabel()
        showDotsLabel.text = "Show dots"
        showDotsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(showDotsLabel)
        
        let strokeEndSlider: UISlider = UISlider()
        strokeEndSlider.minimumValue = 0.0
        strokeEndSlider.maximumValue = Float(kDuration)
        strokeEndSlider.value = Float(kInitialTimeOffset)
        strokeEndSlider.continuous = true
        strokeEndSlider.addTarget(self, action: "strokeEndSliderValueChanged:", forControlEvents: .ValueChanged)
        strokeEndSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(strokeEndSlider)
        
        let drawPathButton: UIButton = UIButton(type: .System)
        drawPathButton.setTitle("Draw Path", forState: .Normal)
        drawPathButton.addTarget(self, action: "drawPathButtonTapped", forControlEvents: .TouchUpInside)
        drawPathButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(drawPathButton)
        
        
        var views: [String : AnyObject] = ["showDotsLabel" : showDotsLabel, "showDotsSwitch" : showDotsSwitch, "drawPathButton" : drawPathButton]
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[showDotsLabel]-[showDotsSwitch]->=20-[drawPathButton]-|", options: .AlignAllCenterY, metrics: nil, views: views))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[showDotsSwitch]-|", options: [], metrics: nil, views: views))
        let topLayoutGuide: AnyObject = self.topLayoutGuide
        views = ["strokeEndSlider" :strokeEndSlider, "topLayoutGuide" :topLayoutGuide]
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[strokeEndSlider]-|", options: .AlignAllCenterY, metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topLayoutGuide][strokeEndSlider]", options: [], metrics: nil, views: views))
    }
    
    internal func showDotsSwitchValueChanged(showDotsSwitch: UISwitch) {
        UIView.animateWithDuration(0.15, delay: 0.0, options: .BeginFromCurrentState, animations: {() -> Void in
            self.pathBuilderView.pointsShapeView.alpha = showDotsSwitch.on ? 1.0 : 0.0
            }, completion: { _ in })
    }
    
    internal func strokeEndSliderValueChanged(strokeEndSlider: UISlider) {
        pathBuilderView.pathShapeView.shapeLayer.timeOffset = CFTimeInterval(strokeEndSlider.value)
    }
    
    internal func drawPathButtonTapped() {
        let timeOffset: CFTimeInterval = pathBuilderView.pathShapeView.shapeLayer.timeOffset
        
        CATransaction.setCompletionBlock {() -> Void in
            let animation: CABasicAnimation = CABasicAnimation(keyPath: NSStringFromSelector("strokeEnd"))
            animation.fromValue = 0.0
            animation.toValue = 1.0
            animation.removedOnCompletion = false
            animation.duration = kDuration
            self.pathBuilderView.pathShapeView.shapeLayer.speed = 0
            self.pathBuilderView.pathShapeView.shapeLayer.timeOffset = 0
            self.pathBuilderView.pathShapeView.shapeLayer.addAnimation(animation, forKey: NSStringFromSelector("strokeEnd"))
            CATransaction.flush()
            self.pathBuilderView.pathShapeView.shapeLayer.timeOffset = timeOffset
        }
        pathBuilderView.pathShapeView.shapeLayer.timeOffset = 0.0
        pathBuilderView.pathShapeView.shapeLayer.speed = 1.0
        let animation: CABasicAnimation = CABasicAnimation(keyPath: NSStringFromSelector("strokeEnd"))
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = kDuration
        pathBuilderView.pathShapeView.shapeLayer.addAnimation(animation, forKey: NSStringFromSelector("strokeEnd"))
    }
}