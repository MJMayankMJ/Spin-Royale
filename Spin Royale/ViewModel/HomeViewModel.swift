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
    
//    func checkDailyReward() {
//        guard let stats = userStats else { return }
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        
//        if let lastRewardDate = stats.lastDailyRewardDate {
//            let lastDay = calendar.startOfDay(for: lastRewardDate)
//            if lastDay < today {
//                resetDailyBooleans(stats: stats, newDate: today)
//            }
//        } else {
//            resetDailyBooleans(stats: stats, newDate: today)
//        }
//    }
    
//    func checkDailyReward() {
//        guard let stats = userStats else { return }
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        
//        // Retrieve last reward date from Keychain
//        let key = "LastRewardClaimed"
//        if let storedDate = KeychainHelper.shared.retrieveDate(for: key) {
//            let storedDay = calendar.startOfDay(for: storedDate)
//            if storedDay == today {
//                // User already claimed reward today – don't reset booleans
//                return
//            }
//        }
//        // Else, reset and allow rewards
//        resetDailyBooleans(stats: stats, newDate: today)
//        // Also save today's date in keychain
//        KeychainHelper.shared.save(date: today, for: key)
//    }

    
//    func checkDailyReward() {
//        guard let stats = userStats else { return }
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        let key = "LastRewardClaimed"
//        
//        if let storedDate = KeychainHelper.shared.retrieveDate(for: key) {
//            let storedDay = calendar.startOfDay(for: storedDate)
//            if storedDay == today {
//                // User already claimed reward today; update core data accordingly.
//                stats.collectedCoinsToday = true
//                stats.collectedSpinsToday = true
//            } else {
//                // It's a new day; reset booleans.
//                resetDailyBooleans(stats: stats, newDate: today)
//                KeychainHelper.shared.save(date: today, for: key)
//            }
//        } else {
//            // No stored date means the reward was never claimed; reset booleans and store today's date.
//            resetDailyBooleans(stats: stats, newDate: today)
//            KeychainHelper.shared.save(date: today, for: key)
//        }
//        onUpdate?()
//    }

    
    private func resetDailyBooleans(stats: UserStats, newDate: Date) {
        stats.collectedCoinsToday = false
        stats.collectedSpinsToday = false
        stats.lastDailyRewardDate = newDate
        CoreDataManager.shared.saveContext()
        onUpdate?()
    }
    
//    func collectCoins() {
//        guard let stats = userStats, !stats.collectedCoinsToday else { return }
//        stats.totalCoins += 1000
//        stats.collectedCoinsToday = true
//        CoreDataManager.shared.saveContext()
//        onUpdate?()
//    }
//    
//    func collectSpins() {
//        guard let stats = userStats, !stats.collectedSpinsToday else { return }
//        // 10 spins per day....
//        stats.dailySpinsRemaining += 10
//        stats.collectedSpinsToday = true
//        CoreDataManager.shared.saveContext()
//        onUpdate?()
//    }
    
    func checkDailyReward() {
        guard let stats = userStats else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let coinsKey = "LastRewardClaimedCoins"
        let spinsKey = "LastRewardClaimedSpins"
        
        // Check for coins reward
        if let storedCoinsDate = KeychainHelper.shared.retrieveDate(for: coinsKey) {
             let storedDay = calendar.startOfDay(for: storedCoinsDate)
             stats.collectedCoinsToday = (storedDay == today)
        } else {
             stats.collectedCoinsToday = false
        }
        
        // Check for spins reward
        if let storedSpinsDate = KeychainHelper.shared.retrieveDate(for: spinsKey) {
             let storedDay = calendar.startOfDay(for: storedSpinsDate)
             stats.collectedSpinsToday = (storedDay == today)
        } else {
             stats.collectedSpinsToday = false
        }
        
        CoreDataManager.shared.saveContext()
        onUpdate?()
    }

    func collectCoins() {
        guard let stats = userStats, !stats.collectedCoinsToday else { return }
        stats.totalCoins += 1000
        stats.collectedCoinsToday = true
        CoreDataManager.shared.saveContext()
        let today = Calendar.current.startOfDay(for: Date())
        KeychainHelper.shared.save(date: today, for: "LastRewardClaimedCoins")
        onUpdate?()
    }

    func collectSpins() {
        guard let stats = userStats, !stats.collectedSpinsToday else { return }
        stats.dailySpinsRemaining += 10
        stats.collectedSpinsToday = true
        CoreDataManager.shared.saveContext()
        let today = Calendar.current.startOfDay(for: Date())
        KeychainHelper.shared.save(date: today, for: "LastRewardClaimedSpins")
        onUpdate?()
    }

}
