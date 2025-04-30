//
//  TimelineAsyncDataSource.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 10/4/2568 BE.
//

import Foundation
import UIKit
import ElefantEntity
import ElefantAPI
import Combine

enum TimelineRequestType {
    case `public`(local: Bool?, remote: Bool?, onlyMedia: Bool?)
    case hashtag(any: [String]?, all: [String]?, none: [String]?, local: Bool?, remote: Bool?, onlyMedia: Bool?)
    case home
    case link(url: String)
    case list(id: String)
    
    var title: String {
        switch self {
        case .public(_, _, _):
            "public"
        case .hashtag(_, _, _, _, _, _):
            "hashtag"
        case .home:
            "following"
        case let .link(url):
            url
        case .list(_):
            "list"
        }
    }
}

@MainActor class TimelineInternalDataController {
    init(timelineAsyncDataSource: TimelineAsyncDataSource,
         client: any NetworkClient) {
        self.client = client
        self.timelineAsyncDataSource = timelineAsyncDataSource
    }
    
    struct Section: Hashable, Identifiable {
        enum SectionType: Hashable {
            case singleRowItem(String)
            case loadMore(String)
        }
        
        var id: SectionType {
            sectionType
        }
        
        let sectionType: SectionType
        let headerType: HeaderType
        let footerType: FooterType
        
        enum HeaderType {
            case none
        }
        
        enum FooterType {
            case none
        }
    }
    
    enum Item: Hashable, Identifiable {
        var id: String {
            switch self {
            case let .timeline(id):
                id
            case let .loadMore(id):
                id
            }
        }
        
        case timeline(Status.ID)
        case loadMore(String)
    }
    
    private let client: any NetworkClient
    private let timelineAsyncDataSource: TimelineAsyncDataSource
    private let statusStore = AnyModelStore<Status>()
    private let sectionStore = AnyModelStore<Section>()
    private var task: Task<[Status], Error>?

    var dataSource: UICollectionViewDiffableDataSource<Section.ID, Item>?
    
    var firstID: String?
    var lastID: String?
    
    struct Pagination {
        let sinceID: String?
        let maxID: String?
        let minID: String?
        let limit: Int
    }
        
    func fetchMore(limit: Int?, request: TimelineRequestType) async throws {
        guard task == nil || task?.isCancelled == true else { return }
        let pagination = Pagination(
            sinceID: nil,
            maxID: lastID,
            minID: nil,
            limit: limit ?? 20)
        let task = Task {
            try await fetchTimeline(pagination: pagination, request: request)
        }
        self.task = task
        let results = try await task.value
        insertAfter(results)
        
        task.cancel()
        self.task = nil
    }
    
    func fetchBeforeFirst(limit: Int?, request: TimelineRequestType) async throws {
        guard task == nil || task?.isCancelled == true else { return }
        let pagination = Pagination(
            sinceID: nil,
            maxID: nil,
            minID: firstID,
            limit: limit ?? 20)
        
        let task = Task {
            try await fetchTimeline(pagination: pagination, request: request)
        }
        self.task = task
        let results = try await task.value
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        insertTop(results)
        
        task.cancel()
        self.task = nil
    }
    
    func refreshTimeline(limit: Int?, request: TimelineRequestType) async throws {
        guard task == nil || task?.isCancelled == true else { return }
        let pagination = Pagination(
            sinceID: nil,
            maxID: nil,
            minID: nil,
            limit: limit ?? 20)
        
        let task = Task {
            try await fetchTimeline(pagination: pagination, request: request)
        }
        self.task = task
        let statuses = try await task.value
        task.cancel()
        self.task = nil
        
        let items: [Item] = statuses.map { .timeline($0.id) }
        var snapshot = NSDiffableDataSourceSnapshot<Section.ID, Item>()
        let section = Section(
            sectionType: .singleRowItem(UUID().uuidString),
            headerType: .none,
            footerType: .none)
        
        let loadMoreSection = Section(
            sectionType: .loadMore("load_more:\(UUID().uuidString)"),
            headerType: .none,
            footerType: .none)
        
        snapshot.appendSections([section.id])
        snapshot.appendItems(items)
        snapshot.appendSections([loadMoreSection.id])
        snapshot.appendItems([.loadMore("load_more_item\(UUID().uuidString)")])
        statusStore.insert(statuses)
        sectionStore.insert([section])
        await dataSource?.apply(snapshot)
        
        firstID = statuses.first?.id
        lastID = statuses.last?.id
    }
    
    func fetchAfter(id: String?, limit: Int?, request: TimelineRequestType) async throws {
        guard task == nil || task?.isCancelled == true else { return }
        let pagination = Pagination(
            sinceID: nil,
            maxID: id,
            minID: nil,
            limit: limit ?? 20)
        
        let task = Task {
            try await fetchTimeline(pagination: pagination, request: request)
        }
        self.task = task
        let results = try await task.value
        insertAfter(results)
        
        task.cancel()
        self.task = nil
    }
    
    func fetchBefore(id: String?, limit: Int?, request: TimelineRequestType) async throws {
        guard task == nil || task?.isCancelled == true else { return }
        let pagination = Pagination(
            sinceID: nil,
            maxID: nil,
            minID: id,
            limit: limit ?? 20)
        
        let task = Task {
            try await fetchTimeline(pagination: pagination, request: request)
        }
        self.task = task
        let results = try await task.value
        insertTop(results)
        
        task.cancel()
        self.task = nil
    }
    
    func fetchTimeline(pagination: Pagination, request: TimelineRequestType) async throws -> [Status] {
        let maxID = pagination.maxID
        let sinceID = pagination.sinceID
        let minID = pagination.minID
        let limit = pagination.limit
        
        return switch request {
        case .public(let local, let remote, let onlyMedia):
            try await ElefantAPI.Timeline.PublicV2(
                local: local,
                remote: remote,
                onlyMedia: onlyMedia,
                maxID: maxID,
                sinceID: sinceID,
                minID: minID,
                limit: limit
            ).request(using: client)
        case .hashtag:
            []
        case .home:
            try await ElefantAPI.Timeline.Home(maxID: maxID, sinceID: sinceID, minID: minID, limit: limit).request(using: client)
        case .link:
            []
        case .list:
            []
        }
    }
    
    func insertTop(_ statuses: [Status]) {
        guard var snapshot = dataSource?.snapshot() else { return }
        
        if let firstStatusSection = snapshot.sectionIdentifiers.first(where: { section in
            if case .singleRowItem(_) = section {
                return true
            }
            return false
        }) {
            if let firstItem = snapshot.itemIdentifiers(inSection: firstStatusSection).first {
                let items: [Item] = statuses.map { .timeline($0.id) }
                snapshot.insertItems(items, beforeItem: firstItem)
                statusStore.insert(statuses)
                dataSource?.apply(snapshot)
            } else {
                let items: [Item] = statuses.map { .timeline($0.id) }
                snapshot.appendItems(items, toSection: firstStatusSection)
                statusStore.insert(statuses)
                dataSource?.apply(snapshot)
            }
        } else {
            let items: [Item] = statuses.map { .timeline($0.id) }
            var snapshot = NSDiffableDataSourceSnapshot<Section.ID, Item>()
            let section = Section(
                sectionType: .singleRowItem(UUID().uuidString),
                headerType: .none,
                footerType: .none)
            snapshot.appendSections([section.id])
            snapshot.appendItems(items)
            statusStore.insert(statuses)
            sectionStore.insert([section])
            dataSource?.apply(snapshot)
        }
        
        firstID = statuses.first?.id ?? firstID
    }
    
    func insertAfter(_ statuses: [Status]) {
        guard var snapshot = dataSource?.snapshot() else { return }
        
        if let lastStatusSection = snapshot.sectionIdentifiers.last(where: { section in
            if case .singleRowItem(_) = section {
                return true
            }
            return false
        }) {
            if let lastItem = snapshot.itemIdentifiers(inSection: lastStatusSection).last {
                let items: [Item] = statuses.map { .timeline($0.id) }
                snapshot.insertItems(items, afterItem: lastItem)
                statusStore.insert(statuses)
                dataSource?.apply(snapshot)
            } else {
                let items: [Item] = statuses.map { .timeline($0.id) }
                snapshot.appendItems(items, toSection: lastStatusSection)
                statusStore.insert(statuses)
                dataSource?.apply(snapshot)
            }
        } else {
            let items: [Item] = statuses.map { .timeline($0.id) }
            var snapshot = NSDiffableDataSourceSnapshot<Section.ID, Item>()
            let section = Section(
                sectionType: .singleRowItem(UUID().uuidString),
                headerType: .none,
                footerType: .none)
            
            let loadMoreSection = Section(
                sectionType: .loadMore("load_more:\(UUID().uuidString)"),
                headerType: .none,
                footerType: .none)
            
            snapshot.appendSections([section.id])
            snapshot.appendItems(items)
            snapshot.appendSections([loadMoreSection.id])
            snapshot.appendItems([.loadMore("load_more_item\(UUID().uuidString)")])
            statusStore.insert(statuses)
            sectionStore.insert([section])
            dataSource?.apply(snapshot)
            
            firstID = statuses.first?.id
        }
        
        lastID = statuses.last?.id
    }
    
    @MainActor func setup(collectionView: UICollectionView) {
        let reactionViewActionHandler: StatusReactionView.ActionHandler = { action in
            switch action {
            case .reply:
                return true
            case .reblog(_):
                return true
            case let .favourite(isFavorite, id):
                return await self.toggleFavorite(isFavorite: isFavorite, id: id)
            case .bookmark(_):
                return true
            case .share:
                return true
            }
        }
        
        let loadMoreCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Item> { cell, indexPath, itemIdentifier in
            cell.contentConfiguration = LoadMoreViewConfiguration()
        }
        
        let mediaCellRegistration = UICollectionView.CellRegistration<StatusCollectionViewCell, Item> { [weak self] cell, indexPath, itemIdentifier in
            
            if case let .timeline(id) = itemIdentifier, let self, let item = statusStore.fetchBy(id: id) {                
                cell.contentConfiguration = MediaStatusViewConfiguration(
                    statusID: item.id,
                    statusThreadViewConfiguration: StatusThreadView.Configuration(
                        imageURL: item.account.avatar,
                        actionHandler: nil),
                    statusProfilePreviewConfiguration: StatusProfilePreview.Configuration(
                        displayName: item.account.displayName,
                        attributedDisplayName: item.account.displayNameWithIcon,
                        userName: item.account.username,
                        description: item.createdAt.formatted(date: .complete, time: .shortened),
                        actionHandler: nil),
                    statusReactionViewConfiguration: StatusReactionView.Configuration(
                        statusID: item.id,
                        reactionData: StatusReactionView.Configuration.Reaction(
                            repliesCount: item.repliesCount,
                            reblogsCount: item.reblogsCount,
                            reblogged: item.reblogged ?? false,
                            favouritesCount: item.favouritesCount,
                            favourited: item.favourited ?? false,
                            bookmarked: item.bookmarked ?? false),
                        actionHandler: reactionViewActionHandler),
                    mediaViewConfiguration: MediaViewConfiguration(
                        mediaAttachments: item.mediaAttachments.map { media in
                            switch media.type {
                            case .image:
                                return .image(ImagePreviewConfiguration(
                                    previewURL: media.previewURL ?? "",
                                    blurhash: media.blurhash ?? "",
                                    aspect: media.meta?.small?.aspect ?? 0))
                            case .video:
                                return .video(VideoPreviewConfiguration(
                                    previewURL: media.previewURL ?? "",
                                    previewImageURL: media.previewURL ?? "",
                                    url: media.url,
                                    blurhash: media.blurhash ?? "",
                                    aspect: media.meta?.small?.aspect ?? 0))
                            case .audio, .gifv, .unknown, ._unknown(_):
                                return nil
                            }
                        }.compactMap { $0 }),
                    content: item.content?.value,
                    statusWatcher: timelineAsyncDataSource)
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section.ID, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .timeline(_):
                collectionView.dequeueConfiguredReusableCell(using: mediaCellRegistration, for: indexPath, item: item)
            case .loadMore(_):
                collectionView.dequeueConfiguredReusableCell(using: loadMoreCellRegistration, for: indexPath, item: item)
            }
        }
    }
    
    func toggleFavorite(isFavorite: Bool, id: String) async -> Bool {
        do {
            let newStatus = try await ElefantAPI.Status.Favorite(id: id).request(using: client)
            await timelineAsyncDataSource.update(status: newStatus)
            statusStore.update(newStatus)
        } catch {
            if let oldStatus = statusStore.fetchBy(id: id) {
                await timelineAsyncDataSource.update(status: oldStatus)
            }
        }
        return true
    }
}

struct DefaultTimelineActionHandler {
}
