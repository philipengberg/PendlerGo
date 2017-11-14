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
    init?(htmlEncodedString: String) {
        let encodedData = htmlEncodedString.data(using: String.Encoding.utf8)!
        let attributedOptions : Dictionary<NSAttributedString.DocumentReadingOptionKey, Any> = [
            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html as Any,
            NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8 as Any
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
