//
//  CoinManager.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/28/25.
//

import Foundation
import CoreData

class CoinsManager {
    static let shared = CoinsManager()
    
    var userStats: UserStats? {
        return CoreDataManager.shared.fetchUserStats()
    }
    
    static let coinsDidChangeNotification = Notification.Name("CoinsDidChangeNotification")
    
    func deductCoins(amount: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let stats = userStats else {
            let error = NSError(domain:"CoinsManager", code:1, userInfo: [NSLocalizedDescriptionKey:"No user stats available."])
            completion(.failure(error))
            return
        }
        stats.totalCoins -= amount
        CoreDataManager.shared.saveContext()
        
        // Notify listeners that coins have changed.
        NotificationCenter.default.post(name: CoinsManager.coinsDidChangeNotification, object: nil)
        completion(.success(()))
    }
    
    func addCoins(amount: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let stats = userStats else {
            let error = NSError(domain:"CoinsManager", code:1, userInfo: [NSLocalizedDescriptionKey:"No user stats available."])
            completion(.failure(error))
            return
        }
        stats.totalCoins += amount
        CoreDataManager.shared.saveContext()
        // Notify listeners that coins have changed.
        NotificationCenter.default.post(name: CoinsManager.coinsDidChangeNotification, object: nil)
        completion(.success(()))
    }
}
