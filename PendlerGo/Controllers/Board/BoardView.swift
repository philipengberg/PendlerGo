//
//  BoardView.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import Foundation
import UIKit
import SnapKit

class BoardView : UIView {
    let tableView = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tableView)
        
        setNeedsUpdateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        tableView.snp_updateConstraintsWithSuper { (make, superview) -> Void in
            make.edges.equalTo(superview)
        }
        
        super.updateConstraints()
    }
}