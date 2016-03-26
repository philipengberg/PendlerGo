//
//  String+Utilities.swift
//  PendlerGo
//
//  Created by Philip Engberg on 26/03/16.
//
//

import Foundation
import UIKit

extension String {
    init(htmlEncodedString: String) {
        let encodedData = htmlEncodedString.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions : Dictionary<String, AnyObject> = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
        ]
        do {
            let attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            self.init(attributedString.string)
        }
        catch _ {
            self.init(htmlEncodedString)
        }
    }
}