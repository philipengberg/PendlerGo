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
        $0.contentMode = .scaleAspectFit
    }
    
    let subtitleLabel = UILabel(frame: .zero).setUp {
        $0.font = Theme.font.regular(size: .small)
        $0.textColor = UIColor.white
        $0.textAlignment = .center
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
        
        iconImageView.snp.updateConstraints { make in
            make.size.equalTo(21)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        subtitleLabel.snp.updateConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(iconImageView.snp.bottom).offset(4)
        }
        
        super.updateConstraints()
    }
    
    override var isHighlighted: Bool {
        didSet {
            let alpha: CGFloat = isHighlighted ? 0.8 : 1.0
            
            iconImageView.alpha = alpha
            subtitleLabel.alpha = alpha
        }
    }
}
