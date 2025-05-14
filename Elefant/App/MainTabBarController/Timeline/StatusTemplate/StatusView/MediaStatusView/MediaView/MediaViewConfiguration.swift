//
//  MediaViewConfiguration.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 11/4/2568 BE.
//

import Foundation
import UIKit

struct MediaViewConfiguration: UIContentConfiguration {
    enum MediaType {
        case image(ImagePreviewConfiguration)
        case video(VideoPreviewConfiguration)
    }
    
    let mediaAttachments: [MediaType]
    
    func makeContentView() -> any UIView & UIContentView {
        MediaView(configuration: self)
    }
    
    func updated(for state: any UIConfigurationState) -> Self {
        self
    }
}
