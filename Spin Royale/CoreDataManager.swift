//
//  CoreDataManager.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/20/25.
//

import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()

    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "SlotMachineModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error loading Core Data: \(error)")
            }
        }
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving Core Data context: \(error)")
            }
        }
    }

    func fetchUserStats() -> UserStats? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserStats> = UserStats.fetchRequest()

        do {
            let results = try context.fetch(fetchRequest)
            if let userStats = results.first {
                // Found existing user stats
                return userStats
            } else {
                // Create new user stats record if none exists
                let newStats = UserStats(context: context)
                newStats.totalCoins = 0
                newStats.dailySpinsRemaining = 0
                newStats.lastDailyRewardDate = nil
                saveContext()
                return newStats
            }
        } catch {
            print("Failed to fetch UserStats: \(error)")
            return nil
        }
    }
}
