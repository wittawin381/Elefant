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

class StatusProfilePreview: UIView {
    private let profileTitleStackView = UIStackView()
    private let profileTitleLabel = UILabel()
    private let profileDescriptionLabel = UILabel()
    private let menuButton = UIButton()
    private var actionHandler: ActionHandler?
        
    struct ActionHandler {
        let profileTitleTapHandler: (() -> Void)?
        let menuButtonTapHandler: (() -> Void)?
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutMargins = .zero
        setupLayout()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct Configuration {
        let displayName: String
        let attributedDisplayName: ([NSAttributedString.Key: Any]) -> AttributedString?
        let userName: String
        let description: String
        let actionHandler: ActionHandler?
    }
    
    func configure(with configuration: Configuration) {
        actionHandler = configuration.actionHandler
        profileTitleLabel.attributedText = createProfileTitleAttributedString(
            profileName: configuration.displayName,
            attributedDisplayName: configuration.attributedDisplayName([
                .font: UIFont.preferredFont(forTextStyle: .headline)
            ]),
            userName: configuration.userName)
        profileDescriptionLabel.text = configuration.description
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
    }
    
    private func setupLayout() {
        addSubview(profileTitleStackView)
        profileTitleStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileTitleStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            profileTitleStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            profileTitleStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])
        
        profileTitleStackView.addArrangedSubview(profileTitleLabel)
        profileTitleStackView.addArrangedSubview(profileDescriptionLabel)
        
        addSubview(menuButton)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            menuButton.leadingAnchor.constraint(equalTo: profileDescriptionLabel.trailingAnchor),
            menuButton.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            menuButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            menuButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 60)
        ])
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
}

extension StatusProfilePreview {
    @objc private func onProfileTitleTapped() {
        actionHandler?.profileTitleTapHandler?()
    }
    
    @objc private func onMenuButtonTapped() {
        actionHandler?.menuButtonTapHandler?()
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
