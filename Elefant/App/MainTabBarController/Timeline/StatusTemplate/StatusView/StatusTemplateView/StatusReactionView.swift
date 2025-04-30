//
//  StatusReactionView.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 8/4/2568 BE.
//

import Foundation
import UIKit

class StatusReactionView: UIView {
    private let stackView = UIStackView()
    private let replyButton = UIButton(type: .custom)
    private let reblogButton = UIButton(type: .custom)
    private let favouriteButton = UIButton(type: .custom)
    private let bookmarkButton = UIButton(type: .custom)
    private let shareButton = UIButton(type: .custom)
    private var actionHandler: ActionHandler?

    
    typealias ActionHandler = (Action) async -> Bool
    
    enum Action {
        case reply
        case reblog(Bool)
        case favourite(Bool, String)
        case bookmark(Bool)
        case share
    }
    
    private var configuration: Configuration = Configuration(
        statusID: "",
        reactionData: Configuration.Reaction(
            repliesCount: 0,
            reblogsCount: 0,
            reblogged: false,
            favouritesCount: 0,
            favourited: false,
            bookmarked: false),
        actionHandler: nil)
    
    struct Configuration: Hashable {
        let statusID: String
        struct Reaction: Hashable {
            let repliesCount: Int
            let reblogsCount: Int
            let reblogged: Bool
            let favouritesCount: Int
            let favourited: Bool
            let bookmarked: Bool
        }
        let reactionData: Reaction
        let actionHandler: ActionHandler?
        
        static func == (lhs: StatusReactionView.Configuration, rhs: StatusReactionView.Configuration) -> Bool {
            return lhs.reactionData == rhs.reactionData
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(reactionData)
        }
    }
    
    func configure(with configuration: Configuration) {
        self.configuration = configuration
        actionHandler = configuration.actionHandler

        let reactionData = configuration.reactionData
        replyButton.setTitle(reactionData.repliesCount.formattedShort, for: .normal)
        
        reblogButton.setTitle(reactionData.repliesCount.formattedShort, for: .normal)
        reblogButton.isSelected = configuration.reactionData.reblogged
        
        favouriteButton.setTitle(reactionData.favouritesCount.formattedShort, for: .normal)
        favouriteButton.isSelected = configuration.reactionData.favourited
        
        bookmarkButton.isSelected = configuration.reactionData.bookmarked
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupView()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        stackView.addArrangedSubview(replyButton)
        replyButton.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(reblogButton)
        reblogButton.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(favouriteButton)
        favouriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(bookmarkButton)
        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(shareButton)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupView() {
        stackView.distribution = .fillProportionally
        stackView.spacing = 24
        
        var replyButtonConfiguration = UIButton.Configuration.reactionButton()
        replyButtonConfiguration.image = UIImage(systemName: "text.bubble")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.systemGray)
        replyButton.contentHorizontalAlignment = .left
        replyButton.configuration = replyButtonConfiguration
        replyButton.addTarget(self, action: #selector(replyButtonDidTap), for: .touchUpInside)
        
        let reblogButtonImage = UIImage(systemName: "repeat")
        var reblogButtonConfiguration = UIButton.Configuration.reactionButton()
        reblogButtonConfiguration.image = reblogButtonImage?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.systemGray)
        reblogButtonConfiguration.imageReservation = 16
        reblogButton.configurationUpdateHandler = { button in
            var newContfiguration = button.configuration
            newContfiguration?.baseForegroundColor = button.isSelected ? .systemGreen : .secondaryLabel
            newContfiguration?.image = button.isSelected ?
                reblogButtonImage?
                    .withRenderingMode(.alwaysOriginal)
                    .withTintColor(.systemGreen)
                : reblogButtonImage?
                    .withRenderingMode(.alwaysOriginal)
                    .withTintColor(.systemGray)
            button.configuration = newContfiguration
        }
        reblogButton.contentHorizontalAlignment = .left
        reblogButton.configuration = reblogButtonConfiguration
        reblogButton.addTarget(self, action: #selector(reblogButtonDidTap), for: .touchUpInside)
        
        var favouriteButtonConfiguration = UIButton.Configuration.reactionButton()
        favouriteButtonConfiguration.image = UIImage(systemName: "heart")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.systemGray)
        favouriteButton.configurationUpdateHandler = { button in
            var newContfiguration = button.configuration
            newContfiguration?.image = button.isSelected ?
                UIImage(systemName: "heart.fill")?
                    .withRenderingMode(.alwaysOriginal)
                    .withTintColor(.systemRed)
                : UIImage(systemName: "heart")?
                    .withRenderingMode(.alwaysOriginal)
                    .withTintColor(.systemGray)
            newContfiguration?.baseForegroundColor = button.isSelected ? .systemRed : .secondaryLabel
            button.configuration = newContfiguration
        }
        favouriteButton.contentHorizontalAlignment = .left
        favouriteButton.configuration = favouriteButtonConfiguration
        favouriteButton.addTarget(self, action: #selector(favouriteButtonDidTap), for: .touchUpInside)
        
        var bookmarkButtonConfiguration = UIButton.Configuration.reactionButton()
        bookmarkButtonConfiguration.image =  UIImage(systemName: "bookmark")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.systemGray)
        bookmarkButton.configurationUpdateHandler = { button in
            var newContfiguration = button.configuration
            newContfiguration?.image = button.isSelected ? UIImage(systemName: "bookmark.fill")?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(.systemBlue)
            : UIImage(systemName: "bookmark")?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(.systemGray)
            newContfiguration?.baseForegroundColor = button.isSelected ? .systemBlue : .secondaryLabel
            button.configuration = newContfiguration
        }
        bookmarkButton.contentHorizontalAlignment = .left
        bookmarkButton.configuration = bookmarkButtonConfiguration
        bookmarkButton.addTarget(self, action: #selector(bookmarkButtonDidTap), for: .touchUpInside)
        bookmarkButton.isHidden = true
        
        var shareButtonConfiguration = UIButton.Configuration.reactionButton()
        shareButtonConfiguration.image = UIImage(systemName: "square.and.arrow.up")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.systemGray)
        shareButton.contentHorizontalAlignment = .left
        shareButton.configuration = shareButtonConfiguration
        shareButton.addTarget(self, action: #selector(shareButtonDidTap), for: .touchUpInside)
        shareButton.isHidden = true
    }
    
    @objc private func replyButtonDidTap() {
        Task {
            await actionHandler?(.reply)
        }
    }
    
    @objc private func reblogButtonDidTap() {
        reblogButton.isSelected.toggle()
        Task {
            let isCurrentlyReblog = configuration.reactionData.reblogged
            let isConfirmAction = await actionHandler?(.reblog(!isCurrentlyReblog)) ?? false
            let oldConfiguration = self.configuration
            
            let (newReblogCount, newIsReblogged): (Int, Bool) = {
                if isCurrentlyReblog && isConfirmAction {
                    return (oldConfiguration.reactionData.reblogsCount - 1, false)
                } else if !isCurrentlyReblog && isConfirmAction {
                    return (oldConfiguration.reactionData.reblogsCount + 1, true)
                }
                return (oldConfiguration.reactionData.reblogsCount, oldConfiguration.reactionData.reblogged)
            } ()
            
            let newConfiguration = Configuration(
                statusID: oldConfiguration.statusID,
                reactionData: Configuration.Reaction(
                    repliesCount: oldConfiguration.reactionData.repliesCount,
                    reblogsCount: newReblogCount,
                    reblogged: newIsReblogged,
                    favouritesCount: oldConfiguration.reactionData.favouritesCount,
                    favourited: oldConfiguration.reactionData.favourited,
                    bookmarked: oldConfiguration.reactionData.bookmarked),
                actionHandler: oldConfiguration.actionHandler)
            configure(with: newConfiguration)
        }
    }
    
    @objc private func favouriteButtonDidTap() {
        Task {
            let isFavorite = !configuration.reactionData.favourited
            let oldConfiguration = self.configuration
            let oldFavoriteCount = oldConfiguration.reactionData.favouritesCount
            let newFavoriteCount = isFavorite ? oldFavoriteCount + 1 : oldFavoriteCount - 1
            
            let newConfiguration = Configuration(
                statusID: oldConfiguration.statusID,
                reactionData: Configuration.Reaction(
                    repliesCount: oldConfiguration.reactionData.repliesCount,
                    reblogsCount: oldConfiguration.reactionData.reblogsCount,
                    reblogged: oldConfiguration.reactionData.reblogged,
                    favouritesCount: newFavoriteCount,
                    favourited: isFavorite,
                    bookmarked: oldConfiguration.reactionData.bookmarked),
                actionHandler: oldConfiguration.actionHandler)
            configure(with: newConfiguration)
            
            _ = await actionHandler?(.favourite(isFavorite, configuration.statusID))
            
        }
    }
    
    @objc private func bookmarkButtonDidTap() {
        Task {
            let isBookmark = !configuration.reactionData.bookmarked
            _ = await actionHandler?(.bookmark(isBookmark))
            let oldConfiguration = self.configuration
                    
            let newConfiguration = Configuration(
                statusID: oldConfiguration.statusID,
                reactionData: Configuration.Reaction(
                    repliesCount: oldConfiguration.reactionData.repliesCount,
                    reblogsCount: oldConfiguration.reactionData.reblogsCount,
                    reblogged: oldConfiguration.reactionData.reblogged,
                    favouritesCount: oldConfiguration.reactionData.favouritesCount,
                    favourited: oldConfiguration.reactionData.favourited,
                    bookmarked: isBookmark),
                actionHandler: oldConfiguration.actionHandler)
            configure(with: newConfiguration)
        }
    }
    
    @objc private func shareButtonDidTap() {
        Task {
            await actionHandler?(.share)
        }
    }
}

extension UIButton.Configuration {
    static func reactionButton() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = 4
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        configuration.baseForegroundColor = .secondaryLabel
        configuration.baseBackgroundColor = .clear
        let transformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.boldSystemFont(ofSize: 12)
            return outgoing
        }
        configuration.titleTextAttributesTransformer = transformer
        return configuration
    }
}
