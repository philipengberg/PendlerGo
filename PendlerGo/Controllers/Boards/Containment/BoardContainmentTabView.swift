//
//  LeagueTabView.swift
//  Tonsser
//
//  Created by Philip Engberg on 14/01/16.
//  Copyright © 2016 tonsser. All rights reserved.
//

import Foundation
import UIKit

class BoardContainmentTabView: TabView {
    
    let homeButton   = IconTabViewButton(icon: UIImage.imageNamed("home", coloredWithColor: UIColor.white, blendMode: .overlay), subtitle: "Hjem")
    let workButton   = IconTabViewButton(icon: UIImage.imageNamed("work", coloredWithColor: UIColor.white, blendMode: .multiply), subtitle: "Arbejde")
    
    override init(numberOfTabs: Int, outerMargin: Double, innerMargin: Double) {
        super.init(numberOfTabs: numberOfTabs, outerMargin: outerMargin, innerMargin: innerMargin)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func buttonAtIndex(_ index: Int) -> UIButton {
            
            switch index {
            case 0:   return homeButton
            case 1:   return workButton
            default: break
            }
        
        fatalError("There was an inconsistency in the setup of \(self)")
        
    }
    
}
