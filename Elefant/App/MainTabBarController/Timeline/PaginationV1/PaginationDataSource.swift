//
//  PaginationDataSource.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 6/4/2568 BE.
//

import Foundation

import Foundation
import ElefantEntity
import ElefantAPI


class PaginationDataSource<Fetcher: PaginationFetcher> {
    var items: [Fetcher.Data] = []
    let fetcher: Fetcher
    var lastID: String?
    var firstID: String?
    
    init(fetcher: Fetcher) {
        self.fetcher = fetcher
    }
    
    func fetchMore(limit: Int = 20, request: Fetcher.Request) async throws {
        let pagination = PaginationData(
            sinceID: nil,
            maxID: lastID,
            minID: nil,
            limit: limit,
            data: request)
        let results: [Fetcher.Data] = try await fetcher.fetch(pagination: pagination)
        items.append(contentsOf: results)
    }
    
    func fetchBeforeFirst(limit: Int = 20, request: Fetcher.Request) async throws {
        let pagination = PaginationData(
            sinceID: nil,
            maxID: nil,
            minID: firstID,
            limit: limit,
            data: request)
        let results: [Fetcher.Data] = try await fetcher.fetch(pagination: pagination)
        items.append(contentsOf: results)
    }
    
    func fetchAfter(id: String?, limit: Int = 20, request: Fetcher.Request) async throws {
        let pagination = PaginationData(
            sinceID: nil,
            maxID: id,
            minID: nil,
            limit: limit,
            data: request)
        let results: [Fetcher.Data] = try await fetcher.fetch(pagination: pagination)
        items.append(contentsOf: results)
    }
    
    func fetchBefore(id: String?, limit: Int = 20, request: Fetcher.Request) async throws {
        let pagination = PaginationData(
            sinceID: nil,
            maxID: nil,
            minID: id,
            limit: limit,
            data: request)
        let results: [Fetcher.Data] = try await fetcher.fetch(pagination: pagination)
        items.append(contentsOf: results)
    }
}

struct PaginationData<Data> {
    let sinceID: String?
    let maxID: String?
    let minID: String?
    let limit: Int
    let data: Data
}

protocol PaginationFetcher {
    associatedtype Request
    associatedtype Data: Decodable
    
    func fetch(pagination: PaginationData<Request>) async throws -> [Data]
}
