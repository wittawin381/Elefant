//
//  StatusCollectionViewCell.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 9/4/2568 BE.
//

import Foundation
import UIKit

@MainActor protocol CancellableView {
    func cancel()
}

class StatusCollectionViewCell: UICollectionViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let contentView = contentView as? CancellableView {
            contentView.cancel()
        }
    }
}
