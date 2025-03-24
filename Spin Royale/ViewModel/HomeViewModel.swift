//
//  HomeViewModel.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/24/25.
//

import Foundation
import CoreData

class HomeViewModel {
    var userStats: UserStats?
    
    // to notify UI updates.
    var onUpdate: (() -> Void)?
    
    // exposed properties for UI binding.
    var totalCoins: Int64 {
        return userStats?.totalCoins ?? 0
    }
    
    var dailySpinsRemaining: Int16 {
        return userStats?.dailySpinsRemaining ?? 0
    }
    
    var canCollectCoins: Bool {
        return !(userStats?.collectedCoinsToday ?? false)
    }
    
    var canCollectSpins: Bool {
        return !(userStats?.collectedSpinsToday ?? false)
    }
    
    init() {
        fetchUserStats()
        checkDailyReward()
    }
    
    func fetchUserStats() {
        self.userStats = CoreDataManager.shared.fetchUserStats()
    }
    
    func checkDailyReward() {
        guard let stats = userStats else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastRewardDate = stats.lastDailyRewardDate {
            let lastDay = calendar.startOfDay(for: lastRewardDate)
            if lastDay < today {
                resetDailyBooleans(stats: stats, newDate: today)
            }
        } else {
            resetDailyBooleans(stats: stats, newDate: today)
        }
    }
    
    private func resetDailyBooleans(stats: UserStats, newDate: Date) {
        stats.collectedCoinsToday = false
        stats.collectedSpinsToday = false
        stats.lastDailyRewardDate = newDate
        CoreDataManager.shared.saveContext()
        onUpdate?()
    }
    
    func collectCoins() {
        guard let stats = userStats, !stats.collectedCoinsToday else { return }
        stats.totalCoins += 1000
        stats.collectedCoinsToday = true
        CoreDataManager.shared.saveContext()
        onUpdate?()
    }
    
    func collectSpins() {
        guard let stats = userStats, !stats.collectedSpinsToday else { return }
        // 10 spins per day....
        stats.dailySpinsRemaining += 10
        stats.collectedSpinsToday = true
        CoreDataManager.shared.saveContext()
        onUpdate?()
    }
}
