//
//  SnapKit+Superview.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import Foundation
import SnapKit

extension UIView {
    
    public func snp_makeConstraintsWithSuper(@noescape closure: (make: ConstraintMaker, superview: UIView) -> Void) -> Void {
        
        if let s = superview {
            self.snp_makeConstraints { (make) -> Void in
                closure(make: make, superview: s)
            }
        }
    }
    
    public func snp_remakeConstraintsWithSuper(@noescape closure: (make: ConstraintMaker, superview: UIView) -> Void) -> Void {
        
        if let s = superview {
            self.snp_remakeConstraints { (make) -> Void in
                closure(make: make, superview: s)
            }
        }
    }
    
    public func snp_updateConstraintsWithSuper(@noescape closure: (make: ConstraintMaker, superview: UIView) -> Void) -> Void {
        
        if let s = superview {
            self.snp_updateConstraints { (make) -> Void in
                closure(make: make, superview: s)
            }
        }
    }
    
}
