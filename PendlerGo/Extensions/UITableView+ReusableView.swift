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
    
    func registerCell<T : UITableViewCell>(_ type : T.Type) where T:ReuseableView {
        self.register(type.self, forCellReuseIdentifier: type.reuseIdentifier)
    }
    
    func dequeueCell<T : UITableViewCell>(_ type : T.Type, indexPath: IndexPath) -> T where T: ReuseableView {
        guard let cell = self.dequeueReusableCell(withIdentifier: type.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier \(type.reuseIdentifier). Are you sure it has been registered?")
        }
        return cell
    }
}
