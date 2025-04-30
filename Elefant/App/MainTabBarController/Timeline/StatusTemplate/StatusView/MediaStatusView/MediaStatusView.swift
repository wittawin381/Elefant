//
//  MediaStatusView.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 8/4/2568 BE.
//

import Foundation
import UIKit

class MediaStatusView<Watcher>: StatusTemplateView, MediaCollectionViewCellProvider where Watcher: StatusWatcher {
    private let mediaView = MediaView()
    private var appliedConfiguration: MediaStatusViewConfiguration<Watcher>!
    private var mediaPreviewableItem: [MediaPreviewableItem] = []
    
    override var contentView: UIView { mediaView }
    
    var hasVideo: Bool {
        appliedConfiguration.mediaViewConfiguration.mediaAttachments.contains {
            if case .video = $0 { return true }
            return false
        }
    }
    
    var mediaViewFrame: CGRect {
        mediaContainerView.frame
    }
    
    init(configuration: MediaStatusViewConfiguration<Watcher>) {
        super.init(frame: .zero)
        setupLayout()
        setupView()
        apply(configuration: configuration)
        mediaView.apply(configuration: configuration.mediaViewConfiguration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
    }
    
    private func setupView() {

    }
    
    override func cancelTask() {
        if let mediaCancellable = mediaView as? CancellableView {
            mediaCancellable.cancel()
        }
    }
    
    func startPlayingMedia() {
        mediaView.startVideoPlayback()
    }
    
    func stopPlayingMedia() {
        mediaView.stopVideoPlayback()
    }
}

extension MediaStatusView: UIContentView {
    var configuration: any UIContentConfiguration {
        get { appliedConfiguration }
        set(newValue) {
            guard let newConfiguration = newValue as? MediaStatusViewConfiguration<Watcher> else { return }
            apply(configuration: newConfiguration)
        }
    }
    
    private func apply(configuration: MediaStatusViewConfiguration<Watcher>) {
        appliedConfiguration = configuration
        
        configure(
            with: StatusTemplateView.Configuration(
                statusID: configuration.statusID,
                statusThreadViewConfiguration: configuration.statusThreadViewConfiguration,
                statusProfilePreviewConfiguration: configuration.statusProfilePreviewConfiguration,
                statusReactionViewConfiguration: configuration.statusReactionViewConfiguration,
                content: configuration.content),
            statusWatcher: configuration.statusWatcher
        )
        
        mediaView.apply(configuration: configuration.mediaViewConfiguration)
    }
}
