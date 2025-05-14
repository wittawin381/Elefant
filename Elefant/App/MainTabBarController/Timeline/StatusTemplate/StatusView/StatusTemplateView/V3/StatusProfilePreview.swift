//
//  StatusProfilePreview.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 8/4/2568 BE.
//

import Foundation
import UIKit
import ElefantEntity

private let kProfileImageViewSize: CGFloat = 44

class StatusProfilePreviewV2: UIView {
    private let profileImageView = StatusProfileImageView()
    private var imageTask: Task<Void, Never>?
    private let profileTitleStackView = UIStackView()
    private let profileTitleLabel = UILabel()
    private let profileDescriptionLabel = UILabel()
    private let menuButton = UIButton()
    private var actionHandler: ActionHandler?
    
    private var appliedConfiguration: Configuration
        
    struct ActionHandler {
        let profileTitleTapHandler: (() -> Void)?
        let menuButtonTapHandler: (() -> Void)?
    }
    
    init(configuration: Configuration) {
        appliedConfiguration = configuration
        super.init(frame: .zero)
        
        setupLayout()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct Configuration: UIContentConfiguration {
        let displayName: String
        let attributedDisplayName: ([NSAttributedString.Key: Any]) -> AttributedString?
        let userName: String
        let createdAt: Date
        let imageURL: String
        let actionHandler: ActionHandler?
        
        func makeContentView() -> any UIView & UIContentView {
            StatusProfilePreviewV2(configuration: self)
        }
        
        func updated(for state: any UIConfigurationState) -> StatusProfilePreviewV2.Configuration {
            self
        }
    }
    
    private func setupView() {
        profileTitleLabel.numberOfLines = 1
        
        profileDescriptionLabel.numberOfLines = 1
        profileDescriptionLabel.font = .preferredFont(forTextStyle: .subheadline)
        profileDescriptionLabel.textColor = .secondaryLabel
        
        let profileTitleTapGesture = UITapGestureRecognizer(target: self, action: #selector(onProfileTitleTapped))
        profileTitleLabel.addGestureRecognizer(profileTitleTapGesture)
        
        let profileDescriptionTapGesture = UITapGestureRecognizer(target: self, action: #selector(onProfileTitleTapped))
        profileDescriptionLabel.addGestureRecognizer(profileDescriptionTapGesture)
        
        profileTitleStackView.axis = .vertical
        profileTitleStackView.spacing = 2
        
        profileImageView.addTarget(self, action: #selector(profileImageDidTap), for: .touchUpInside)
    }
    
    private func setupLayout() {
        layoutMargins = UIEdgeInsets(
            top: StatusViewConfiguration.padding,
            left: StatusViewConfiguration.padding,
            bottom: 0,
            right: StatusViewConfiguration.padding)
        
        addSubview(profileImageView)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            profileImageView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: StatusViewConfiguration.profileImageSize.width),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
        ])
        
        addSubview(profileTitleStackView)
        profileTitleStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileTitleStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: StatusViewConfiguration.profileImageToContentSpacing),
            profileTitleStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            profileTitleStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        profileTitleStackView.addArrangedSubview(profileTitleLabel)
        profileTitleStackView.addArrangedSubview(profileDescriptionLabel)
        
//        addSubview(menuButton)
//        menuButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            menuButton.leadingAnchor.constraint(equalTo: profileDescriptionLabel.trailingAnchor),
//            menuButton.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
//            menuButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
//            menuButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
//            menuButton.widthAnchor.constraint(equalToConstant: 60)
//        ])
    }
    
    @MainActor private func createProfileTitleAttributedString(profileName: String, attributedDisplayName: AttributedString?, userName: String) -> NSAttributedString {
        let userNameAttributedString  = NSMutableAttributedString(string: " @\(userName)", attributes: [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.preferredFont(forTextStyle: .subheadline)
        ])
        
        if let attributedDisplayName {
            let newAttributedDisplayName = NSMutableAttributedString(attributedDisplayName)
            newAttributedDisplayName.append(userNameAttributedString)
            return newAttributedDisplayName
        }
        
        let profileNameAttributedString = NSMutableAttributedString(string: profileName, attributes: [
            .foregroundColor: UIColor.label,
            .font: UIFont.preferredFont(forTextStyle: .headline)
        ])
        
        profileNameAttributedString.append(userNameAttributedString)
        return profileNameAttributedString
    }
    
    @objc private func profileImageDidTap() {
        print("profile image tap")
    }
}

extension StatusProfilePreviewV2 {
    @objc private func onProfileTitleTapped() {
        actionHandler?.profileTitleTapHandler?()
    }
    
    @objc private func onMenuButtonTapped() {
        actionHandler?.menuButtonTapHandler?()
    }
}

extension StatusProfilePreviewV2: UIContentView {
    var configuration: any UIContentConfiguration {
        get { appliedConfiguration }
        set(newValue) {
            guard let configuration = newValue as? Configuration else { return }
            apply(configuration: configuration)
        }
    }
    
    private func apply(configuration: Configuration) {
        appliedConfiguration = configuration
        
        imageTask?.cancel()
        imageTask = profileImageView.imageView.setImage(from: configuration.imageURL, placeholderImage: UIImage(systemName: "photo"))
        actionHandler = configuration.actionHandler
        profileTitleLabel.attributedText = createProfileTitleAttributedString(
            profileName: configuration.displayName,
            attributedDisplayName: configuration.attributedDisplayName([
                .font: UIFont.preferredFont(forTextStyle: .headline)
            ]),
            userName: configuration.userName)
        profileDescriptionLabel.text = configuration.createdAt.formattedSinceDate()
    }
}

extension Account {
    func displayNameWithIcon(attributes: [NSAttributedString.Key: Any]) -> AttributedString {
        let attributedDisplayName = NSMutableAttributedString(string: username)
        
        if displayName.contains(":verified_business:") {
            let configuration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 12))
            let colored = configuration.applying(UIImage.SymbolConfiguration(paletteColors: [.systemYellow]))
            let checkImage = UIImage(systemName: "checkmark.seal.fill", withConfiguration: colored)!
            let imageAttachment = NSTextAttachment(image: checkImage)
            attributedDisplayName.append(NSAttributedString(string: " ", attributes: attributes))
            attributedDisplayName.append(NSAttributedString(attachment: imageAttachment))
        }
        
        if locked {
            let configuration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 12))
            let checkImage = UIImage(systemName: "lock.fill", withConfiguration: configuration)!
            let imageAttachment = NSTextAttachment(image: checkImage)
            attributedDisplayName.append(NSAttributedString(string: " ", attributes: attributes))
            attributedDisplayName.append(NSAttributedString(attachment: imageAttachment))
        }
        
        if bot {
            attributedDisplayName.append(NSAttributedString(string: " ", attributes: attributes))
            attributedDisplayName.append(NSAttributedString(string: "\u{1F916}"))
        }
        
        return AttributedString(attributedDisplayName)
    }
}

extension Date {
    func formattedSinceDate() -> String {
        let distance = distance(to: Date.now)
        if distance < TimeInterval(60 * 60 * 24) {
            if distance < TimeInterval(60) {
                return "\(Int(distance)) seconds ago"
            }
            if distance < TimeInterval(60 * 60) {
                return "\(Int(distance / 60)) minutes ago"
            }
            return "\(Int(distance / (60 * 60))) hours ago"
        }
        return formatted(date: .complete, time: .shortened)
    }
}
