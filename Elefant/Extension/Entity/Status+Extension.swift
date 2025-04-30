//
//  Status+Extension.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 8/4/2568 BE.
//

import Foundation
import ElefantEntity
import UIKit

extension String {
    var contentAsAttributedString: String? {
        let data = Data(self.utf8)
        return try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil).string
    }
}
