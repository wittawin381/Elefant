//
//  Keychain.swift
//  Elefant
//
//  Created by Wittawin Muangnoi on 4/4/2568 BE.
//

import Foundation
import Security


actor Keychain {
    func set(_ object: Encodable, for key: String) -> Bool {
        guard let encodedData = try? JSONEncoder().encode(object) else { return false }
        
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
                                    kSecValueData as String: encodedData]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func getData(for key: String) -> Data? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnData as String: true]
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        
        return item as? Data
    }
    
    var allData: [String: Data] {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecMatchLimit as String: kSecMatchLimitAll,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return [:] }
        let itemsDict = item as? [[String: Any]]
        
        return itemsDict?.reduce(into: Dictionary<String, Data>()) { result, item in
            if let key = item[kSecAttrAccount as String] as? String, let value = item[kSecValueData as String] as? Data {
                result[key] = value
            }
        } ?? [:]
    }
    
    func removeObject(for key: String) -> Bool {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    func removeAll() {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else { return }
    }
}
