//
//  UITableView+ReusableView.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import Foundation
import UIKit

extension UITableView {
    
    func registerCell<T : UITableViewCell where T:ReuseableView>(type : T.Type) {
        self.registerClass(type.self, forCellReuseIdentifier: type.reuseIdentifier)
    }
    
    func dequeueCell<T : UITableViewCell where T: ReuseableView>(type : T.Type, indexPath: NSIndexPath) -> T {
        guard let cell = self.dequeueReusableCellWithIdentifier(type.reuseIdentifier, forIndexPath: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier \(type.reuseIdentifier). Are you sure it has been registered?")
        }
        return cell
    }
}