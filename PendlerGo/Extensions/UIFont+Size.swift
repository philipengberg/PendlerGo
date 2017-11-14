//
//  UIFont+Size.swift
//  PendlerGo
//
//  Created by Philip Engberg on 14/03/16.
//
//

import Foundation
import UIKit

extension UIFont {
    func sizeOfString (_ string: String, constrainedToWidth width: Double) -> CGSize {
        if string.isEmpty {
            return CGSize.zero
        }
        return NSString(string: string).boundingRect(with: CGSize(width: width, height: Double.infinity),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [NSAttributedStringKey.font: self],
            context: nil).size
    }
}
