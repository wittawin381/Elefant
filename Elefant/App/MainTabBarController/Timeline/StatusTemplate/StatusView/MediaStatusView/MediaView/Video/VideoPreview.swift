//
//  VideoPreview.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 11/4/2568 BE.
//

import Foundation
import UIKit
import AVKit
import Combine

@MainActor protocol MediaPreviewableItem {
    func start()
    func stop()
}

class VideoPreview: UIView, CancellableView, MediaPreviewableItem {
    private var appliedConfiguration: VideoPreviewConfiguration
    private let videoPlayerLayer = AVPlayerLayer()
    private var player: AVPlayer?
    private var subscription = Set<AnyCancellable>()
    
    private let playButton = UIButton(type: .custom)
    private let blurEffectView = UIVisualEffectView()
    private let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
    
    private let muteButton = MuteButton()
    private var volumeObservationKey: NSKeyValueObservation?
    private var timer: Timer?
    
    init(configuration: VideoPreviewConfiguration) {
        appliedConfiguration = configuration
        super.init(frame: .zero)
        setupLayout()
        setupView()
        apply(configuration: configuration)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        videoPlayerLayer.frame = bounds
        
        let maskPath = UIBezierPath(roundedRect: playButton.bounds,
                                    byRoundingCorners: .allCorners,
                                    cornerRadii: CGSize(width: playButton.frame.height / 2,
                                                        height: playButton.frame.height / 2))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        blurEffectView.layer.mask = maskLayer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        layer.addSublayer(videoPlayerLayer)

        playButton.insertSubview(blurEffectView, at: 0)
        
        addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            playButton.heightAnchor.constraint(equalToConstant: 48),
            playButton.widthAnchor.constraint(equalToConstant: 48)
        ])
        
        addSubview(muteButton)
        muteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
           muteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
           muteButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
           muteButton.heightAnchor.constraint(equalToConstant: 32),
           muteButton.widthAnchor.constraint(equalToConstant: 42)
       ])
    }
    
    private func setupView() {
        let playImageSize = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .large)
        let playImageColor = UIImage.SymbolConfiguration(paletteColors: [.white])
        let playImageConfig = playImageSize.applying(playImageColor)
        
        var playButtonConfiguration = UIButton.Configuration.plain()
        playButtonConfiguration.image = UIImage(systemName: "play.fill")
        playButtonConfiguration.preferredSymbolConfigurationForImage = playImageConfig
        playButtonConfiguration.imagePadding = 4
        playButton.configuration = playButtonConfiguration
        playButton.imageView?.contentMode = .center
        
        blurEffectView.effect = blurEffect
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.frame = playButton.bounds
        
        muteButton.delegate = self
        
        try? AVAudioSession.sharedInstance().setActive(true)

        volumeObservationKey = AVAudioSession.sharedInstance().observe(\.outputVolume, options: [.old, .new]) { [self] _, change in
            if let newValue = change.newValue {
                Task { @MainActor in
                    if case .volume(_) = muteButton.mode {
                        muteButton.mode = .volume(newValue)
                    }
                }
            }
        }
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(videoPreviewDidTap))
//        addGestureRecognizer(tapGesture)
    }
    
    @objc private func videoPreviewDidTap() {
//        guard let player else { return }
        //TODO:
    }
    
    func start() {
        player?.play()
    }
    
    func stop() {
        player?.pause()
    }
}

extension VideoPreview: MuteButtonDelegate {
    
    func muteButtonDidTap(_ button: MuteButton) {
        guard let player else { return }
        player.isMuted.toggle()
        if player.isMuted {
            muteButton.mode = .mute
        } else {
            muteButton.mode = .volume(AVAudioSession.sharedInstance().outputVolume)
        }
    }
}

extension VideoPreview: UIContentView {
    var configuration: any UIContentConfiguration {
        get { appliedConfiguration }
        set(newValue) {
            guard let newConfiguration = newValue as? VideoPreviewConfiguration else { return }
            apply(configuration: newConfiguration)
        }
    }
    
    func apply(configuration: VideoPreviewConfiguration) {
        appliedConfiguration = configuration
        
        if let playerFromCache = AVPlayerCacheManager.shared.object(for: configuration.url) {
            self.player = playerFromCache
        } else {
            guard let playerURL = URL(string: configuration.url) else { return }
            let player = AVPlayer(url: playerURL)
            self.player = player
            AVPlayerCacheManager.shared.setObject(player, for: configuration.url)
        }
        
        guard let playerItem = player?.currentItem else { return }
        playerItem.preferredMaximumResolution = CGSize(width: 960, height: 540)
        playerItem.preferredForwardBufferDuration = TimeInterval(1)
        
        player?.publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .paused:
                    playButton.isHidden = false
                case .waitingToPlayAtSpecifiedRate:
                    break
                case .playing:
                    playButton.isHidden = true
                @unknown default:
                    break
                }
            }.store(in: &subscription)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidPlayToEndTime),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
       
        videoPlayerLayer.player = player
        player?.actionAtItemEnd = .pause
        player?.isMuted = true
    }
    
    @objc private func playerItemDidPlayToEndTime() {
        
    }
    
    func cancel() {
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem)
    }
    
}

@MainActor struct AVPlayerCacheManager: Sendable {
    static let shared = AVPlayerCacheManager()
    private let cache = NSCache<NSString, AVPlayer>()
    
    private init() {}
    
    func setObject(_ object: AVPlayer, for key: String) {
        cache.setObject(object, forKey: NSString(string: key))
    }
    
    func object(for key: String) -> AVPlayer? {
        cache.object(forKey: NSString(string: key))
    }
}
