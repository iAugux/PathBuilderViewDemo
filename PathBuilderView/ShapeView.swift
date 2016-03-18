//
//  ShapeView.swift
//  PathBuilderViewDemo
//
//  Created by Augus on 3/18/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import UIKit


class ShapeView: UIView {
    
    var shapeLayer: CAShapeLayer {
        return self.layer as! CAShapeLayer
    }
    
    override class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }
    
}