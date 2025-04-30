//
//  TimelinePaginationFetcher.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 6/4/2568 BE.
//

import Foundation
import ElefantAPI
import ElefantEntity

protocol PaginationFetcherV2 {
    associatedtype Result
    associatedtype Request: PaginationRequestData
    
    func fetch(pagination: Request) async throws -> [Result]
}

enum TimelineType {
    case `public`(local: Bool?, remote: Bool?, onlyMedia: Bool?)
    case hashtag(any: [String]?, all: [String]?, none: [String]?, local: Bool?, remote: Bool?, onlyMedia: Bool?)
    case home
    case link(url: String)
    case list(id: String)
}

struct TimelinePaginationFetcherV2: PaginationFetcherV2 {
    private let client: any NetworkClient
    
    init(client: any NetworkClient) {
        self.client = client
    }

    func fetch(pagination: AnyDefaultPaginationRequest<TimelineType>) async throws -> [Status] {
        let maxID = pagination.pagination.maxID
        let sinceID = pagination.pagination.sinceID
        let minID = pagination.pagination.minID
        let limit = pagination.pagination.limit

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
