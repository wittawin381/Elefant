//
//  VideoPreviewConfiguration.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 11/4/2568 BE.
//

import Foundation
import UIKit

struct VideoPreviewConfiguration: UIContentConfiguration, Hashable {
    let previewURL: String
    let previewImageURL: String
    let url: String
    let blurhash: String
    let aspect: Double
    
    func makeContentView() -> any UIView & UIContentView {
        VideoPreview(configuration: self)
    }
    
    func updated(for state: any UIConfigurationState) -> Self {
        self
    }
}
