//
//  BoardDepartureCell.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import Foundation
import UIKit
import DateTools

class BoardDepartureCell: UITableViewCell, ReuseableView {
    
    let timeLabel = UILabel().setUp {
        $0.font = Theme.font.demiBold(size: .Medium)
        $0.textColor = Theme.color.darkTextColor
    }
    
    let realTimeLabel = UILabel().setUp {
        $0.font = Theme.font.demiBold(size: .Small)
        $0.textColor = UIColor.redColor()
    }
    
    let typeLabel = UILabel().setUp {
        $0.font = Theme.font.regular(size: .Small)
        $0.textColor = Theme.color.darkTextColor
    }
    
    let nameLabel = UILabel().setUp {
        $0.font = Theme.font.medium(size: .Small)
        $0.textColor = Theme.color.darkTextColor
        $0.textAlignment = .Center
        $0.layer.cornerRadius = 2
        $0.layer.masksToBounds = true
    }
    
    let destinationLabel = UILabel().setUp {
        $0.font = Theme.font.regular(size: .Medium)
        $0.textColor = Theme.color.darkTextColor
    }
    
    let trackLabel = UILabel().setUp {
        $0.font = Theme.font.regular(size: .Small)
        $0.textColor = Theme.color.darkTextColor
        $0.textAlignment = .Right
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews([timeLabel, realTimeLabel, /*typeLabel,*/ nameLabel, destinationLabel, trackLabel])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let superview = contentView
        
        timeLabel.x = 15
        timeLabel.width = 40
        timeLabel.height = 20
        timeLabel.centerY = superview.centerY
        
        realTimeLabel.x = timeLabel.x
        realTimeLabel.y = timeLabel.bottom - 3
        realTimeLabel.width = timeLabel.width
        realTimeLabel.height = 15
        
        typeLabel.x = timeLabel.right + 8
        typeLabel.width = 20
        typeLabel.height = 20
        typeLabel.centerY = superview.centerY
        
        nameLabel.x = timeLabel.right + 8
        nameLabel.width = max(30, nameLabel.intrinsicContentSize().width + 10)
        nameLabel.height = 20
        nameLabel.centerY = superview.centerY
        
        destinationLabel.x = nameLabel.right + 4
        destinationLabel.width = 200
        destinationLabel.height = 20
        destinationLabel.centerY = superview.centerY
        
        trackLabel.height = 20
        trackLabel.width = 70
        trackLabel.right = superview.right - 10
        trackLabel.centerY = superview.centerY
    }
    
    func configure(departure: Departure) {
        timeLabel.text = departure.time
        nameLabel.text = departure.name
        destinationLabel.text = "👉 \(departure.finalStop)"
        
        if !departure.realTime.isEmpty && departure.time != departure.realTime {
            realTimeLabel.hidden = false
            realTimeLabel.text = "+\(abs(Int(departure.realDepartureTime.minutesFrom(departure.departureTime))))"
        } else {
            realTimeLabel.hidden = true
        }
        
        if let realTrack = departure.realTrack where  realTrack != departure.track {
            trackLabel.text = "Spor " + realTrack
           
            // S-trains are weird
            if !departure.track.isEmpty {
                trackLabel.textColor = UIColor.redColor()
            }
        } else {
            trackLabel.text = "Spor " + departure.track
            trackLabel.textColor = Theme.color.darkTextColor
        }
        
        nameLabel.textColor = UIColor.whiteColor()
        
        switch departure.type {
        case .IC:
            nameLabel.backgroundColor = Theme.color.trainIC
        case .Regional:
            nameLabel.backgroundColor = Theme.color.trainReg
        case .OtherTrain:
            nameLabel.backgroundColor = Theme.color.trainOther
        case .STrain:
            switch departure.sTrainType {
            case .A: nameLabel.backgroundColor  = Theme.color.sTrainA
            case .B: nameLabel.backgroundColor  = Theme.color.sTrainB
            case .Bx: nameLabel.backgroundColor = Theme.color.sTrainBx
            case .C: nameLabel.backgroundColor  = Theme.color.sTrainC
            case .E: nameLabel.backgroundColor  = Theme.color.sTrainE
            case .F: nameLabel.backgroundColor  = Theme.color.sTrainF
            case .H: nameLabel.backgroundColor  = Theme.color.sTrainH
            default: break
            }
        default:
            nameLabel.textColor =  Theme.color.darkTextColor
            nameLabel.backgroundColor = UIColor.clearColor()
        }
        
        switch departure.type {
        case .IC:           typeLabel.text = "🚄"
        case .Regional:     typeLabel.text = "🚂"
        case .Lyn:          typeLabel.text = "🚄"
        case .OtherTrain:   typeLabel.text = "🚅"
        case .STrain:       typeLabel.text = "🚈"
        case .Metro:        typeLabel.text = "🚇"
        case .Bus:          typeLabel.text = "🚌"
        case .Ferry:        typeLabel.text = "⛴"
        default: break
        }
    }
    
}