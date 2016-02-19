//
//  SettingsView.swift
//  PendlerGo
//
//  Created by Philip Engberg on 19/02/16.
//
//

import Foundation
import UIKit

class SettingsView: UIView {
    
    let visualEffect = UIBlurEffect(style: .Dark)
    let visualEffectView = UIVisualEffectView()
    let vibrancyView = UIVisualEffectView()
    
    let searchResultsTableView = UITableView().setUp {
        $0.backgroundColor = UIColor.clearColor()
    }
    
    let homeTextField = UITextField().setUp {
        $0.font = Theme.font.medium(size: .XtraLarge)
        $0.textColor = UIColor.whiteColor()
        $0.clearButtonMode = UITextFieldViewMode.WhileEditing
        $0.textAlignment = .Center
    }
    
    private var resultsTableViewHidden = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        
        visualEffectView.effect = visualEffect
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: visualEffect)
        vibrancyView.effect = vibrancyEffect
        
        addSubviews([visualEffectView])
        
        visualEffectView.contentView.addSubviews([vibrancyView])
        vibrancyView.contentView.addSubviews([homeTextField, searchResultsTableView])
        
        setNeedsUpdateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        visualEffectView.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.edges.equalTo(superview)
        }
        
        vibrancyView.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.edges.equalTo(superview)
        }
        
        homeTextField.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.centerX.equalTo(superview)
            make.height.equalTo(50)
            make.width.equalTo(superview).multipliedBy(0.6)
            make.centerY.equalTo(superview).dividedBy(2)
        }
        
        searchResultsTableView.snp_remakeConstraintsWithSuper { (make, superview) -> Void in
            make.left.bottom.right.equalTo(superview)
            if resultsTableViewHidden {
                make.top.equalTo(superview.snp_bottom)
            } else {
                make.top.equalTo(superview.snp_centerY)
            }
        }
        
        super.updateConstraints()
    }
    
    func hideResults() {
        resultsTableViewHidden = true
        update()
    }
    
    func showResults() {
        resultsTableViewHidden = false
        update()
    }
    
    private func update() {
        
        setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
}