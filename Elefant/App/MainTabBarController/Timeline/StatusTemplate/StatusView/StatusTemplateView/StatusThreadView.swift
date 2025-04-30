//
//  StatusThreadView.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 28/4/2568 BE.
//

import Foundation
import UIKit

final class StatusThreadView: UIView {
    private let profileImageView = StatusProfileImageView()
    private var imageTask: Task<Void, Never>?
    
    var actionHandler: ActionHandler?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct ActionHandler {
        let profileImageTapHandler: (() -> Void)?
    }
    
    struct Configuration {
        let imageURL: String
        let actionHandler: ActionHandler?
    }
    
    func configure(with configuration: Configuration) {
        actionHandler = configuration.actionHandler

        imageTask?.cancel()
        imageTask = profileImageView.imageView.setImage(from: configuration.imageURL, placeholderImage: UIImage(systemName: "photo"))
    }
    
    private func setupLayout() {
        addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    private func setupView() {
        profileImageView.imageView.contentMode = .scaleAspectFill
        profileImageView.addTarget(self, action: #selector(onProfileImageTapped), for: .touchUpInside)
    }
    
    @objc private func onProfileImageTapped() {
        actionHandler?.profileImageTapHandler?()
    }
}
