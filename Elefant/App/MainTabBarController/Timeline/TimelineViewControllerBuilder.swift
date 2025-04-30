//
//  TimelineViewControllerBuilder.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 6/4/2568 BE.
//

import Foundation
import UIKit
import ElefantEntity
import ElefantAPI

typealias TimelinePaginationData = Status
typealias TimelinePaginationRequest = TimelineType

typealias TimelinePaginationController = AnyDefaultPaginationDataController<TimelinePaginationData, TimelinePaginationRequest, TimelinePaginationFetcherV2>

@MainActor enum TimelineViewControllerBuilder {
    static func build() -> UIViewController {
        // MARK: - TODO
        let client = (UIApplication.shared.delegate as? AppDelegate)!.environment.client
        let dataSource = (UIApplication.shared.delegate as? AppDelegate)!.environment.timelineDataSource
        let dataController = TimelineInternalDataController(timelineAsyncDataSource: dataSource, client: client)
        let viewController = TimelineViewController(dataController: dataController)
        
        return viewController
    }
}
