//
//  ImagePreviewConfiguration.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 11/4/2568 BE.
//

import Foundation
import UIKit

struct ImagePreviewConfiguration: UIContentConfiguration, Hashable {
    let previewURL: String
    let blurhash: String
    let aspect: Double
    
    func makeContentView() -> any UIView & UIContentView {
        ImagePreview(configuration: self)
    }
    
    func updated(for state: any UIConfigurationState) -> ImagePreviewConfiguration {
        self
    }
}
