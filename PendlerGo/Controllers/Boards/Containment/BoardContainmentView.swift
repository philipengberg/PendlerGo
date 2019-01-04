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
        $0.backgroundColor = Theme.color.mainColor.withAlphaComponent(1) //UIColor(red: 237, green: 159, blue: 33)
    }
    
    let removeAdsView = RemoveAdsView()
    
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
        
        tabView.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(0)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        
        
        adBannerView.snp.remakeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(50)
            if self.showAdBanner {
                if #available(iOS 11.0, *) {
                    make.bottom.equalTo(safeAreaLayoutGuide)
                } else {
                    make.bottom.equalToSuperview()
                }
            } else {
                make.top.equalTo(self.snp.bottom)
            }
        }
        
        filterView.snp.remakeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(60)
            make.left.right.equalToSuperview()
            if self.showFilter {
                make.top.equalTo(self.tabView.snp.bottom).offset(-10)
            } else {
                make.bottom.equalTo(self.tabView.snp.bottom).offset(-5)
            }
        }
        
//        removeAdsView.snp.updateConstraints { (make) in
//            make.left.right.equalToSuperview()
//            make.height.equalTo(50)
//            make.bottom.equalTo(adBannerView.snp.top)
//        }
        
        super.updateConstraints()
    }
    
}

class RemoveAdsView: UIView {
    
    let label = UILabel().setUp {
        $0.font = Theme.font.medium(size: .large)
        $0.textColor = .white
        $0.text = "Fjern reklamer >"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews([label])
        backgroundColor = Theme.color.mainColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        label.snp.updateConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        super.updateConstraints()
    }
    
}
