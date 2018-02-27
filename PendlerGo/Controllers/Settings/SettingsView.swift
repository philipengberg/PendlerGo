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
    
    let visualEffect = UIBlurEffect(style: .dark)
    let visualEffectView = UIVisualEffectView().setUp {
        $0.contentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let vibrancyView = UIVisualEffectView().setUp {
        $0.contentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let fakeNavBar = UIView()
    let fakeNavBarTitleLabel = UILabel().setUp {
        $0.font = Theme.font.regular(size: .xtraXtraLarge)
        $0.textColor = UIColor.white
    }
    
    var fakeNavBarCloseButton = LargeHitAreaButton(type: .system).setUp {
        $0.setTitle("OK", for: UIControlState())
        $0.titleLabel!.font = Theme.font.regular(size: .large)
    }
    
    let fakeNavBarFeedbackButton = LargeHitAreaButton(type: .system).setUp {
        $0.setTitle("Hjælp", for: UIControlState())
        $0.titleLabel!.font = Theme.font.regular(size: .large)
    }
    
    let containerView = UIView()
    let searchResultsTableView = UITableView().setUp {
        $0.backgroundColor = UIColor.clear
    }
    
    let homeImageView = UIImageView().setUp {
        $0.image = UIImage(named: "home")
    }
    
    let spacer1 = UIView()
    let spacer2 = UIView()
    let spacer3 = UIView()
    
    let homeTextField = UITextField().setUp {
        $0.font = Theme.font.medium(size: .xtraLarge)
        $0.textColor = UIColor.white
        $0.clearButtonMode = .unlessEditing
        $0.textAlignment = .center
        $0.attributedPlaceholder = NSAttributedString(string: "Station hjemme", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
    }
    
    let homeTextFieldMagnifier = UIImageView(image: UIImage(named: "search")).setUp {
        $0.alpha = 0.5
    }
    
    let homeTextFieldUnderline = UIView().setUp {
        $0.backgroundColor = UIColor.white
    }
    
    let workImageView = UIImageView().setUp {
        $0.image = UIImage(named: "work")
    }
    
    let workTextField = UITextField().setUp {
        $0.font = Theme.font.medium(size: .xtraLarge)
        $0.textColor = UIColor.white
        $0.clearButtonMode = .unlessEditing
        $0.textAlignment = .center
        $0.attributedPlaceholder = NSAttributedString(string: "Station arbejde", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
    }
    
    let workTextFieldMagnifier = UIImageView(image: UIImage(named: "search")).setUp {
        $0.alpha = 0.5
    }
    
    let workTextFieldUnderline = UIView().setUp {
        $0.backgroundColor = UIColor.white
    }
    
    let textFieldContainerView = UIView()
    
    var bottomInset: CGFloat = 0
    
    fileprivate var resultsTableViewHidden = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        
        visualEffectView.effect = visualEffect
        let vibrancyEffect = UIVibrancyEffect(blurEffect: visualEffect)
        vibrancyView.effect = vibrancyEffect
        
        addSubviews([visualEffectView])
        
        visualEffectView.contentView.addSubviews([vibrancyView])
        vibrancyView.contentView.addSubviews([fakeNavBar, containerView])
        fakeNavBar.addSubviews([fakeNavBarTitleLabel, fakeNavBarFeedbackButton, fakeNavBarCloseButton])
        containerView.addSubviews([textFieldContainerView, searchResultsTableView])
        textFieldContainerView.addSubviews([homeImageView, homeTextField, homeTextFieldUnderline, workImageView, workTextField, workTextFieldUnderline, spacer1, spacer2, spacer3])
        

        homeTextField.rightView = homeTextFieldMagnifier
        homeTextField.rightViewMode = .whileEditing
        
        workTextField.rightView = workTextFieldMagnifier
        workTextField.rightViewMode = .whileEditing
        
        setNeedsUpdateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        visualEffectView.snp.updateConstraints { make in
            make.edges.equalToSuperview()
        }
        
        visualEffectView.contentView.snp.updateConstraints { make in
            make.edges.equalToSuperview()
        }
        
        vibrancyView.snp.updateConstraints { make in
            make.edges.equalToSuperview()
        }
        
        vibrancyView.contentView.snp.updateConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        
        fakeNavBar.snp.updateConstraints { make in
            make.left.right.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview()
            }
            make.height.equalTo(20+44)
        }
        
        fakeNavBarTitleLabel.snp.updateConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(5)
        }
        
        fakeNavBarCloseButton.snp.updateConstraints { make in
            make.right.equalTo(-15)
            make.lastBaseline.equalTo(fakeNavBarTitleLabel)
        }
        
        fakeNavBarFeedbackButton.snp.updateConstraints { make in
            make.lastBaseline.equalTo(fakeNavBarTitleLabel)
            make.left.equalTo(15)
        }
        
        
        
        containerView.snp.remakeConstraints { make in
            make.top.equalTo(fakeNavBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-bottomInset)
        }
        
        searchResultsTableView.snp.remakeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            if resultsTableViewHidden {
                make.top.equalTo(searchResultsTableView.superview!.snp.bottom)
            } else {
                make.top.equalTo(searchResultsTableView.superview!.snp.centerY)
            }
        }
        
        textFieldContainerView.snp.updateConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(searchResultsTableView.snp.top)
        }
        
        
        
        spacer1.snp.updateConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(homeTextField.snp.top)
        }
        
        spacer2.snp.updateConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(homeTextField.snp.bottom)
            make.bottom.equalTo(workTextField.snp.top)
            make.height.equalTo(spacer1)
        }
        
        spacer3.snp.updateConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(workTextField.snp.bottom)
            make.bottom.equalToSuperview()
            make.height.equalTo(spacer2)
        }
        
        
        
        homeImageView.snp.updateConstraints { make in
            make.bottom.equalTo(homeTextField)
            make.size.equalTo(20)
            make.right.equalTo(homeTextField.snp.left).offset(-10)
        }
        
        homeTextField.snp.updateConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalToSuperview().multipliedBy(0.6)
        }
        
        homeTextFieldUnderline.snp.updateConstraints { make in
            make.left.right.equalTo(homeTextField)
            make.top.equalTo(homeTextField.snp.bottom)
            make.height.equalTo(0.5)
        }
        
        
        
        workImageView.snp.updateConstraints { make in
            make.bottom.equalTo(workTextField)
            make.size.equalTo(homeImageView)
            make.right.equalTo(homeImageView)
        }
        
        workTextField.snp.updateConstraints { make in
            make.centerX.equalTo(homeTextField)
            make.height.equalTo(homeTextField)
            make.width.equalTo(homeTextField)
        }
        
        workTextFieldUnderline.snp.updateConstraints { make in
            make.left.right.equalTo(workTextField)
            make.top.equalTo(workTextField.snp.bottom)
            make.height.equalTo(homeTextFieldUnderline)
        }
        
        super.updateConstraints()
    }
    
    func hideResults(_ completion: ((Bool) -> Void)?) {
        resultsTableViewHidden = true
        update(completion)
    }
    
    func showResults(_ completion: ((Bool) -> Void)?) {
        resultsTableViewHidden = false
        update(completion)
    }
    
    fileprivate func update(_ completion: ((Bool) -> Void)?) {
        
        setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: UIViewAnimationOptions.beginFromCurrentState, animations: { () -> Void in
            self.layoutIfNeeded()
        }, completion: completion)
    }
    
}
