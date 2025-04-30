//
//  PaginationDataController.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 6/4/2568 BE.
//

import Foundation

protocol PaginationDataControllerProtocol: AnyObject {
    associatedtype Request: PaginationRequestData
    associatedtype Data
    
    var items: [Data] { get }
    
    func fetchMore(limit: Int?, request: Request.Data) async throws
    func fetchBeforeFirst(limit: Int?, request: Request.Data) async throws
    func fetchAfter(id: String?, limit: Int?, request: Request.Data) async throws
    func fetchBefore(id: String?, limit: Int?, request: Request.Data) async throws
}
