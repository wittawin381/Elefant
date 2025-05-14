//
//  StatusMediaContentView.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 10/5/2568 BE.
//

import Foundation
import UIKit

class StatusMediaContentView: UIView, MediaCollectionViewCellProvider {
    private let mediaView: MediaView
    private var appliedConfiguration: Configuration
    
    var hasVideo: Bool {
        return appliedConfiguration.mediaViewConfiguration.mediaAttachments.contains {
            if case .video = $0 { return true }
            return false
        }
    }
    
    var mediaViewFrame: CGRect {
        mediaView.frame
    }
    
    func startPlayingMedia() {
        mediaView.startVideoPlayback()
    }
    
    func stopPlayingMedia() {
        mediaView.stopVideoPlayback()
    }
    
    struct Configuration: UIContentConfiguration {
        let mediaViewConfiguration: MediaViewConfiguration
        
        func makeContentView() -> any UIView & UIContentView {
            StatusMediaContentView(configuration: self)
        }
        
        func updated(for state: any UIConfigurationState) -> Self {
            self
        }
    }
    
    init(configuration: Configuration) {
        appliedConfiguration = configuration
        mediaView = MediaView(configuration: configuration.mediaViewConfiguration)
        super.init(frame: .zero)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        layoutMargins = UIEdgeInsets(
            top: 0,
            left: StatusViewConfiguration.padding,
            bottom: 0,
            right: StatusViewConfiguration.padding)

        addSubview(mediaView)
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        
        let trailingConstraint = mediaView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        trailingConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            mediaView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: StatusViewConfiguration.defaultContentLeadingSpacing),
            mediaView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            trailingConstraint,
            mediaView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
}

extension StatusMediaContentView: UIContentView {
    var configuration: any UIContentConfiguration {
        get { appliedConfiguration }
        set(newValue) {
            guard let configuration = newValue as? Configuration else { return }
            apply(configuration: configuration)
        }
    }
    
    private func apply(configuration: Configuration) {
        appliedConfiguration = configuration
        
        mediaView.apply(configuration: configuration.mediaViewConfiguration)
    }
}
