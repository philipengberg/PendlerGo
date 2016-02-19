//
//  Setup.swift
//  PendlerGo
//
//  Created by Philip Engberg on 18/02/16.
//
//

import Foundation

public protocol Setup {}

extension Setup {
    public func setUp(@noescape block: Self -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject : Setup {}