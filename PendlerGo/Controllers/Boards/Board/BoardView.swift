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
    
    let tableView = UITableView().setUp {
        $0.backgroundColor = Theme.color.backgroundColor
    }
    
    let refreshControl = UIRefreshControl()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tableView)
        
        setNeedsUpdateConstraints()
        
        let tableViewController = UITableViewController()
        tableViewController.tableView = tableView
        
        tableViewController.refreshControl = refreshControl
        
        backgroundColor = Theme.color.backgroundColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        tableView.snp.updateConstraints { make in
            make.edges.equalToSuperview()
        }
        
        super.updateConstraints()
    }
}
