//
//  StatusSharedDatasource.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 11/4/2568 BE.
//

import Foundation
import ElefantEntity

struct AnyStatusObserver: StatusObserver, Identifiable {
    let id = UUID()
    let statusID: String
    let statusDidUpdate: (ElefantEntity.Status) -> Void
    
    init(statusID: String, statusDidUpdate: @escaping (ElefantEntity.Status) -> Void) {
        self.statusID = statusID
        self.statusDidUpdate = statusDidUpdate
    }
}

protocol StatusWatcher {
    @MainActor func addObserver(_ observer: AnyStatusObserver)
    @MainActor func removeObserver(_ observer: AnyStatusObserver)
}

protocol StatusObserver {
    var statusDidUpdate: (Status) -> Void { get }
}

actor TimelineAsyncDataSource: StatusWatcher {    
    @MainActor var observersValue: [Status.ID: [AnyStatusObserver]] = [:]
    
    func update(status: Status) async {
        await notifyValue(for: status)
    }
    
    @MainActor func notifyValue(for status: Status) {
        if let observer = observersValue[status.id] {
            observer.forEach { $0.statusDidUpdate(status) }
        }
    }
    
    @MainActor func addObserver(_ observer: AnyStatusObserver) {
        if observersValue[observer.statusID] == nil {
            observersValue[observer.statusID] = [observer]
        } else {
            observersValue[observer.statusID]?.append(observer)
        }
    }
    
    @MainActor func removeObserver(_ observer: AnyStatusObserver) {
        observersValue[observer.statusID]?.removeAll { $0.id == observer.id }
    }
}
