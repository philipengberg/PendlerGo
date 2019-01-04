//
//  BoardContainmentFilterView.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/09/16.
//
//

import Foundation
import UIKit

class BoardContainmentFilterView: UIView {
    
    fileprivate let containerView = UIView()
    
    let trainsButton = LargeHitAreaButton(type: .custom).setUp {
        $0.setImage(UIImage(named: "train"), for: .selected)
        $0.setImage(UIImage(named: "train-off"), for: UIControl.State())
        $0.tintColor = UIColor.white
        $0.imageView?.contentMode = .scaleAspectFit
        $0.isSelected = true
    }
    
    let sTrainsButton = LargeHitAreaButton(type: .custom).setUp {
        $0.setImage(UIImage(named: "s-train"), for: .selected)
        $0.setImage(UIImage(named: "s-train-off"), for: UIControl.State())
        $0.tintColor = UIColor.white
        $0.imageView?.contentMode = .scaleAspectFit
        $0.isSelected = true
    }
    
    let metroButton = LargeHitAreaButton(type: .custom).setUp {
        $0.setImage(UIImage(named: "metro"), for: .selected)
        $0.setImage(UIImage(named: "metro-off"), for: UIControl.State())
        $0.tintColor = UIColor.white
        $0.imageView?.contentMode = .scaleAspectFit
        $0.isSelected = true
    }
    
    let tapGesture = UITapGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(containerView)
        containerView.addSubviews([trainsButton, sTrainsButton, metroButton])
        
        layer.shadowColor = UIColor.black.cgColor
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
        
        containerView.snp.updateConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(5)
            make.height.equalToSuperview().offset(-10)
        }
        
        trainsButton.snp.updateConstraints { make in
            make.height.equalToSuperview()
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalTo(35)
        }
        
        sTrainsButton.snp.updateConstraints { make in
            make.height.equalToSuperview()
            make.top.equalToSuperview()
            make.left.equalTo(trainsButton.snp.right).offset(40)
            make.width.equalTo(35)
        }
        
        metroButton.snp.updateConstraints { make in
            make.height.equalToSuperview()
            make.top.equalToSuperview()
            make.left.equalTo(sTrainsButton.snp.right).offset(40)
            make.width.equalTo(35)
            make.right.equalToSuperview()
        }
        
        super.updateConstraints()
    }
    
}

extension BoardContainmentFilterView : UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let errorMargin: CGFloat = 15;
        
        let rect = CGRect(x: gestureRecognizer.location(in: self).x - errorMargin / 2, y: gestureRecognizer.location(in: self).y - errorMargin / 2, width: errorMargin, height: errorMargin)
        
        if rect.intersects(trainsButton.convert(trainsButton.frame, to: self)) {
            return false
        }
        
        if rect.intersects(sTrainsButton.convert(sTrainsButton.frame, to: self)) {
            return false
        }
        
        if rect.intersects(metroButton.convert(metroButton.frame, to: self)) {
            return false
        }
        
        return true
    }
}
