//
//  String+Extension.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 3/4/2568 BE.
//

import Foundation

extension Int {
    
    var formattedShort: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 1
        if self < 100_000 {
            return numberFormatter.string(for: self) ?? ""
        }
        
        if self > 99_999 && self < 1_000_000 {
            let number = Double(self) / 1_000
            let formattedString = numberFormatter.string(for: number) ?? ""
            return "\(formattedString) K"
        } else {
            let number = Double(self) / 100_000
            let formattedString = numberFormatter.string(for: number) ?? ""
            return "\(formattedString) M"
        }
    }
}
