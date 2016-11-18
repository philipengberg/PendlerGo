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
    
    public func snp_makeConstraintsWithSuper(_ closure: @escaping (_ make: ConstraintMaker, _ superview: UIView) -> Void) -> Void {
        
        if let s = superview {
            self.snp.makeConstraints { (make) -> Void in
                closure(make, s)
            }
        }
    }
    
    public func snp_remakeConstraintsWithSuper(_ closure: @escaping (_ make: ConstraintMaker, _ superview: UIView) -> Void) -> Void {
        
        if let s = superview {
            self.snp.remakeConstraints { (make) -> Void in
                closure(make, s)
            }
        }
    }
    
    public func snp_updateConstraintsWithSuper(_ closure: @escaping (_ make: ConstraintMaker, _ superview: UIView) -> Void) -> Void {
        
        if let s = superview {
            self.snp.updateConstraints { (make) -> Void in
                closure(make, s)
            }
        }
    }
    
}
