//
//  DefaultPaginationController.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 6/4/2568 BE.
//

import Foundation
import UIKit

struct AnyDefaultPaginationRequest<Data>: PaginationRequestData {
    struct Pagination {
        let sinceID: String?
        let maxID: String?
        let minID: String?
        let limit: Int
    }
    let pagination: Pagination
    let data: Data
}

class AnyDefaultPaginationDataController<Data, RequestData, Fetcher>: PaginationDataControllerProtocol
    where Data: Decodable,
          Fetcher: PaginationFetcherV2,
          Fetcher.Result == Data,
          Fetcher.Request == AnyDefaultPaginationRequest<RequestData> {
    
    typealias Request = AnyDefaultPaginationRequest<RequestData>
        
    var items: [Data] = []
    
    private let fetcher: Fetcher
    private let limit: Int
    var firstID: String?
    var lastID: String?
    
    init(fetcher: Fetcher, limit: Int = 20) {
        self.fetcher = fetcher
        self.limit = limit
    }
    
    func fetchMore(limit: Int?, request: RequestData) async throws {
        let pagination = Request.Pagination(
            sinceID: lastID,
            maxID: nil,
            minID: nil,
            limit: limit ?? self.limit)
        let paginationRequestData = Request(
            pagination: pagination,
            data: request)
        let results = try await fetcher.fetch(pagination: paginationRequestData)
        items.append(contentsOf: results)
    }
    
    func fetchBeforeFirst(limit: Int?, request: RequestData) async throws {
        let pagination = Request.Pagination(
            sinceID: nil,
            maxID: nil,
            minID: firstID,
            limit: limit ?? self.limit)
        let paginationRequestData = Request(
            pagination: pagination,
            data: request)
        let results = try await fetcher.fetch(pagination: paginationRequestData)
        items.insert(contentsOf: results, at: 0)
    }
    
    func fetchAfter(id: String?, limit: Int?, request: RequestData) async throws {
        let pagination = Request.Pagination(
            sinceID: nil,
            maxID: id,
            minID: nil,
            limit: limit ?? self.limit)
        let paginationRequestData = Request(
            pagination: pagination,
            data: request)
        let results = try await fetcher.fetch(pagination: paginationRequestData)
        items.append(contentsOf: results)
    }
    
    func fetchBefore(id: String?, limit: Int?, request: RequestData) async throws {
        let pagination = Request.Pagination(
            sinceID: nil,
            maxID: nil,
            minID: id,
            limit: limit ?? self.limit)
        let paginationRequestData = Request(
            pagination: pagination,
            data: request)
        let results = try await fetcher.fetch(pagination: paginationRequestData)
        items.insert(contentsOf: results, at: 0)
    }
}

