//
//  BoardContainmentView.swift
//  PendlerGo
//
//  Created by Philip Engberg on 19/02/16.
//
//

import Foundation
import CoreAudioKit
import GoogleMobileAds

class BoardContainmentView : UIView {
    
    let tabView = BoardContainmentTabView(numberOfTabs: 2, outerMargin: 15, innerMargin: 30).setUp {
        $0.backgroundColor = Theme.color.mainColor
    }
    
    let adBannerView = GADBannerView().setUp {
        $0.adUnitID = "ca-app-pub-7606160133081216/4101628484"
        $0.adSize = kGADAdSizeSmartBannerPortrait
    }
    
    var showAdBanner: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews([tabView, adBannerView])
        
        setNeedsUpdateConstraints()
        
        backgroundColor = Theme.color.backgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        tabView.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.top.equalTo(superview).offset(0)
            make.left.right.equalTo(superview)
            make.height.equalTo(50)
        }
        
        
        adBannerView.snp_remakeConstraintsWithSuper { (make, superview) -> Void in
            make.width.equalTo(superview)
            make.height.equalTo(50)
            if showAdBanner {
                make.bottom.equalTo(superview)
            } else {
                make.top.equalTo(superview.snp_bottom)
            }
        }
        
        super.updateConstraints()
    }
    
}