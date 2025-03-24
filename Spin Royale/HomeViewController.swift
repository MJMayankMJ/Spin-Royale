//
//  HomeViewController.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/20/25.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    @IBOutlet weak var labelTotalCoins: UILabel!
    @IBOutlet weak var labelTotalSpins: UILabel!
    
    @IBOutlet weak var buttonCollectCoins: UIButton!
    @IBOutlet weak var buttonCollectSpins: UIButton!
    
    var userStats: UserStats?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch or create the user stats
        userStats = CoreDataManager.shared.fetchUserStats()
        
        // Check if it’s a new day and reset booleans if needed
        checkDailyReward()
        
        // Update UI (labels & button states)
        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Re-fetch in case data changed while on the Slot screen
        userStats = CoreDataManager.shared.fetchUserStats()
        updateUI()
    }

    // MARK: - Daily Reward Logic
    func checkDailyReward() {
        guard let stats = userStats else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastRewardDate = stats.lastDailyRewardDate {
            let lastDay = calendar.startOfDay(for: lastRewardDate)
            
            // If last reward day < today => new day => reset booleans
            if lastDay < today {
                resetDailyBooleans(stats: stats, newDate: today)
            }
        } else {
            // User has never claimed daily rewards => first time setup
            resetDailyBooleans(stats: stats, newDate: today)
        }
    }
    
    private func resetDailyBooleans(stats: UserStats, newDate: Date) {
        stats.collectedCoinsToday = false
        stats.collectedSpinsToday = false
        stats.lastDailyRewardDate = newDate
        CoreDataManager.shared.saveContext()
    }
    
    // MARK: - Collect Buttons
    @IBAction func didTapCollectCoins(_ sender: UIButton) {
        guard let stats = userStats else { return }
        
        // If user hasn't collected coins yet today
        if !stats.collectedCoinsToday {
            // Award 1000 coins
            stats.totalCoins += 1000
            stats.collectedCoinsToday = true
            
            // Save & update
            CoreDataManager.shared.saveContext()
            updateUI()
        } else {
            // alert.... ?
        }
    }
    
    @IBAction func didTapCollectSpins(_ sender: UIButton) {
        guard let stats = userStats else { return }
        
        // If user hasn't collected spins yet today
        if !stats.collectedSpinsToday {
            // Award 10 spins
            stats.dailySpinsRemaining += 10
            stats.collectedSpinsToday = true
            
            // Save & update
            CoreDataManager.shared.saveContext()
            updateUI()
        } else {
            // alert.... ?
        }
    }

    // MARK: - UI Updates
    func updateUI() {
        guard let stats = userStats else { return }
        
        // Update labels
        labelTotalCoins.text = "\(stats.totalCoins)"
        labelTotalSpins.text = "\(stats.dailySpinsRemaining)"
        
        // Update button states
        buttonCollectCoins.isEnabled = !stats.collectedCoinsToday
        buttonCollectSpins.isEnabled = !stats.collectedSpinsToday
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.homeToSlotVC,
           let slotVC = segue.destination as? SlotViewController {
            slotVC.userStats = self.userStats
            // If presenting as a sheet:
            slotVC.presentationController?.delegate = self
        }
    }
}

// MARK: - Refresh if presenting as a sheet
extension HomeViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        userStats = CoreDataManager.shared.fetchUserStats()
        updateUI()
    }
}
