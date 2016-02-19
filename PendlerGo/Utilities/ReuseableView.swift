//
//  ReusableView.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import Foundation
import UIKit

protocol ReuseableView : class {
    static var reuseIdentifier : String { get }
}

extension ReuseableView where Self : UIView {
    static var reuseIdentifier : String {
        return NSStringFromClass(self) as String
  }
}