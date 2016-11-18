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
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let errorMargin: CGFloat = 15;
        let largerFrame = CGRect(x: 0 - errorMargin, y: 0 - errorMargin, width: self.frame.size.width + errorMargin * 2, height: self.frame.size.height + errorMargin * 2);
        
        if !self.isHidden && largerFrame.contains(point) {
            return self;
        }
        
        return nil;
    }
    
}
