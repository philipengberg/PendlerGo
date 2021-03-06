//
//  TabView.swift
//  Tonsser
//
//  Created by Philip Engberg on 13/01/16.
//  Copyright © 2016 tonsser. All rights reserved.
//

import Foundation
import UIKit

class TabView : UIView {
    
    fileprivate var buttons = [UIButton]()
    fileprivate var outerMargin: Double
    fileprivate var innerMargin: Double
    var activeToggleIndex: Int = 0
    
    fileprivate let activeMarker = UIView().setUp {
        $0.backgroundColor = UIColor.white
    }
    
    fileprivate var buttonWidth: Double {
        return (Double(UIScreen.main.bounds.width) - outerMargin * 2 - innerMargin * Double(self.buttons.count - 1)) / Double(self.buttons.count)
    }
    
    init(numberOfTabs: Int, outerMargin: Double, innerMargin: Double) {
        
        self.outerMargin = outerMargin
        self.innerMargin = innerMargin
        
        super.init(frame: .zero)
        
        for i in 0..<numberOfTabs {
            buttons.append(buttonAtIndex(i))
        }
        
        addSubviews(buttons)
        addSubview(activeMarker)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        if buttons.count == 1 {
            fatalError("Not yet implemented")
        }
        
        for (index, button) in buttons.enumerated() {
            button.snp.updateConstraints { make in
                make.centerY.equalToSuperview()
                make.width.equalTo(buttonWidth)
                make.height.equalToSuperview()
                
                if index == 0 {
                    make.left.equalToSuperview().offset(outerMargin)
                } else {
                    make.left.equalTo(buttons[index - 1].snp.right).offset(innerMargin)
                }
            }
        }
        
        super.updateConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let percentage = Double(activeToggleIndex) / Double(self.buttons.count - 1)
        setActiveMarkerScrollPercentage(percentage)
    }
    
    func setActiveMarkerScrollPercentage(_ scrollPercentage: Double) {
        let i = Double(buttons.count - 1)
        
        let totalScrollableWidth = i * buttonWidth + i * innerMargin
        var markerX = outerMargin + scrollPercentage * totalScrollableWidth
        let markerHeight: Double = 4
        let minMarkerWidth: Double = 2
        
        var markerExcess: Double = 0.0
        
        if markerX < outerMargin {
            markerExcess = outerMargin - markerX
        } else if markerX > totalScrollableWidth + outerMargin {
            markerExcess = markerX - totalScrollableWidth - outerMargin
        }
        
        markerX = min(max(markerX, outerMargin), totalScrollableWidth + outerMargin + buttonWidth - minMarkerWidth)
        
        self.activeMarker.frame = CGRect(x: markerX, y: Double(self.height) - markerHeight, width: max(buttonWidth - markerExcess, minMarkerWidth), height: markerHeight)
    }
    
    func buttonAtIndex(_ index: Int) -> UIButton {
        let button = UIButton()
        button.titleLabel?.font = Theme.font.regular(size: .xtraSmall)
        return button
    }
    
}
