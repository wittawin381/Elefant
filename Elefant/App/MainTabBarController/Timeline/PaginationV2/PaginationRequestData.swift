//
//  PaginationRequestData.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 6/4/2568 BE.
//

import Foundation

protocol PaginationRequestData {
    associatedtype Pagination
    associatedtype Data
    
    var pagination: Pagination { get }
    var data: Data { get }
}
