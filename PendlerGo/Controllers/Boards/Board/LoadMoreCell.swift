//
//  LoadMoreCell.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/09/16.
//
//

import Foundation
import RxSwift

class LoadMoreCell : UITableViewCell, ReuseableView {
    
    let bag = DisposeBag()
    
    fileprivate let loadMoreLabel = UILabel().setUp {
        $0.font = Theme.font.medium(size: .medium)
        $0.textColor = Theme.color.darkTextColor
        $0.text = "Hent flere..."
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews([loadMoreLabel])
        
        backgroundColor = Theme.color.backgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func height() -> CGFloat {
        return 50
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let superview = contentView
        
        loadMoreLabel.x = 15
        loadMoreLabel.size = loadMoreLabel.intrinsicContentSize
        loadMoreLabel.centerY = superview.boundsCenterY
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func configure() {
        
    }
    
}
