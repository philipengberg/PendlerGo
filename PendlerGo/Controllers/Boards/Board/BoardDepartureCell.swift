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
import RxSwift

class BoardDepartureCell: UITableViewCell, ReuseableView {
    
    let timeLabel = UILabel().setUp {
        $0.font = Theme.font.demiBold(size: .Medium)
        $0.textColor = Theme.color.darkTextColor
        $0.textAlignment = .Center
    }
    
    let delayedLabel = UILabel().setUp {
        $0.font = Theme.font.demiBold(size: .Small)
        $0.textColor = UIColor.redColor()
        $0.textAlignment = .Right
    }
    
    let realTimeLabel = UILabel().setUp {
        $0.font = Theme.font.demiBold(size: .Small)
        $0.textColor = UIColor.redColor()
        $0.textAlignment = .Right
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
    
    let messageLabel = UILabel().setUp {
        $0.font = Theme.font.regular(size: .XtraSmall)
        $0.textColor = Theme.color.darkTextColor
        $0.hidden = true
        $0.numberOfLines = 0
    }
    
    let messageSpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    let bag = DisposeBag()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews([timeLabel, delayedLabel, realTimeLabel, /*typeLabel,*/ nameLabel, destinationLabel, trackLabel, messageLabel, messageSpinner])
        
        backgroundColor = Theme.color.backgroundColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func height(departure: Departure, journeyDetail: JourneyDetail?) -> CGFloat {
        var height: CGFloat = 13.75 + 20 - 3 + 15 + 2
        
        if let message = journeyDetail?.allMessages where departure.hasMessages {
            height += Theme.font.regular(size: .XtraSmall)!.sizeOfString(message, constrainedToWidth: Double(UIScreen.mainScreen().bounds.width - CGFloat(2 * 15))).height
            
            if departure.isDelayed || departure.cancelled {
                height += 7
            }
        } else if departure.hasMessages {
            height += 25 // Spinner
        }
        
        return height
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let superview = contentView
        
        timeLabel.x = 15
        timeLabel.width = 40
        timeLabel.height = 20
        timeLabel.top = 13.75
        
        realTimeLabel.x = timeLabel.x
        realTimeLabel.width = timeLabel.width
        realTimeLabel.height = 15
        realTimeLabel.bottom = timeLabel.top + 3
        
        delayedLabel.x = timeLabel.x
        delayedLabel.y = timeLabel.bottom - 3
        delayedLabel.width = timeLabel.width
        delayedLabel.height = 15
        
        nameLabel.x = timeLabel.right + 8
        nameLabel.width = max(30, nameLabel.intrinsicContentSize().width + 10)
        nameLabel.height = 20
        nameLabel.centerY = timeLabel.centerY
        
        trackLabel.height = 20
        trackLabel.width = trackLabel.intrinsicContentSize().width
        trackLabel.right = superview.right - 10
        trackLabel.centerY = nameLabel.centerY
        
        destinationLabel.left = nameLabel.right + 4
        destinationLabel.width = trackLabel.left - destinationLabel.left - 5
        destinationLabel.height = 20
        destinationLabel.centerY = nameLabel.centerY
        
        messageLabel.left = timeLabel.left
        messageLabel.width = trackLabel.right - messageLabel.left
        messageLabel.top = delayedLabel.hidden ? nameLabel.bottom + 5 : delayedLabel.bottom
        messageLabel.sizeToFit()
        
        messageSpinner.left = messageLabel.left
        messageSpinner.top = messageLabel.top
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        realTimeLabel.hidden = true
        delayedLabel.hidden = true
        trackLabel.hidden = false
        messageLabel.hidden = true
    }
    
    func configure(departure: Departure, journeyDetail: JourneyDetail?) {
        timeLabel.text = departure.time
        nameLabel.text = departure.name
        destinationLabel.text = "👉 \(departure.finalStop)"
        
        // CANCELLED
        if departure.cancelled {
            delayedLabel.hidden = false
            trackLabel.hidden = true
            delayedLabel.text = "Aflyst"
            
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: departure.time)
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attributeString.length))
            attributeString.addAttribute(NSForegroundColorAttributeName, value: realTimeLabel.textColor, range: NSMakeRange(0, attributeString.length))
            timeLabel.attributedText = attributeString
            
        // DELAYED
        } else if departure.isDelayed {
            
            let minutesDelayed = abs(Int(departure.realDepartureTime.minutesFrom(departure.departureTime)))
            
            delayedLabel.hidden = false
            delayedLabel.text = "+\(minutesDelayed)"
            
            if minutesDelayed > 10 {
                realTimeLabel.hidden = false
                realTimeLabel.text = departure.realTime
            }
        }
        
        // NEW TRACK
        if let realTrack = departure.realTrack where departure.hasChangedTrack {
            trackLabel.text = "Spor " + realTrack
           
            // S-trains are weird
            if !departure.track.isEmpty {
                trackLabel.textColor = UIColor.redColor()
                trackLabel.font = Theme.font.medium(size: .Small)
            }
        } else {
            trackLabel.text = "Spor " + departure.track
            trackLabel.textColor = Theme.color.darkTextColor
            trackLabel.font = Theme.font.regular(size: .Small)
        }
        
        
        if let detail = journeyDetail where departure.hasMessages {
            self.messageLabel.hidden = false
            self.messageLabel.text = detail.allMessages
            self.messageSpinner.stopAnimating()
        } else if departure.hasMessages {
            self.messageSpinner.startAnimating()
        }
        
        nameLabel.textColor = UIColor.whiteColor()
        
        switch departure.type {
        case .IC:
            nameLabel.backgroundColor = Theme.color.trainIC
        case .Regional:
            nameLabel.backgroundColor = Theme.color.trainReg
        case .OtherTrain:
            nameLabel.backgroundColor = Theme.color.trainOther
        case .Lyn:
            nameLabel.backgroundColor = Theme.color.trainLyn
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
        case .Metro:
            switch departure.name.substringFromIndex(departure.name.endIndex.advancedBy(-2)) {
            case "M1": nameLabel.backgroundColor = Theme.color.metroM1
            case "M2": nameLabel.backgroundColor = Theme.color.metroM2
            case "M3": nameLabel.backgroundColor = Theme.color.metroM3
            case "M4": nameLabel.backgroundColor = Theme.color.metroM4
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