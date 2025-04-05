//
//  ImageCacheManager.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 3/4/2568 BE.
//

import Foundation
import UIKit

@MainActor struct ImageCacheManager: Sendable {
    static let shared = ImageCacheManager()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    func setObject(_ object: UIImage, for key: String) {
        cache.setObject(object, forKey: NSString(string: key))
    }
    
    func object(for key: String) -> UIImage? {
        cache.object(forKey: NSString(string: key))
    }
}
