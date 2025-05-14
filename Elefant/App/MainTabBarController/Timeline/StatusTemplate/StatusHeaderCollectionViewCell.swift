//
//  StatusHeaderCollectionViewCell.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 11/5/2568 BE.
//

import Foundation
import UIKit

class StatusHeaderCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let contentView = contentView as? CancellableView {
            contentView.cancel()
        }
    }
}
