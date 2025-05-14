//
//  StatusViewBuilder.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 10/5/2568 BE.
//

import Foundation
import UIKit
import ElefantEntity

enum StatusViewConfiguration {
    static let profileImageSize: CGSize = .init(width: 48, height: 48)
    static let profileImageToContentSpacing: CGFloat = 16
    static let padding: CGFloat = 8
    static var defaultContentLeadingSpacing: CGFloat {
        profileImageSize.width + profileImageToContentSpacing
    }
}

struct StatusViewBuilder {
    func buildFrom(status: Status) -> [TimelineInternalDataController.Item] {
        var items: [TimelineInternalDataController.Item] = []
        
        items.append(.statusHeader(status.id))
        
        if (status.content?.value) != nil {
            items.append(.statusTextContent(status.id))
        }
        
        if !status.mediaAttachments.isEmpty {
            items.append(.statusMediaView(status.id))
        }
        
        items.append(.statusReactionView(status.id))
        
        return items
    }
}
