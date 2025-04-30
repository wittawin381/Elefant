//
//  StatusTemplateView.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 8/4/2568 BE.
//

import Foundation
import UIKit
import Combine
import ElefantEntity
import HTMLParser

class StatusTemplateView: UIView {
    private let statusThreadView = StatusThreadView()
    private let statusProfilePreview = StatusProfilePreview()
    private let contentTextView = UITextView(usingTextLayoutManager: true)
    private let statusReactionView = StatusReactionView()
    private let defaultView = UIView()

    let mediaContainerView = UIView()
    var contentView: UIView { defaultView }
    
    var statusID: String?
    var statusWatcher: StatusWatcher?
    var watcher: AnyStatusObserver?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupView()
    }
    
    struct Configuration {
        let statusID: String
        let statusThreadViewConfiguration: StatusThreadView.Configuration
        let statusProfilePreviewConfiguration: StatusProfilePreview.Configuration
        let statusReactionViewConfiguration: StatusReactionView.Configuration
        let content: Content?
    }
    
    @MainActor func configure(with configuration: Configuration, statusWatcher: StatusWatcher) {
        statusProfilePreview.configure(with: configuration.statusProfilePreviewConfiguration)
        statusReactionView.configure(with: configuration.statusReactionViewConfiguration)
        statusThreadView.configure(with: configuration.statusThreadViewConfiguration)
        
        let contentBuilder = HTMLAttributedStringContentBuilder { tag in
            
            switch tag {
            case .p: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.label,
            ]
            case .a: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.link,
            ]
            case .span: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.label,
            ]
            case ._unknown: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.label,
            ]
            }
        }
        contentTextView.attributedText = configuration.content?.createFormattedOutput(using: contentBuilder) ?? NSAttributedString("")
        contentTextView.isEditable = false
        contentTextView.textContainer.lineFragmentPadding = 0
        
        self.statusID = configuration.statusID
        self.statusWatcher = statusWatcher
        
        
        let watcher = AnyStatusObserver(statusID: configuration.statusID) { [weak self] status in
            guard let self else { return }
            let newConfiruration = Configuration(
                statusID: status.id,
                statusThreadViewConfiguration: StatusThreadView.Configuration(
                    imageURL: status.account.avatar,
                    actionHandler: configuration.statusThreadViewConfiguration.actionHandler),
                statusProfilePreviewConfiguration: StatusProfilePreview.Configuration(
                    displayName: status.account.displayName,
                    attributedDisplayName: status.account.displayNameWithIcon,
                    userName: status.account.username,
                    description: status.createdAt.formatted(date: .complete, time: .shortened),
                    actionHandler: configuration.statusProfilePreviewConfiguration.actionHandler),
                statusReactionViewConfiguration: StatusReactionView.Configuration(
                    statusID: status.id,
                    reactionData: StatusReactionView.Configuration.Reaction(
                        repliesCount: status.repliesCount,
                        reblogsCount: status.reblogsCount,
                        reblogged: status.reblogged ?? false,
                        favouritesCount: status.favouritesCount,
                        favourited: status.favourited ?? false,
                        bookmarked: status.bookmarked ?? false),
                    actionHandler: configuration.statusReactionViewConfiguration.actionHandler),
                content: status.content?.value)
            
            
            statusProfilePreview.configure(with: newConfiruration.statusProfilePreviewConfiguration)
            statusReactionView.configure(with: newConfiruration.statusReactionViewConfiguration)
            
            contentTextView.isEditable = false
            contentTextView.dataDetectorTypes = [.all]
            contentTextView.textContainer.lineFragmentPadding = 0
        }
        self.watcher = watcher
        statusWatcher.addObserver(watcher)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
        
        addSubview(statusThreadView)
        statusThreadView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusThreadView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            statusThreadView.topAnchor.constraint(equalTo: topAnchor),
            statusThreadView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        addSubview(statusProfilePreview)
        statusProfilePreview.translatesAutoresizingMaskIntoConstraints = false
        let profilePreviewTrailingConstraint = statusProfilePreview.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        profilePreviewTrailingConstraint.priority = .required
        NSLayoutConstraint.activate([
            statusProfilePreview.leadingAnchor.constraint(equalTo: statusThreadView.trailingAnchor, constant: 12),
            statusProfilePreview.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            profilePreviewTrailingConstraint,
        ])
        
        addSubview(contentTextView)
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        let contentTextViewTrailingConstraint = contentTextView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        contentTextViewTrailingConstraint.priority = .required
        NSLayoutConstraint.activate([
            contentTextView.leadingAnchor.constraint(equalTo: statusThreadView.trailingAnchor, constant: 12),
            contentTextView.topAnchor.constraint(equalTo: statusProfilePreview.bottomAnchor),
            contentTextViewTrailingConstraint,
        ])
        
        addSubview(mediaContainerView)
        mediaContainerView.translatesAutoresizingMaskIntoConstraints = false
        let mediaContainerViewTrailingConstraint = mediaContainerView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        mediaContainerViewTrailingConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            mediaContainerView.leadingAnchor.constraint(equalTo: statusThreadView.trailingAnchor, constant: 12),
            mediaContainerView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor),
            mediaContainerViewTrailingConstraint,
        ])
        
        addContentView(contentView)
        
        addSubview(statusReactionView)
        statusReactionView.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = statusReactionView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        bottomConstraint.priority = .defaultHigh
        let reactionViewTrailingConstraint = statusReactionView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        reactionViewTrailingConstraint.priority = .required
        NSLayoutConstraint.activate([
            statusReactionView.leadingAnchor.constraint(equalTo: statusThreadView.trailingAnchor, constant: 12),
            statusReactionView.topAnchor.constraint(equalTo: mediaContainerView.bottomAnchor, constant: 12),
            reactionViewTrailingConstraint,
            statusReactionView.heightAnchor.constraint(equalToConstant: 24),
            bottomConstraint
        ])
        
    }
    
    private func addContentView(_ view: UIView) {
        mediaContainerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: mediaContainerView.leadingAnchor),
            view.topAnchor.constraint(equalTo: mediaContainerView.topAnchor, constant: 8),
            view.trailingAnchor.constraint(equalTo: mediaContainerView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: mediaContainerView.bottomAnchor),
        ])
    }
    
    private func setupView() {
        contentTextView.sizeToFit()
        contentTextView.isScrollEnabled = false
        contentTextView.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    func cancelTask() {}
}

extension StatusTemplateView: CancellableView {
    func cancel() {
        if let watcher {
            statusWatcher?.removeObserver(watcher)
        }
        statusWatcher = nil
        watcher = nil
        cancelTask()
    }
}
