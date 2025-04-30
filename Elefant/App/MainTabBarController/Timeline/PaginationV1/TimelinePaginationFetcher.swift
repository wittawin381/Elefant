//
//  TimelinePaginationFetcher.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 6/4/2568 BE.
//

import Foundation
import ElefantEntity
import ElefantAPI

struct TimelinePaginationFetcher: PaginationFetcher {
    private let client: any NetworkClient
    
    enum TimelineType {
        case `public`(local: Bool?, remote: Bool?, onlyMedia: Bool?)
        case hashtag(any: [String]?, all: [String]?, none: [String]?, local: Bool?, remote: Bool?, onlyMedia: Bool?)
        case home
        case link(url: String)
        case list(id: String)
    }
    
    func fetch(pagination: PaginationData<TimelineType>) async throws -> [Status] {
        let maxID = pagination.maxID
        let sinceID = pagination.sinceID
        let minID = pagination.minID
        let limit = pagination.limit
        
        return switch pagination.data {
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
            []
        case .link:
            []
        case .list:
            []
        }
    }
}
