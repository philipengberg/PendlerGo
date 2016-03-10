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
    let visualEffectView = UIVisualEffectView().setUp {
        $0.contentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let vibrancyView = UIVisualEffectView().setUp {
        $0.contentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let fakeNavBar = UIView()
    let fakeNavBarTitleLabel = UILabel().setUp {
        $0.font = Theme.font.regular(size: .XtraLarge)
        $0.textColor = UIColor.whiteColor()
    }
    
    let fakeNavBarCloseButton = LargeHitAreaButton(type: .System).setUp {
        $0.setTitle("Færdig", forState: .Normal)
        $0.titleLabel!.font = Theme.font.regular(size: .Large)
    }
    
    let containerView = UIView()
    
    let searchResultsTableView = UITableView().setUp {
        $0.backgroundColor = UIColor.clearColor()
    }
    
    let homeImageView = UIImageView().setUp {
        $0.image = UIImage(named: "home")
    }
    
    let spacer1 = UIView()
    let spacer2 = UIView()
    let spacer3 = UIView()
    
    let homeTextField = UITextField().setUp {
        $0.font = Theme.font.medium(size: .XtraLarge)
        $0.textColor = UIColor.whiteColor()
        $0.clearButtonMode = UITextFieldViewMode.WhileEditing
        $0.textAlignment = .Center
        $0.attributedPlaceholder = NSAttributedString(string: "Station hjemme", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.5)])
    }
    
    let homeTextFieldUnderline = UIView().setUp {
        $0.backgroundColor = UIColor.whiteColor()
    }
    
    let workImageView = UIImageView().setUp {
        $0.image = UIImage(named: "work")
    }
    
    let workTextField = UITextField().setUp {
        $0.font = Theme.font.medium(size: .XtraLarge)
        $0.textColor = UIColor.whiteColor()
        $0.clearButtonMode = UITextFieldViewMode.WhileEditing
        $0.textAlignment = .Center
        $0.attributedPlaceholder = NSAttributedString(string: "Station arbejde", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.5)])
    }
    
    let workTextFieldUnderline = UIView().setUp {
        $0.backgroundColor = UIColor.whiteColor()
    }
    
    let textFieldContainerView = UIView()
    
    var bottomInset: CGFloat = 0
    
    private var resultsTableViewHidden = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        
        visualEffectView.effect = visualEffect
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: visualEffect)
        vibrancyView.effect = vibrancyEffect
        
        addSubviews([visualEffectView])
        
        visualEffectView.contentView.addSubviews([vibrancyView])
        vibrancyView.contentView.addSubviews([fakeNavBar, containerView])
        fakeNavBar.addSubviews([fakeNavBarTitleLabel, fakeNavBarCloseButton])
        containerView.addSubviews([textFieldContainerView, searchResultsTableView])
        textFieldContainerView.addSubviews([homeImageView, homeTextField, homeTextFieldUnderline, workImageView, workTextField, workTextFieldUnderline, spacer1, spacer2, spacer3])
        
        setNeedsUpdateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        visualEffectView.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.edges.equalTo(superview)
        }
        
        visualEffectView.contentView.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.edges.equalTo(superview)
        }
        
        vibrancyView.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.edges.equalTo(superview)
        }
        
        vibrancyView.contentView.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.edges.equalTo(superview)
        }
        
        
        
        fakeNavBar.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.left.top.right.equalTo(superview)
            make.height.equalTo(20+44)
        }
        
        fakeNavBarTitleLabel.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.centerX.equalTo(superview)
            make.centerY.equalTo(superview).offset(5)
        }
        
        fakeNavBarCloseButton.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.right.equalTo(-15)
            make.centerY.equalTo(fakeNavBarTitleLabel)
//            make.size.equalTo(15)
        }
        
        
        
        containerView.snp_remakeConstraintsWithSuper({ (make, superview) -> Void in
            make.top.equalTo(fakeNavBar.snp_bottom)
            make.left.right.equalTo(superview)
            make.bottom.equalTo(superview).offset(-bottomInset)
        })
        
        searchResultsTableView.snp_remakeConstraintsWithSuper { (make, superview) -> Void in
            make.left.bottom.right.equalTo(superview)
            if resultsTableViewHidden {
                make.top.equalTo(superview.snp_bottom)
            } else {
                make.top.equalTo(superview.snp_centerY)
            }
        }
        
        textFieldContainerView.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.left.top.right.equalTo(superview)
            make.bottom.equalTo(searchResultsTableView.snp_top)
        }
        
        
        
        spacer1.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(superview)
            make.bottom.equalTo(homeTextField.snp_top)
        }
        
        spacer2.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(homeTextField.snp_bottom)
            make.bottom.equalTo(workTextField.snp_top)
            make.height.equalTo(spacer1)
        }
        
        spacer3.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(workTextField.snp_bottom)
            make.bottom.equalTo(superview)
            make.height.equalTo(spacer2)
        }
        
        
        
        homeImageView.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.bottom.equalTo(homeTextField)
            make.size.equalTo(20)
            make.right.equalTo(homeTextField.snp_left).offset(-10)
        }
        
        homeTextField.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.centerX.equalTo(superview)
            make.height.equalTo(30)
            make.width.equalTo(superview).multipliedBy(0.6)
        }
        
        homeTextFieldUnderline.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.left.right.equalTo(homeTextField)
            make.top.equalTo(homeTextField.snp_bottom)
            make.height.equalTo(0.5)
        }
        
        
        
        workImageView.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.bottom.equalTo(workTextField)
            make.size.equalTo(homeImageView)
            make.right.equalTo(homeImageView)
        }
        
        workTextField.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.centerX.equalTo(homeTextField)
            make.height.equalTo(homeTextField)
            make.width.equalTo(homeTextField)
        }
        
        workTextFieldUnderline.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.left.right.equalTo(workTextField)
            make.top.equalTo(workTextField.snp_bottom)
            make.height.equalTo(homeTextFieldUnderline)
        }
        
        super.updateConstraints()
    }
    
    func hideResults(completion: ((Bool) -> Void)?) {
        resultsTableViewHidden = true
        update(completion)
    }
    
    func showResults(completion: ((Bool) -> Void)?) {
        resultsTableViewHidden = false
        update(completion)
    }
    
    private func update(completion: ((Bool) -> Void)?) {
        
        setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.layoutIfNeeded()
        }, completion: completion)
    }
    
}