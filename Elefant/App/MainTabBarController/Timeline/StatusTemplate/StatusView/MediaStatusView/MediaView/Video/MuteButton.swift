//
//  MuteButton.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 17/4/2568 BE.
//

import Foundation
import UIKit
import AVFoundation

@MainActor protocol MuteButtonDelegate: AnyObject {
    func muteButtonDidTap(_ button: MuteButton)
}

final class MuteButton: MediaPlayerButton {
    weak var delegate: MuteButtonDelegate?
    
    enum Mode {
        case mute
        case volume(Float)
    }
    
    var mode: Mode = .mute {
        didSet {
            configureImage(mode: mode)
        }
    }
    
    init() {
        super.init(configuration: .init(
            symbolConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold, scale: .default)
                .applying(UIImage.SymbolConfiguration(paletteColors: [.white])),
            cornerRadius: 8,
            blurEffect: .systemThinMaterialDark))
        
        addTarget(self, action: #selector(muteButtonDidTap), for: .touchUpInside)
        configureImage(mode: mode)
    }
    
    private func configureImage(mode: Mode) {
        switch mode {
        case .mute:
            if let image = UIImage(systemName: "speaker.slash") {
                replaceSymbol(image: image)
            }
        case let .volume(level):
            if let image = UIImage(systemName: "speaker.wave.3", variableValue: Double(level)) {
                replaceSymbol(image: image)
            }
        }
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func muteButtonDidTap() {
        delegate?.muteButtonDidTap(self)
    }
}

