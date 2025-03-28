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
    
    // Fetch the current UserStats from Core Data.
    var userStats: UserStats? {
        return CoreDataManager.shared.fetchUserStats()
    }
    
    func deductCoins(amount: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let stats = userStats else {
            let error = NSError(domain:"CoinsManager", code:1, userInfo: [NSLocalizedDescriptionKey:"No user stats available."])
            completion(.failure(error))
            return
        }
        stats.totalCoins -= amount
        CoreDataManager.shared.saveContext()
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
        completion(.success(()))
    }
}
