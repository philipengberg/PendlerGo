//
//  UIView+PendlerGo.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import Foundation
import UIKit

extension UIView {
    internal func addSubviews(subviews : Array <UIView> ) {
        for view in subviews {
            self.addSubview(view)
        }
    }
    
    internal func maxY() -> CGFloat {
        return CGRectGetMaxY(self.frame)
    }
    
    internal func minY() -> CGFloat {
        return CGRectGetMinY(self.frame)
    }
    
    var width:      CGFloat { get { return self.frame.size.width }  set { self.frame.size.width = newValue } }
    var height:     CGFloat { get { return self.frame.size.height } set { self.frame.size.height = newValue } }
    var size:       CGSize  { get { return self.frame.size }        set { self.frame.size = newValue } }
    
    var origin:     CGPoint { get { return self.frame.origin }   set { self.frame.origin = newValue } }
    var x:          CGFloat { get { return self.frame.origin.x } set { self.frame.origin = CGPointMake(newValue, self.frame.origin.y) } }
    var y:          CGFloat { get { return self.frame.origin.y } set { self.frame.origin = CGPointMake(self.frame.origin.x, newValue) } }
    var centerX:    CGFloat { get { return self.center.x }       set { self.center = CGPointMake(newValue, self.center.y) } }
    var centerY:    CGFloat { get { return self.center.y }       set { self.center = CGPointMake(self.center.x, newValue) } }
    
    var left:       CGFloat { get { return self.frame.origin.x }                          set { self.frame.origin.x = newValue } }
    var top:        CGFloat { get { return self.frame.origin.y }                          set { self.frame.origin.y = newValue } }
    var right:      CGFloat { get { return self.frame.origin.x + self.frame.size.width }  set { self.frame.origin.x = newValue - self.frame.size.width } }
    var bottom:     CGFloat { get { return self.frame.origin.y + self.frame.size.height } set { self.frame.origin.y = newValue - self.frame.size.height } }
    
    var boundsCenter:   CGPoint { get { return CGPoint(x: CGRectGetMidX(self.bounds), y: CGRectGetMidY(self.bounds)) } }
    var boundsCenterX:  CGFloat { get { return CGRectGetMidX(self.bounds) } }
    var boundsCenterY:  CGFloat { get { return CGRectGetMidY(self.bounds) } }
}