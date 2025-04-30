//
//  ModelStore.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 8/4/2568 BE.
//

import Foundation

protocol ModelStore {
    associatedtype Model: Identifiable
    
    func insert(_ models: [Model])
    func fetchBy(id: Model.ID) -> Model?
    func update(_ id: Model)
}

final class AnyModelStore<Model: Identifiable>: ModelStore {
    private var models: [Model.ID: Model] = [:]
    
    func fetchBy(id: Model.ID) -> Model? {
        models[id]
    }
    
    func insert(_ models: [Model]) {
        let newModels = models.groupingByUniqueID()
        self.models.merge(newModels, uniquingKeysWith: { current, _ in current })
    }
    
    func update(_ model: Model) {
        models[model.id] = model
    }
}

extension Sequence where Element: Identifiable {
    func groupingByID() -> [Element.ID: [Element]] {
        return Dictionary(grouping: self, by: { $0.id })
    }
    
    func groupingByUniqueID() -> [Element.ID: Element] {
        return Dictionary(uniqueKeysWithValues: self.map { ($0.id, $0) })
    }
}
