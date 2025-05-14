////
////  StatusTemplateViewV2.swift
////  Elefant
////
////  Created by Wittawin Muangnoi on 30/4/2568 BE.
////
//
//import Foundation
//import UIKit
//import Combine
//import ElefantEntity
//import HTMLParser
//
//class StatusTemplateViewV2: UIView, MediaCollectionViewCellProvider {
//    private var appliedConfiguration: Configuration
//    
//    private let statusThreadView = StatusThreadView()
//    private let statusProfilePreview = StatusProfilePreview()
//    private let contentTextView = UITextView(usingTextLayoutManager: true)
//    private let statusReactionView = StatusReactionView()
//    
//    private var mediaView: MediaView?
//    
//    var hasVideo: Bool {
//        guard let mediaViewConfiguration = appliedConfiguration.mediaViewConfiguration else { return false }
//        return mediaViewConfiguration.mediaAttachments.contains {
//            if case .video = $0 { return true }
//            return false
//        }
//    }
//    
//    var mediaViewFrame: CGRect {
//        mediaContainerView.frame
//    }
//    
//    private lazy var mediaContainerConstraints: [NSLayoutConstraint] = [
//        mediaContainerView.leadingAnchor.constraint(equalTo: statusThreadView.trailingAnchor, constant: 12),
//        mediaContainerView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor),
//        mediaContainerView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
//        statusReactionView.topAnchor.constraint(equalTo: mediaContainerView.bottomAnchor, constant: 12),
//    ]
//
//    private lazy var noMediaContainerConstraints: [NSLayoutConstraint] = [
//        statusReactionView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 12),
//    ]
//
//    let mediaContainerView = UIView()
//    var statusID: String?
//    var statusWatcher: StatusWatcher?
//    var watcher: AnyStatusObserver?
//    
//    init(configuration: Configuration) {
//        appliedConfiguration = configuration
//        super.init(frame: .zero)
//        apply(configuration: configuration)
//        setupLayout()
//        setupView()
//    }
//    
//    struct Configuration: UIContentConfiguration {
//        let statusID: String
//        let statusThreadViewConfiguration: StatusThreadView.Configuration
//        let statusProfilePreviewConfiguration: StatusProfilePreview.Configuration
//        let statusReactionViewConfiguration: StatusReactionView.Configuration
//        let content: Content?
//        let mediaViewConfiguration: MediaViewConfiguration?
//        let statusWatcher: StatusWatcher
//        
//        func makeContentView() -> any UIView & UIContentView {
//            StatusTemplateViewV2(configuration: self)
//        }
//        
//        func updated(for state: any UIConfigurationState) -> StatusTemplateViewV2.Configuration {
//            self
//        }
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func updateConstraints() {
//        if let mediaViewConfiguration = appliedConfiguration.mediaViewConfiguration, !mediaViewConfiguration.mediaAttachments.isEmpty {
//            NSLayoutConstraint.activate(mediaContainerConstraints)
//            NSLayoutConstraint.deactivate(noMediaContainerConstraints)
//        } else {
//            NSLayoutConstraint.deactivate(mediaContainerConstraints)
//            NSLayoutConstraint.activate(noMediaContainerConstraints)
//        }
//        super.updateConstraints()
//    }
//    
//    private func setupLayout() {
//        layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
//        
//        addSubview(statusThreadView)
//        statusThreadView.translatesAutoresizingMaskIntoConstraints = false
//        
//        addSubview(statusProfilePreview)
//        statusProfilePreview.translatesAutoresizingMaskIntoConstraints = false
//        
//        addSubview(contentTextView)
//        contentTextView.translatesAutoresizingMaskIntoConstraints = false
//        
//        addSubview(statusReactionView)
//        statusReactionView.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            statusThreadView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
//            statusThreadView.topAnchor.constraint(equalTo: topAnchor),
//            statusThreadView.bottomAnchor.constraint(equalTo: bottomAnchor),
//        ])
//        
//        
//        let profilePreviewTrailingConstraint = statusProfilePreview.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
//        profilePreviewTrailingConstraint.priority = .required
//        NSLayoutConstraint.activate([
//            statusProfilePreview.leadingAnchor.constraint(equalTo: statusThreadView.trailingAnchor, constant: 12),
//            statusProfilePreview.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
//            profilePreviewTrailingConstraint,
//        ])
//        
//        
//        let contentTextViewTrailingConstraint = contentTextView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
//        contentTextViewTrailingConstraint.priority = .required
//        NSLayoutConstraint.activate([
//            contentTextView.leadingAnchor.constraint(equalTo: statusThreadView.trailingAnchor, constant: 12),
//            contentTextView.topAnchor.constraint(equalTo: statusProfilePreview.bottomAnchor),
//            contentTextViewTrailingConstraint,
//        ])
//        
////        if let mediaViewConfiguration = appliedConfiguration.mediaViewConfiguration, !mediaViewConfiguration.mediaAttachments.isEmpty {
////            addSubview(mediaContainerView)
////            addContentView(mediaView)
////            mediaContainerView.translatesAutoresizingMaskIntoConstraints = false
////            NSLayoutConstraint.activate(mediaContainerConstraints)
////            NSLayoutConstraint.deactivate(noMediaContainerConstraints)
////        } else {
////            NSLayoutConstraint.deactivate(mediaContainerConstraints)
////            NSLayoutConstraint.activate(noMediaContainerConstraints)
////        }
//        
//        let bottomConstraint = statusReactionView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
//        bottomConstraint.priority = .defaultHigh
//        let reactionViewTrailingConstraint = statusReactionView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
//        reactionViewTrailingConstraint.priority = .required
//        NSLayoutConstraint.activate([
//            statusReactionView.leadingAnchor.constraint(equalTo: statusThreadView.trailingAnchor, constant: 12),
//            reactionViewTrailingConstraint,
//            statusReactionView.heightAnchor.constraint(equalToConstant: 24),
//            bottomConstraint
//        ])
//        
//    }
//    
//    private func addContentView(_ view: UIView) {
//        mediaContainerView.addSubview(view)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            view.leadingAnchor.constraint(equalTo: mediaContainerView.leadingAnchor),
//            view.topAnchor.constraint(equalTo: mediaContainerView.topAnchor, constant: 8),
//            view.trailingAnchor.constraint(equalTo: mediaContainerView.trailingAnchor),
//            view.bottomAnchor.constraint(equalTo: mediaContainerView.bottomAnchor),
//        ])
//    }
//    
//    private func setupView() {
//        contentTextView.sizeToFit()
//        contentTextView.isScrollEnabled = false
//        contentTextView.font = .systemFont(ofSize: 14, weight: .regular)
//    }
//    
//    func cancelTask() {}
//    
//    func startPlayingMedia() {
//        mediaView?.startVideoPlayback()
//    }
//    
//    func stopPlayingMedia() {
//        mediaView?.stopVideoPlayback()
//    }
//}
//
//extension StatusTemplateViewV2: CancellableView {
//    func cancel() {
//        if let watcher {
//            statusWatcher?.removeObserver(watcher)
//        }
//        statusWatcher = nil
//        watcher = nil
//        cancelTask()
//    }
//}
//
//extension StatusTemplateViewV2: UIContentView {
//    var configuration: any UIContentConfiguration {
//        get { appliedConfiguration }
//        set(newValue) {
//            guard let configuration = newValue as? Configuration else { return }
//            apply(configuration: configuration)
//        }
//    }
//    
//    private func apply(configuration: Configuration) {
//        appliedConfiguration = configuration
//        
//        if let mediaViewConfiguration = configuration.mediaViewConfiguration, !mediaViewConfiguration.mediaAttachments.isEmpty {
//            if mediaView == nil {
//                let mediaView = MediaView(configuration: mediaViewConfiguration)
//                self.mediaView = mediaView
//                addSubview(mediaContainerView)
//                addContentView(mediaView)
//                mediaContainerView.translatesAutoresizingMaskIntoConstraints = false
//                
//            }
//            mediaView?.apply(configuration: mediaViewConfiguration)
//            setNeedsUpdateConstraints()
//        } else {
//            mediaView?.removeFromSuperview()
//            mediaView = nil
//            setNeedsUpdateConstraints()
//        }
//        
//        statusProfilePreview.configure(with: configuration.statusProfilePreviewConfiguration)
//        statusReactionView.configure(with: configuration.statusReactionViewConfiguration)
//        statusThreadView.configure(with: configuration.statusThreadViewConfiguration)
//        
//        let contentBuilder = HTMLAttributedStringContentBuilder { tag in
//            switch tag {
//            case .p: [
//                .font: UIFont.preferredFont(forTextStyle: .body),
//                .foregroundColor: UIColor.label,
//            ]
//            case .a: [
//                .font: UIFont.preferredFont(forTextStyle: .body),
//                .foregroundColor: UIColor.link,
//            ]
//            case .span: [
//                .font: UIFont.preferredFont(forTextStyle: .body),
//                .foregroundColor: UIColor.label,
//            ]
//            case ._unknown: [
//                .font: UIFont.preferredFont(forTextStyle: .body),
//                .foregroundColor: UIColor.label,
//            ]
//            }
//        }
//        contentTextView.attributedText = configuration.content?.createFormattedOutput(using: contentBuilder) ?? NSAttributedString("")
//        contentTextView.isEditable = false
//        contentTextView.textContainer.lineFragmentPadding = 0
//        
//        self.statusID = configuration.statusID
//        self.statusWatcher = configuration.statusWatcher
//        
//        
//        let watcher = AnyStatusObserver(statusID: configuration.statusID) { [weak self] status in
//            guard let self else { return }
//            let newConfiruration = Configuration(
//                statusID: status.id,
//                statusThreadViewConfiguration: StatusThreadView.Configuration(
//                    imageURL: status.account.avatar,
//                    actionHandler: configuration.statusThreadViewConfiguration.actionHandler),
//                statusProfilePreviewConfiguration: StatusProfilePreview.Configuration(
//                    displayName: status.account.displayName,
//                    attributedDisplayName: status.account.displayNameWithIcon,
//                    userName: status.account.username,
//                    createdAt: status.createdAt,
//                    actionHandler: configuration.statusProfilePreviewConfiguration.actionHandler),
//                statusReactionViewConfiguration: StatusReactionView.Configuration(
//                    statusID: status.id,
//                    reactionData: StatusReactionView.Configuration.Reaction(
//                        repliesCount: status.repliesCount,
//                        reblogsCount: status.reblogsCount,
//                        reblogged: status.reblogged ?? false,
//                        favouritesCount: status.favouritesCount,
//                        favourited: status.favourited ?? false,
//                        bookmarked: status.bookmarked ?? false),
//                    actionHandler: configuration.statusReactionViewConfiguration.actionHandler),
//                content: status.content?.value,
//                mediaViewConfiguration: status.mediaAttachments.isEmpty ? nil: MediaViewConfiguration(
//                    mediaAttachments: status.mediaAttachments.map { media in
//                        switch media.type {
//                        case .image:
//                            return .image(ImagePreviewConfiguration(
//                                previewURL: media.previewURL ?? "",
//                                blurhash: media.blurhash ?? "",
//                                aspect: media.meta?.small?.aspect ?? 0))
//                        case .video:
//                            return .video(VideoPreviewConfiguration(
//                                previewURL: media.previewURL ?? "",
//                                previewImageURL: media.previewURL ?? "",
//                                url: media.url,
//                                blurhash: media.blurhash ?? "",
//                                aspect: media.meta?.small?.aspect ?? 0))
//                        case .audio, .gifv, .unknown, ._unknown(_):
//                            return nil
//                        }
//                    }.compactMap { $0 }),
//                statusWatcher: configuration.statusWatcher)
//            
//            
//            statusProfilePreview.configure(with: newConfiruration.statusProfilePreviewConfiguration)
//            statusReactionView.configure(with: newConfiruration.statusReactionViewConfiguration)
//            
//            contentTextView.isEditable = false
//            contentTextView.dataDetectorTypes = [.all]
//            contentTextView.textContainer.lineFragmentPadding = 0
//        }
//        
//        self.watcher = watcher
//        statusWatcher?.addObserver(watcher)
//    }
//}
//
////@MainActor protocol StatusTemplateViewSubviewReusable {
////    func returnSubview()
////    func willDisplaySubview()
////    func prepareForReuseSubview()
////}
////
////class StatusTemplateViewV2: UIView, MediaCollectionViewCellProvider, StatusTemplateViewSubviewReusable {
////    private var appliedConfiguration: Configuration
////
//////    private let statusThreadView = StatusThreadView()
////    private let statusProfilePreview = StatusProfilePreview()
////    private let contentTextView = UITextView(usingTextLayoutManager: true)
////    private let statusReactionView = StatusReactionView()
////    private let mediaView = MediaView()
////
////    private var statusThreadView: StatusThreadView
////
////    var hasVideo: Bool {
////        guard let mediaViewConfiguration = appliedConfiguration.mediaViewConfiguration else { return false }
////        return mediaViewConfiguration.mediaAttachments.contains {
////            if case .video = $0 { return true }
////            return false
////        }
////    }
////
////    var mediaViewFrame: CGRect {
////        mediaContainerView.frame
////    }
////
////    private lazy var mediaContainerConstraints: [NSLayoutConstraint] = [
////        mediaContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 56),
////        mediaContainerView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor),
////        mediaContainerView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
////        statusReactionView.topAnchor.constraint(equalTo: mediaContainerView.bottomAnchor, constant: 12),
////    ]
////
////    private lazy var noMediaContainerConstraints: [NSLayoutConstraint] = [
////        statusReactionView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 12),
////    ]
////
////    let mediaContainerView = UIView()
////    var statusID: String?
////    var statusWatcher: StatusWatcher?
////    var watcher: AnyStatusObserver?
////
////    init(configuration: Configuration) {
////        appliedConfiguration = configuration
////        configuration.subviewPool.register({ StatusThreadView() }, for: "status-template-view")
////
////        statusThreadView = configuration.subviewPool.dequeueReusableView(for: "status-template-view") as? StatusThreadView ?? StatusThreadView()
////        super.init(frame: .zero)
////        apply(configuration: configuration)
////        setupLayout()
////        setupView()
////    }
////
////    struct Configuration: UIContentConfiguration {
////        let statusID: String
////        let statusThreadViewConfiguration: StatusThreadView.Configuration
////        let statusProfilePreviewConfiguration: StatusProfilePreview.Configuration
////        let statusReactionViewConfiguration: StatusReactionView.Configuration
////        let content: Content?
////        let mediaViewConfiguration: MediaViewConfiguration?
////        let statusWatcher: StatusWatcher
////        let subviewPool: ObjectPool
////
////        func makeContentView() -> any UIView & UIContentView {
////            StatusTemplateViewV2(configuration: self)
////        }
////
////        func updated(for state: any UIConfigurationState) -> StatusTemplateViewV2.Configuration {
////            self
////        }
////    }
////
////    required init?(coder: NSCoder) {
////        fatalError("init(coder:) has not been implemented")
////    }
////
////    override func updateConstraints() {
////        if let mediaViewConfiguration = appliedConfiguration.mediaViewConfiguration, !mediaViewConfiguration.mediaAttachments.isEmpty {
////            NSLayoutConstraint.activate(mediaContainerConstraints)
////            NSLayoutConstraint.deactivate(noMediaContainerConstraints)
////        } else {
////            NSLayoutConstraint.deactivate(mediaContainerConstraints)
////            NSLayoutConstraint.activate(noMediaContainerConstraints)
////        }
////        super.updateConstraints()
////    }
////
////    private func setupLayout() {
////        layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
////
////        addSubview(statusThreadView)
////        statusThreadView.translatesAutoresizingMaskIntoConstraints = false
////
////        addSubview(statusProfilePreview)
////        statusProfilePreview.translatesAutoresizingMaskIntoConstraints = false
////
////        addSubview(contentTextView)
////        contentTextView.translatesAutoresizingMaskIntoConstraints = false
////
////        addSubview(statusReactionView)
////        statusReactionView.translatesAutoresizingMaskIntoConstraints = false
////
////        NSLayoutConstraint.activate([
////            statusThreadView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
////            statusThreadView.topAnchor.constraint(equalTo: topAnchor),
////            statusThreadView.bottomAnchor.constraint(equalTo: bottomAnchor),
////        ])
////
////
////        let profilePreviewTrailingConstraint = statusProfilePreview.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
////        profilePreviewTrailingConstraint.priority = .required
////        NSLayoutConstraint.activate([
////            statusProfilePreview.leadingAnchor.constraint(equalTo: statusThreadView.trailingAnchor, constant: 12),
////            statusProfilePreview.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
////            profilePreviewTrailingConstraint,
////        ])
////
////
////        let contentTextViewTrailingConstraint = contentTextView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
////        contentTextViewTrailingConstraint.priority = .required
////        NSLayoutConstraint.activate([
////            contentTextView.leadingAnchor.constraint(equalTo: statusThreadView.trailingAnchor, constant: 12),
////            contentTextView.topAnchor.constraint(equalTo: statusProfilePreview.bottomAnchor),
////            contentTextViewTrailingConstraint,
////        ])
////
////        if let mediaViewConfiguration = appliedConfiguration.mediaViewConfiguration, !mediaViewConfiguration.mediaAttachments.isEmpty {
////            addSubview(mediaContainerView)
////            addContentView(mediaView)
////            mediaContainerView.translatesAutoresizingMaskIntoConstraints = false
////            NSLayoutConstraint.activate(mediaContainerConstraints)
////            NSLayoutConstraint.deactivate(noMediaContainerConstraints)
////        } else {
////            NSLayoutConstraint.deactivate(mediaContainerConstraints)
////            NSLayoutConstraint.activate(noMediaContainerConstraints)
////        }
////
////        let bottomConstraint = statusReactionView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
////        bottomConstraint.priority = .defaultHigh
////        let reactionViewTrailingConstraint = statusReactionView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
////        reactionViewTrailingConstraint.priority = .required
////        NSLayoutConstraint.activate([
////            statusReactionView.leadingAnchor.constraint(equalTo: statusThreadView.trailingAnchor, constant: 12),
////            reactionViewTrailingConstraint,
////            statusReactionView.heightAnchor.constraint(equalToConstant: 24),
////            bottomConstraint
////        ])
////
////    }
////
////    private func addContentView(_ view: UIView) {
////        mediaContainerView.addSubview(view)
////        view.translatesAutoresizingMaskIntoConstraints = false
////        NSLayoutConstraint.activate([
////            view.leadingAnchor.constraint(equalTo: mediaContainerView.leadingAnchor),
////            view.topAnchor.constraint(equalTo: mediaContainerView.topAnchor, constant: 8),
////            view.trailingAnchor.constraint(equalTo: mediaContainerView.trailingAnchor),
////            view.bottomAnchor.constraint(equalTo: mediaContainerView.bottomAnchor),
////        ])
////    }
////
////    private func setupView() {
////        contentTextView.sizeToFit()
////        contentTextView.isScrollEnabled = false
////        contentTextView.font = .systemFont(ofSize: 14, weight: .regular)
////    }
////
////    func cancelTask() {}
////
////    func startPlayingMedia() {
////        mediaView.startVideoPlayback()
////    }
////
////    func stopPlayingMedia() {
////        mediaView.stopVideoPlayback()
////    }
////}
////
////extension StatusTemplateViewV2: CancellableView {
////    func cancel() {
////        if let watcher {
////            statusWatcher?.removeObserver(watcher)
////        }
////        statusWatcher = nil
////        watcher = nil
////        cancelTask()
////    }
////}
////
////extension StatusTemplateViewV2: UIContentView {
////    var configuration: any UIContentConfiguration {
////        get { appliedConfiguration }
////        set(newValue) {
////            guard let configuration = newValue as? Configuration else { return }
////            apply(configuration: configuration)
////        }
////    }
////
////    private func apply(configuration: Configuration) {
////        appliedConfiguration = configuration
////
////        if let mediaViewConfiguration = configuration.mediaViewConfiguration, !mediaViewConfiguration.mediaAttachments.isEmpty {
////            addSubview(mediaContainerView)
////            addContentView(mediaView)
////            mediaContainerView.translatesAutoresizingMaskIntoConstraints = false
////            mediaView.apply(configuration: mediaViewConfiguration)
////            setNeedsUpdateConstraints()
////        } else {
////            mediaView.removeFromSuperview()
////            setNeedsUpdateConstraints()
////        }
////
////        statusProfilePreview.configure(with: configuration.statusProfilePreviewConfiguration)
////        statusReactionView.configure(with: configuration.statusReactionViewConfiguration)
////        statusThreadView.configure(with: configuration.statusThreadViewConfiguration)
////
////        let contentBuilder = HTMLAttributedStringContentBuilder { tag in
////            switch tag {
////            case .p: [
////                .font: UIFont.preferredFont(forTextStyle: .body),
////                .foregroundColor: UIColor.label,
////            ]
////            case .a: [
////                .font: UIFont.preferredFont(forTextStyle: .body),
////                .foregroundColor: UIColor.link,
////            ]
////            case .span: [
////                .font: UIFont.preferredFont(forTextStyle: .body),
////                .foregroundColor: UIColor.label,
////            ]
////            case ._unknown: [
////                .font: UIFont.preferredFont(forTextStyle: .body),
////                .foregroundColor: UIColor.label,
////            ]
////            }
////        }
////        contentTextView.attributedText = configuration.content?.createFormattedOutput(using: contentBuilder) ?? NSAttributedString("")
////        contentTextView.isEditable = false
////        contentTextView.textContainer.lineFragmentPadding = 0
////
////        self.statusID = configuration.statusID
////        self.statusWatcher = configuration.statusWatcher
////
////        let watcher = AnyStatusObserver(statusID: configuration.statusID) { [weak self] status in
////            guard let self else { return }
////            let newConfiruration = Configuration(
////                statusID: status.id,
////                statusThreadViewConfiguration: StatusThreadView.Configuration(
////                    imageURL: status.account.avatar,
////                    actionHandler: configuration.statusThreadViewConfiguration.actionHandler),
////                statusProfilePreviewConfiguration: StatusProfilePreview.Configuration(
////                    displayName: status.account.displayName,
////                    attributedDisplayName: status.account.displayNameWithIcon,
////                    userName: status.account.username,
////                    createdAt: status.createdAt,
////                    actionHandler: configuration.statusProfilePreviewConfiguration.actionHandler),
////                statusReactionViewConfiguration: StatusReactionView.Configuration(
////                    statusID: status.id,
////                    reactionData: StatusReactionView.Configuration.Reaction(
////                        repliesCount: status.repliesCount,
////                        reblogsCount: status.reblogsCount,
////                        reblogged: status.reblogged ?? false,
////                        favouritesCount: status.favouritesCount,
////                        favourited: status.favourited ?? false,
////                        bookmarked: status.bookmarked ?? false),
////                    actionHandler: configuration.statusReactionViewConfiguration.actionHandler),
////                content: status.content?.value,
////                mediaViewConfiguration: status.mediaAttachments.isEmpty ? nil: MediaViewConfiguration(
////                    mediaAttachments: status.mediaAttachments.map { media in
////                        switch media.type {
////                        case .image:
////                            return .image(ImagePreviewConfiguration(
////                                previewURL: media.previewURL ?? "",
////                                blurhash: media.blurhash ?? "",
////                                aspect: media.meta?.small?.aspect ?? 0))
////                        case .video:
////                            return .video(VideoPreviewConfiguration(
////                                previewURL: media.previewURL ?? "",
////                                previewImageURL: media.previewURL ?? "",
////                                url: media.url,
////                                blurhash: media.blurhash ?? "",
////                                aspect: media.meta?.small?.aspect ?? 0))
////                        case .audio, .gifv, .unknown, ._unknown(_):
////                            return nil
////                        }
////                    }.compactMap { $0 }),
////                statusWatcher: configuration.statusWatcher, subviewPool: ObjectPool())
////
////
////            statusProfilePreview.configure(with: newConfiruration.statusProfilePreviewConfiguration)
////            statusReactionView.configure(with: newConfiruration.statusReactionViewConfiguration)
////
////            contentTextView.isEditable = false
////            contentTextView.textContainer.lineFragmentPadding = 0
////        }
////
////        self.watcher = watcher
////        statusWatcher?.addObserver(watcher)
////    }
////
////    func returnSubview() {
////        statusThreadView.imageTask?.cancel()
////        appliedConfiguration.subviewPool.returnObject(statusThreadView, identifier: "status-template-view")
////    }
////
////    func willDisplaySubview() {
////        statusThreadView = appliedConfiguration.subviewPool.dequeueReusableView(for: "status-template-view") as? StatusThreadView ?? StatusThreadView()
////    }
////
////    func prepareForReuseSubview() {
////        statusThreadView.imageTask?.cancel()
////    }
////}
//
////
////  StatusProfilePreview.swift
////  Elefant
////
////  Created by Wittawin Muangnoi on 8/4/2568 BE.
////
//
//import Foundation
//import UIKit
//import ElefantEntity
//
//private let kProfileImageViewSize: CGFloat = 44
//
//class StatusProfilePreview: UIView {
//    private let profileTitleStackView = UIStackView()
//    private let profileTitleLabel = UILabel()
//    private let profileDescriptionLabel = UILabel()
//    private let menuButton = UIButton()
//    private var actionHandler: ActionHandler?
//        
//    struct ActionHandler {
//        let profileTitleTapHandler: (() -> Void)?
//        let menuButtonTapHandler: (() -> Void)?
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        layoutMargins = .zero
//        setupLayout()
//        setupView()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    struct Configuration {
//        let displayName: String
//        let attributedDisplayName: ([NSAttributedString.Key: Any]) -> AttributedString?
//        let userName: String
//        let createdAt: Date
//        let actionHandler: ActionHandler?
//    }
//    
//    func configure(with configuration: Configuration) {
//        actionHandler = configuration.actionHandler
//        profileTitleLabel.attributedText = createProfileTitleAttributedString(
//            profileName: configuration.displayName,
//            attributedDisplayName: configuration.attributedDisplayName([
//                .font: UIFont.preferredFont(forTextStyle: .headline)
//            ]),
//            userName: configuration.userName)
////        profileDescriptionLabel.text = configuration.createdAt.formatted(date: .complete, time: .shortened)
//        profileDescriptionLabel.text = configuration.createdAt.formattedSinceDate()
//    }
//    
//    private func setupView() {
//        profileTitleLabel.numberOfLines = 1
//        
//        profileDescriptionLabel.numberOfLines = 1
//        profileDescriptionLabel.font = .preferredFont(forTextStyle: .subheadline)
//        profileDescriptionLabel.textColor = .secondaryLabel
//        
//        let profileTitleTapGesture = UITapGestureRecognizer(target: self, action: #selector(onProfileTitleTapped))
//        profileTitleLabel.addGestureRecognizer(profileTitleTapGesture)
//        
//        let profileDescriptionTapGesture = UITapGestureRecognizer(target: self, action: #selector(onProfileTitleTapped))
//        profileDescriptionLabel.addGestureRecognizer(profileDescriptionTapGesture)
//        
//        profileTitleStackView.axis = .vertical
//        profileTitleStackView.spacing = 2
//    }
//    
//    private func setupLayout() {
//        addSubview(profileTitleStackView)
//        profileTitleStackView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            profileTitleStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
//            profileTitleStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
//            profileTitleStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
//        ])
//        
//        profileTitleStackView.addArrangedSubview(profileTitleLabel)
//        profileTitleStackView.addArrangedSubview(profileDescriptionLabel)
//        
//        addSubview(menuButton)
//        menuButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            menuButton.leadingAnchor.constraint(equalTo: profileDescriptionLabel.trailingAnchor),
//            menuButton.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
//            menuButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
//            menuButton.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
//            menuButton.widthAnchor.constraint(equalToConstant: 60)
//        ])
//    }
//    
//    @MainActor private func createProfileTitleAttributedString(profileName: String, attributedDisplayName: AttributedString?, userName: String) -> NSAttributedString {
//        let userNameAttributedString  = NSMutableAttributedString(string: " @\(userName)", attributes: [
//            .foregroundColor: UIColor.secondaryLabel,
//            .font: UIFont.preferredFont(forTextStyle: .subheadline)
//        ])
//        
//        if let attributedDisplayName {
//            let newAttributedDisplayName = NSMutableAttributedString(attributedDisplayName)
//            newAttributedDisplayName.append(userNameAttributedString)
//            return newAttributedDisplayName
//        }
//        
//        let profileNameAttributedString = NSMutableAttributedString(string: profileName, attributes: [
//            .foregroundColor: UIColor.label,
//            .font: UIFont.preferredFont(forTextStyle: .headline)
//        ])
//        
//        profileNameAttributedString.append(userNameAttributedString)
//        return profileNameAttributedString
//    }
//}
//
//extension StatusProfilePreview {
//    @objc private func onProfileTitleTapped() {
//        actionHandler?.profileTitleTapHandler?()
//    }
//    
//    @objc private func onMenuButtonTapped() {
//        actionHandler?.menuButtonTapHandler?()
//    }
//}
//
//
////
////  StatusReactionView.swift
////  Elefant
////
////  Created by Wittawin Muangnoi on 8/4/2568 BE.
////
//
//import Foundation
//import UIKit
//
//class StatusReactionView: UIView {
//    private let stackView = UIStackView()
//    private let replyButton = UIButton(type: .custom)
//    private let reblogButton = UIButton(type: .custom)
//    private let favouriteButton = UIButton(type: .custom)
//    private let bookmarkButton = UIButton(type: .custom)
//    private let shareButton = UIButton(type: .custom)
//    private var actionHandler: ActionHandler?
//
//    
//    typealias ActionHandler = (Action) async -> Bool
//    
//    enum Action {
//        case reply
//        case reblog(Bool)
//        case favourite(Bool, String)
//        case bookmark(Bool)
//        case share
//    }
//    
//    private var configuration: Configuration = Configuration(
//        statusID: "",
//        reactionData: Configuration.Reaction(
//            repliesCount: 0,
//            reblogsCount: 0,
//            reblogged: false,
//            favouritesCount: 0,
//            favourited: false,
//            bookmarked: false),
//        actionHandler: nil)
//    
//    struct Configuration: Hashable {
//        let statusID: String
//        struct Reaction: Hashable {
//            let repliesCount: Int
//            let reblogsCount: Int
//            let reblogged: Bool
//            let favouritesCount: Int
//            let favourited: Bool
//            let bookmarked: Bool
//        }
//        let reactionData: Reaction
//        let actionHandler: ActionHandler?
//        
//        static func == (lhs: StatusReactionView.Configuration, rhs: StatusReactionView.Configuration) -> Bool {
//            return lhs.reactionData == rhs.reactionData
//        }
//        
//        func hash(into hasher: inout Hasher) {
//            hasher.combine(reactionData)
//        }
//    }
//    
//    func configure(with configuration: Configuration) {
//        self.configuration = configuration
//        actionHandler = configuration.actionHandler
//
//        let reactionData = configuration.reactionData
//        replyButton.setTitle(reactionData.repliesCount.formattedShort, for: .normal)
//        
//        reblogButton.setTitle(reactionData.repliesCount.formattedShort, for: .normal)
//        reblogButton.isSelected = configuration.reactionData.reblogged
//        
//        favouriteButton.setTitle(reactionData.favouritesCount.formattedShort, for: .normal)
//        favouriteButton.isSelected = configuration.reactionData.favourited
//        
//        bookmarkButton.isSelected = configuration.reactionData.bookmarked
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupLayout()
//        setupView()
//    }
//    
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupLayout() {
//        addSubview(stackView)
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            stackView.topAnchor.constraint(equalTo: topAnchor),
//            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
//            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
//        ])
//        
//        stackView.addArrangedSubview(replyButton)
//        replyButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        stackView.addArrangedSubview(reblogButton)
//        reblogButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        stackView.addArrangedSubview(favouriteButton)
//        favouriteButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        stackView.addArrangedSubview(bookmarkButton)
//        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        stackView.addArrangedSubview(shareButton)
//        shareButton.translatesAutoresizingMaskIntoConstraints = false
//    }
//    
//    private func setupView() {
//        stackView.distribution = .fillProportionally
//        stackView.spacing = 24
//        
//        var replyButtonConfiguration = UIButton.Configuration.reactionButton()
//        replyButtonConfiguration.image = UIImage(systemName: "text.bubble")?
//            .withRenderingMode(.alwaysOriginal)
//            .withTintColor(.systemGray)
//        replyButton.contentHorizontalAlignment = .left
//        replyButton.configuration = replyButtonConfiguration
//        replyButton.addTarget(self, action: #selector(replyButtonDidTap), for: .touchUpInside)
//        
//        let reblogButtonImage = UIImage(systemName: "repeat")
//        var reblogButtonConfiguration = UIButton.Configuration.reactionButton()
//        reblogButtonConfiguration.image = reblogButtonImage?
//            .withRenderingMode(.alwaysOriginal)
//            .withTintColor(.systemGray)
//        reblogButtonConfiguration.imageReservation = 16
//        reblogButton.configurationUpdateHandler = { button in
//            var newContfiguration = button.configuration
//            newContfiguration?.baseForegroundColor = button.isSelected ? .systemGreen : .secondaryLabel
//            newContfiguration?.image = button.isSelected ?
//                reblogButtonImage?
//                    .withRenderingMode(.alwaysOriginal)
//                    .withTintColor(.systemGreen)
//                : reblogButtonImage?
//                    .withRenderingMode(.alwaysOriginal)
//                    .withTintColor(.systemGray)
//            button.configuration = newContfiguration
//        }
//        reblogButton.contentHorizontalAlignment = .left
//        reblogButton.configuration = reblogButtonConfiguration
//        reblogButton.addTarget(self, action: #selector(reblogButtonDidTap), for: .touchUpInside)
//        
//        var favouriteButtonConfiguration = UIButton.Configuration.reactionButton()
//        favouriteButtonConfiguration.image = UIImage(systemName: "heart")?
//            .withRenderingMode(.alwaysOriginal)
//            .withTintColor(.systemGray)
//        favouriteButton.configurationUpdateHandler = { button in
//            var newContfiguration = button.configuration
//            newContfiguration?.image = button.isSelected ?
//                UIImage(systemName: "heart.fill")?
//                    .withRenderingMode(.alwaysOriginal)
//                    .withTintColor(.systemRed)
//                : UIImage(systemName: "heart")?
//                    .withRenderingMode(.alwaysOriginal)
//                    .withTintColor(.systemGray)
//            newContfiguration?.baseForegroundColor = button.isSelected ? .systemRed : .secondaryLabel
//            button.configuration = newContfiguration
//        }
//        favouriteButton.contentHorizontalAlignment = .left
//        favouriteButton.configuration = favouriteButtonConfiguration
//        favouriteButton.addTarget(self, action: #selector(favouriteButtonDidTap), for: .touchUpInside)
//        
//        var bookmarkButtonConfiguration = UIButton.Configuration.reactionButton()
//        bookmarkButtonConfiguration.image =  UIImage(systemName: "bookmark")?
//            .withRenderingMode(.alwaysOriginal)
//            .withTintColor(.systemGray)
//        bookmarkButton.configurationUpdateHandler = { button in
//            var newContfiguration = button.configuration
//            newContfiguration?.image = button.isSelected ? UIImage(systemName: "bookmark.fill")?
//                .withRenderingMode(.alwaysOriginal)
//                .withTintColor(.systemBlue)
//            : UIImage(systemName: "bookmark")?
//                .withRenderingMode(.alwaysOriginal)
//                .withTintColor(.systemGray)
//            newContfiguration?.baseForegroundColor = button.isSelected ? .systemBlue : .secondaryLabel
//            button.configuration = newContfiguration
//        }
//        bookmarkButton.contentHorizontalAlignment = .left
//        bookmarkButton.configuration = bookmarkButtonConfiguration
//        bookmarkButton.addTarget(self, action: #selector(bookmarkButtonDidTap), for: .touchUpInside)
//        bookmarkButton.isHidden = true
//        
//        var shareButtonConfiguration = UIButton.Configuration.reactionButton()
//        shareButtonConfiguration.image = UIImage(systemName: "square.and.arrow.up")?
//            .withRenderingMode(.alwaysOriginal)
//            .withTintColor(.systemGray)
//        shareButton.contentHorizontalAlignment = .left
//        shareButton.configuration = shareButtonConfiguration
//        shareButton.addTarget(self, action: #selector(shareButtonDidTap), for: .touchUpInside)
//        shareButton.isHidden = true
//    }
//    
//    @objc private func replyButtonDidTap() {
//        Task {
//            await actionHandler?(.reply)
//        }
//    }
//    
//    @objc private func reblogButtonDidTap() {
//        reblogButton.isSelected.toggle()
//        Task {
//            let isCurrentlyReblog = configuration.reactionData.reblogged
//            let isConfirmAction = await actionHandler?(.reblog(!isCurrentlyReblog)) ?? false
//            let oldConfiguration = self.configuration
//            
//            let (newReblogCount, newIsReblogged): (Int, Bool) = {
//                if isCurrentlyReblog && isConfirmAction {
//                    return (oldConfiguration.reactionData.reblogsCount - 1, false)
//                } else if !isCurrentlyReblog && isConfirmAction {
//                    return (oldConfiguration.reactionData.reblogsCount + 1, true)
//                }
//                return (oldConfiguration.reactionData.reblogsCount, oldConfiguration.reactionData.reblogged)
//            } ()
//            
//            let newConfiguration = Configuration(
//                statusID: oldConfiguration.statusID,
//                reactionData: Configuration.Reaction(
//                    repliesCount: oldConfiguration.reactionData.repliesCount,
//                    reblogsCount: newReblogCount,
//                    reblogged: newIsReblogged,
//                    favouritesCount: oldConfiguration.reactionData.favouritesCount,
//                    favourited: oldConfiguration.reactionData.favourited,
//                    bookmarked: oldConfiguration.reactionData.bookmarked),
//                actionHandler: oldConfiguration.actionHandler)
//            configure(with: newConfiguration)
//        }
//    }
//    
//    @objc private func favouriteButtonDidTap() {
//        Task {
//            let isFavorite = !configuration.reactionData.favourited
//            let oldConfiguration = self.configuration
//            let oldFavoriteCount = oldConfiguration.reactionData.favouritesCount
//            let newFavoriteCount = isFavorite ? oldFavoriteCount + 1 : oldFavoriteCount - 1
//            
//            let newConfiguration = Configuration(
//                statusID: oldConfiguration.statusID,
//                reactionData: Configuration.Reaction(
//                    repliesCount: oldConfiguration.reactionData.repliesCount,
//                    reblogsCount: oldConfiguration.reactionData.reblogsCount,
//                    reblogged: oldConfiguration.reactionData.reblogged,
//                    favouritesCount: newFavoriteCount,
//                    favourited: isFavorite,
//                    bookmarked: oldConfiguration.reactionData.bookmarked),
//                actionHandler: oldConfiguration.actionHandler)
//            configure(with: newConfiguration)
//            
//            _ = await actionHandler?(.favourite(isFavorite, configuration.statusID))
//            
//        }
//    }
//    
//    @objc private func bookmarkButtonDidTap() {
//        Task {
//            let isBookmark = !configuration.reactionData.bookmarked
//            _ = await actionHandler?(.bookmark(isBookmark))
//            let oldConfiguration = self.configuration
//                    
//            let newConfiguration = Configuration(
//                statusID: oldConfiguration.statusID,
//                reactionData: Configuration.Reaction(
//                    repliesCount: oldConfiguration.reactionData.repliesCount,
//                    reblogsCount: oldConfiguration.reactionData.reblogsCount,
//                    reblogged: oldConfiguration.reactionData.reblogged,
//                    favouritesCount: oldConfiguration.reactionData.favouritesCount,
//                    favourited: oldConfiguration.reactionData.favourited,
//                    bookmarked: isBookmark),
//                actionHandler: oldConfiguration.actionHandler)
//            configure(with: newConfiguration)
//        }
//    }
//    
//    @objc private func shareButtonDidTap() {
//        Task {
//            await actionHandler?(.share)
//        }
//    }
//}
