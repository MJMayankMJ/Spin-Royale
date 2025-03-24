//
//  KeychainHelper.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/24/25.
//

import Foundation
import Security

class KeychainHelper {
    
    static let shared = KeychainHelper()
    private init() {}
    
    func save(date: Date, for key: String) {
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)
        if let data = dateString.data(using: .utf8) {
            let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                        kSecAttrAccount as String: key,
                                        kSecValueData as String: data]
            SecItemDelete(query as CFDictionary)
            let status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                print("Error saving to keychain: \(status)")
            }
        }
    }
    
    func retrieveDate(for key: String) -> Date? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecReturnData as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess, let data = item as? Data, let dateString = String(data: data, encoding: .utf8) {
            return ISO8601DateFormatter().date(from: dateString)
        }
        return nil
    }
}
