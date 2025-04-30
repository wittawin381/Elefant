//
//  ImagePreview.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 11/4/2568 BE.
//

import Foundation
import UIKit

class ImagePreview: UIView {
    private var appliedConfiguration: ImagePreviewConfiguration
    private var task: Task<Void, Never>?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    } ()
    
    init(configuration: ImagePreviewConfiguration) {
        appliedConfiguration = configuration
        super.init(frame: .zero)
        setupLayout()
        apply(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        layer.masksToBounds = true
    }
}

extension ImagePreview: UIContentView {
    var configuration: any UIContentConfiguration {
        get { appliedConfiguration }
        set(newValue) {
            guard let newConfiguration = newValue as? ImagePreviewConfiguration else { return }
            apply(configuration: newConfiguration)
        }
    }
    
    private func apply(configuration: ImagePreviewConfiguration) {
        appliedConfiguration = configuration
//        let size = CGSize(width: imageView.bounds.width, height: imageView.bounds.width * configuration.aspect)
//        let blurhashImage = UIImage(blurHash: configuration.blurhash, size: size)
//        imageView.image = blurhashImage
        task = imageView.setImage(
            from: configuration.previewURL,
            placeholderImage: UIImage())
    }
}
