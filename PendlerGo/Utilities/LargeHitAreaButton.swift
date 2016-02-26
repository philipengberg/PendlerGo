//
//  LargeHitAreaButton.swift
//  PendlerGo
//
//  Created by Philip Engberg on 20/02/16.
//
//

import Foundation
import UIKit

class LargeHitAreaButton: UIButton {
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let errorMargin: CGFloat = 15;
        let largerFrame = CGRectMake(0 - errorMargin, 0 - errorMargin, self.frame.size.width + errorMargin * 2, self.frame.size.height + errorMargin * 2);
        
        if !self.hidden && CGRectContainsPoint(largerFrame, point) {
            return self;
        }
        
        return nil;
    }
    
}