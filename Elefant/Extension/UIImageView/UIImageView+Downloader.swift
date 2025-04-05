//
//  UIImageView+Downloader.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 3/4/2568 BE.
//

import Foundation
import UIKit

extension UIImageView {
    func setImage(from url: String, placeholderImage: UIImage?) -> Task<Void, Never>? {
        if let imageFromCache = ImageCacheManager.shared.object(for: url) {
            image = imageFromCache
            return nil
        }
        
        guard let imageURL = URL(string: url) else { return nil }
        return Task(priority: .userInitiated) {
            do {
                let (data, _) = try await URLSession.shared.data(from: imageURL)
                
                if let image = UIImage(data: data) {
                    ImageCacheManager.shared.setObject(image, for: url)
                    DispatchQueue.main.async {
                        self.image = image
                    }
                } else {
                    if let placeholderImage {
                        ImageCacheManager.shared.setObject(placeholderImage, for: url)
                    }
                    DispatchQueue.main.async {
                        self.image = placeholderImage ?? UIImage()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.image = placeholderImage ?? UIImage()
                }
            }
        }
    }
}
