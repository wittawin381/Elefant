//
//  Profile.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 4/4/2568 BE.
//

import Foundation
import ElefantEntity

struct Profile: Codable, Sendable, Identifiable {
    let id: String
    let domain: String
    let oauthToken: Token
}

extension Profile {
    func save(to keychain: Keychain) async -> Bool {
        return await keychain.set(self, for: UUID().uuidString)
    }
    
    static func all(from keychain: Keychain) async -> [Profile] {
        let allProfiles = await keychain.allData
        return allProfiles.map {
            try? JSONDecoder().decode(Profile.self, from: $0.value)
        }.compactMap { $0 }
    }
    
    static func removeProfile(with profileID: String , from keychain: Keychain) async -> Bool {
        await keychain.removeObject(for: profileID)
    }
}
