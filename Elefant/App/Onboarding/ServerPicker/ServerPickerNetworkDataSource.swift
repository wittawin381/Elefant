//
//  ServerPickerNetworkDataSource.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 5/4/2568 BE.
//

import Foundation
import ElefantEntity
import ElefantAPI

@MainActor protocol ServerPickerNetworkDataSource {
    func getServerPickerItems() async throws -> [Server]
}

@MainActor struct DefaultServerPickerNetworkDataSource: ServerPickerNetworkDataSource {
    let client: NetworkClient
    
    func getServerPickerItems() async throws -> [Server] {
        return try await ElefantAPI.Onboarding.ServerList().request(using: client)
    }
}
