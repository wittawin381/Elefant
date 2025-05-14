//
//  PaginationFetcher.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 1/5/2568 BE.
//

import Foundation
import ElefantAPI
import UIKit


//protocol PaginationRequestAdapter {
//    func createRequest() -> any ElefantRequest
//}
//
//struct DefaultPagination {
//    let sinceID: String?
//    let maxID: String?
//    let minID: String?
//    let limit: Int
//}
//
//struct TimelineRequestAdapter: PaginationRequestAdapter {
//    let pagination: DefaultPagination
//    let request: TimelineRequestType
//    
//    func createRequest() -> any ElefantRequest {
//        let maxID = pagination.maxID
//        let sinceID = pagination.sinceID
//        let minID = pagination.minID
//        let limit = pagination.limit
//        
//        return switch request {
//        case .public(let local, let remote, let onlyMedia):
//            ElefantAPI.Timeline.PublicV2(
//                local: local,
//                remote: remote,
//                onlyMedia: onlyMedia,
//                maxID: maxID,
//                sinceID: sinceID,
//                minID: minID,
//                limit: limit
//            )
//        case .hashtag:
//            ElefantAPI.Timeline.PublicV2(
//                local: false,
//                remote: false,
//                onlyMedia: false,
//                maxID: maxID,
//                sinceID: sinceID,
//                minID: minID,
//                limit: limit
//            )
//        case .home:
//            ElefantAPI.Timeline.Home(maxID: maxID, sinceID: sinceID, minID: minID, limit: limit)
//        case .link:
//            ElefantAPI.Timeline.PublicV2(
//                local: false,
//                remote: false,
//                onlyMedia: false,
//                maxID: maxID,
//                sinceID: sinceID,
//                minID: minID,
//                limit: limit
//            )
//        case .list:
//            ElefantAPI.Timeline.PublicV2(
//                local: false,
//                remote: false,
//                onlyMedia: false,
//                maxID: maxID,
//                sinceID: sinceID,
//                minID: minID,
//                limit: limit
//            )
//        }
//    }
//}
//
//
//protocol PaginationDataSourceV3 {
//    func fetchNext()
//    func fetchBefore()
//    func fetchNext(after id: String)
//    func fetchBefore(id: String)
//}
//
//
//class TimelineDataSourceV3: PaginationDataSourceV3 {
//    private var firstID: String?
//    private var lastID: String?
//    
//    func fetchNext() {
//        <#code#>
//    }
//    
//    func fetchBefore() {
//        <#code#>
//    }
//    
//    func fetchNext(after id: String) {
//        <#code#>
//    }
//    
//    func fetchBefore(id: String) {
//        <#code#>
//    }
//}
//
//protocol PaginationCommand {
//    func execute()
//}
