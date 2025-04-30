//
//  MediaPlayerButton.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 17/4/2568 BE.
//

import Foundation
import UIKit

class MediaPlayerButton: UIControl {
    private let imageView = UIImageView()
    private let blurEffectView = UIVisualEffectView()
    private var configuration: Configuration = .init(
        symbolConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .regular, scale: .default),
        cornerRadius: 8,
        blurEffect: .systemThinMaterialDark)
    
    struct Configuration {
        let symbolConfiguration: UIImage.SymbolConfiguration
        let cornerRadius: CGFloat
        let blurEffect: UIBlurEffect.Style
    }
    
    init(configuration: Configuration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupLayout()
        configure(with: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let maskPath = UIBezierPath(roundedRect: bounds, cornerRadius: configuration.cornerRadius)
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
    
    func configure(with configuration: Configuration) {
        imageView.preferredSymbolConfiguration = configuration.symbolConfiguration
        layer.cornerRadius = configuration.cornerRadius
        blurEffectView.effect = UIBlurEffect(style: configuration.blurEffect)
        blurEffectView.isUserInteractionEnabled = false
    }
    
    func replaceSymbol(name: String) {
        guard let image = UIImage(systemName: name) else { return }
        imageView.setSymbolImage(image, contentTransition: .replace.downUp)
    }
    
    func replaceSymbol(image: UIImage) {
        imageView.setSymbolImage(image, contentTransition: .replace.downUp)
    }
    
    private func setupLayout() {
        addSubview(blurEffectView)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.frame = bounds
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            imageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
