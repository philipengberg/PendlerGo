//
//  IconTabViewButton.swift
//  Tonsser
//
//  Created by Philip Engberg on 14/01/16.
//  Copyright © 2016 tonsser. All rights reserved.
//

import Foundation
import UIKit

class IconTabViewButton: UIButton {
    
    let iconImageView = UIImageView().setUp {
        $0.contentMode = .ScaleAspectFit
    }
    
    let subtitleLabel = UILabel(frame: .zero).setUp {
        $0.font = Theme.font.regular(size: .XtraSmall)
        $0.textColor = UIColor.whiteColor()
        $0.textAlignment = .Center
    }
    
    init(icon: UIImage?, subtitle: String) {
        super.init(frame: .zero)
        
        iconImageView.image = icon
        subtitleLabel.text = subtitle
        
        addSubviews([iconImageView, subtitleLabel])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        iconImageView.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.size.equalTo(21)
            make.centerX.equalTo(superview)
            make.top.equalTo(superview)
        }
        
        subtitleLabel.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(iconImageView.snp_bottom).offset(5)
        }
        
        super.updateConstraints()
    }
    
    override var highlighted: Bool {
        didSet {
            let alpha: CGFloat = highlighted ? 0.8 : 1.0
            
            iconImageView.alpha = alpha
            subtitleLabel.alpha = alpha
        }
    }
}