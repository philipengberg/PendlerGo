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
    
    let filterView = BoardContainmentFilterView().setUp {
        $0.backgroundColor = Theme.color.mainColor.colorWithAlphaComponent(1) //UIColor(red: 237, green: 159, blue: 33)
    }
    
    var showFilter: Bool = false
    var showAdBanner: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews([adBannerView, filterView, tabView])
        
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
        
        filterView.snp_remakeConstraintsWithSuper { (make, superview) in
            make.width.equalTo(superview)
            make.height.equalTo(60)
            make.left.right.equalTo(superview)
            if showFilter {
                make.top.equalTo(tabView.snp_bottom).offset(-10)
            } else {
                make.bottom.equalTo(tabView.snp_bottom).offset(-5)
            }
        }
        
        super.updateConstraints()
    }
    
}