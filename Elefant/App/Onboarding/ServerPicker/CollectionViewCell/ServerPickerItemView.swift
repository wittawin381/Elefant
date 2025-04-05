//
//  ServerPickerItemView.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 3/4/2568 BE.
//

import Foundation
import UIKit

class ServerPickerItemView: UIView {
    private var appliedContentConfiguration: ServerPickerViewContentConfiguration! {
        didSet {
            configurationDidUpdated(configuration: appliedContentConfiguration)
        }
    }
    
    private let coverImageView = UIImageView()
    private let serverTitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let totalUsersLabel = UILabel()
    private let lastWeekUsersLabel = UILabel()
    private var coverImageTask: Task<Void, Never>?
    
    init(configuration: ServerPickerViewContentConfiguration) {
        super.init(frame: .zero)
        configurationDidUpdated(configuration: configuration)
        setupLayout(hasImage: configuration.coverImageURL != nil)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout(hasImage: Bool) {
        if hasImage {
            coverImageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(coverImageView)
            NSLayoutConstraint.activate([
                coverImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                coverImageView.topAnchor.constraint(equalTo: topAnchor),
                coverImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                coverImageView.heightAnchor.constraint(equalToConstant: 120)
            ])
        }
        
        let topConstraint = hasImage ? coverImageView.bottomAnchor : topAnchor
        serverTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(serverTitleLabel)
        NSLayoutConstraint.activate([
            serverTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            serverTitleLabel.topAnchor.constraint(equalTo: topConstraint, constant: 16),
            serverTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: serverTitleLabel.bottomAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        let bottomConstraint = totalUsersLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        bottomConstraint.priority = .defaultHigh
        totalUsersLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(totalUsersLabel)
        NSLayoutConstraint.activate([
            totalUsersLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            totalUsersLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            bottomConstraint
        ])
        
        lastWeekUsersLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lastWeekUsersLabel)
        NSLayoutConstraint.activate([
            lastWeekUsersLabel.leadingAnchor.constraint(equalTo: totalUsersLabel.trailingAnchor, constant: 16),
            lastWeekUsersLabel.topAnchor.constraint(equalTo: totalUsersLabel.topAnchor),
            lastWeekUsersLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
        ])
    }
    
    private func setupView() {
        backgroundColor = .secondarySystemGroupedBackground
        serverTitleLabel.numberOfLines = 1
        serverTitleLabel.font = .preferredFont(forTextStyle: .title3)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .preferredFont(forTextStyle: .caption1)
        descriptionLabel.textColor = .secondaryLabel
        
        totalUsersLabel.numberOfLines = 1
        totalUsersLabel.font = .preferredFont(forTextStyle: .caption2)
        totalUsersLabel.textColor = .tintColor
        
        lastWeekUsersLabel.numberOfLines = 1
        lastWeekUsersLabel.font = .preferredFont(forTextStyle: .caption2)
        lastWeekUsersLabel.textColor = .tintColor
        
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
    }
}

extension ServerPickerItemView: UIContentView {
    var configuration: any UIContentConfiguration {
        get { appliedContentConfiguration }
        set(newValue) {
            guard let newConfiguration = newValue as? ServerPickerViewContentConfiguration,
                  newConfiguration != appliedContentConfiguration else { return }
            appliedContentConfiguration = newConfiguration
        }
    }
    
    private func configurationDidUpdated(configuration: ServerPickerViewContentConfiguration) {
        self.configuration = configuration
        serverTitleLabel.text = configuration.serverName
        descriptionLabel.text = configuration.description
        totalUsersLabel.text = "total users: \(configuration.totalUsers.formattedShort)"
        lastWeekUsersLabel.text = "last week users: \(configuration.lastWeekUser.formattedShort)"
        
        coverImageTask?.cancel()
        coverImageView.image = nil
        if let coverImageURL = configuration.coverImageURL {
            coverImageTask = coverImageView.setImage(from: coverImageURL, placeholderImage: UIImage(systemName: "photo"))
        }
    }
}
