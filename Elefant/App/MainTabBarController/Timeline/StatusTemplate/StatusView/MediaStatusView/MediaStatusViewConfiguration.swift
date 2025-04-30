//
//  MediaStatusViewConfiguration.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 8/4/2568 BE.
//

import Foundation
import UIKit
import HTMLParser

struct MediaStatusViewConfiguration<Watcher>: UIContentConfiguration where Watcher: StatusWatcher {
    let statusID: String
    let statusThreadViewConfiguration: StatusThreadView.Configuration
    let statusProfilePreviewConfiguration: StatusProfilePreview.Configuration
    let statusReactionViewConfiguration: StatusReactionView.Configuration
    let mediaViewConfiguration: MediaViewConfiguration
    let content: Content?
    let statusWatcher: Watcher
        
    func makeContentView() -> any UIView & UIContentView {
        MediaStatusView(configuration: self)
    }
    
    func updated(for state: any UIConfigurationState) -> MediaStatusViewConfiguration {
        self
    }
}


struct AnyHandler<Handler>: Hashable {
    let id: String = UUID().uuidString
    
    let handler: Handler?
    
    init(handler: Handler?) {
        self.handler = handler
    }
    
    static func == (lhs: AnyHandler<Handler>, rhs: AnyHandler<Handler>) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
