//
//  LocationCell.swift
//  PendlerGo
//
//  Created by Philip Engberg on 19/02/16.
//
//

import Foundation
import UIKit

class LocationCell : UITableViewCell, ReuseableView {
    
    let nameLabel = UILabel().setUp {
        $0.font = Theme.font.regular(size: .Medium)
        $0.textColor = UIColor.whiteColor()
    }
    
    let homeAccessoryImageView = UIImageView().setUp {
        $0.image = UIImage(named: "home")
    }
    
    let workAccessoryImageView = UIImageView().setUp {
        $0.image = UIImage(named: "work")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundView = nil
        backgroundColor = UIColor.clearColor()
        
        addSubviews([nameLabel])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.x = 15
        nameLabel.width = contentView.width - 15 - 15
        nameLabel.height = 20
        nameLabel.centerY = contentView.centerY
    }
    
    func configure(location: Location) {
        nameLabel.text = location.name
        
        if let homeId = Settings.homeLocation?.id where homeId.isEqual(location.id) {
            self.accessoryView = homeAccessoryImageView
            self.accessoryView?.size = CGSize(width: 15, height: 15)
        } else if let workId = Settings.workLocation?.id where workId.isEqual(location.id) {
            self.accessoryView = workAccessoryImageView
            self.accessoryView?.size = CGSize(width: 15, height: 15)
        } else {
            self.accessoryView = nil
        }
    }
    
    
}