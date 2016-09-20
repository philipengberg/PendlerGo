//
//  BoardContainmentFilterView.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/09/16.
//
//

import Foundation

class BoardContainmentFilterView: UIView {
    
    private let containerView = UIView()
    
    let trainsButton = LargeHitAreaButton(type: .Custom).setUp {
        $0.setImage(UIImage(named: "train"), forState: .Selected)
        $0.setImage(UIImage(named: "train-off"), forState: .Normal)
        $0.tintColor = UIColor.whiteColor()
        $0.imageView?.contentMode = .ScaleAspectFit
        $0.selected = true
    }
    
    let sTrainsButton = LargeHitAreaButton(type: .Custom).setUp {
        $0.setImage(UIImage(named: "s-train"), forState: .Selected)
        $0.setImage(UIImage(named: "s-train-off"), forState: .Normal)
        $0.tintColor = UIColor.whiteColor()
        $0.imageView?.contentMode = .ScaleAspectFit
        $0.selected = true
    }
    
    let metroButton = LargeHitAreaButton(type: .Custom).setUp {
        $0.setImage(UIImage(named: "metro"), forState: .Selected)
        $0.setImage(UIImage(named: "metro-off"), forState: .Normal)
        $0.tintColor = UIColor.whiteColor()
        $0.imageView?.contentMode = .ScaleAspectFit
        $0.selected = true
    }
    
    let tapGesture = UITapGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(containerView)
        containerView.addSubviews([trainsButton, sTrainsButton, metroButton])
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 3.0
        
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        containerView.snp_updateConstraintsWithSuper { (make, superview) in
            make.centerX.equalTo(superview)
            make.centerY.equalTo(superview).offset(5)
            make.height.equalTo(superview).offset(-10)
        }
        
        trainsButton.snp_updateConstraintsWithSuper { (make, superview) in
            make.height.equalTo(superview)
            make.top.equalTo(superview)
            make.left.equalTo(superview)
            make.width.equalTo(35)
        }
        
        sTrainsButton.snp_updateConstraintsWithSuper { (make, superview) in
            make.height.equalTo(superview)
            make.top.equalTo(superview)
            make.left.equalTo(trainsButton.snp_right).offset(40)
            make.width.equalTo(35)
        }
        
        metroButton.snp_updateConstraintsWithSuper { (make, superview) in
            make.height.equalTo(superview)
            make.top.equalTo(superview)
            make.left.equalTo(sTrainsButton.snp_right).offset(40)
            make.width.equalTo(35)
            make.right.equalTo(superview)
        }
        
        super.updateConstraints()
    }
    
}

extension BoardContainmentFilterView : UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let errorMargin: CGFloat = 15;
        
        let rect = CGRect(x: gestureRecognizer.locationInView(self).x - errorMargin / 2, y: gestureRecognizer.locationInView(self).y - errorMargin / 2, width: errorMargin, height: errorMargin)
        
        if CGRectIntersectsRect(rect, trainsButton.convertRect(trainsButton.frame, toView: self)) {
            return false
        }
        
        if CGRectIntersectsRect(rect, sTrainsButton.convertRect(sTrainsButton.frame, toView: self)) {
            return false
        }
        
        if CGRectIntersectsRect(rect, metroButton.convertRect(metroButton.frame, toView: self)) {
            return false
        }
        
        return true
    }
}