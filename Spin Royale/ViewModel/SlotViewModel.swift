//
//  SlotViewModel.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/24/25.
//

import Foundation

class SlotViewModel {
    
    // MARK: - Properties
    var userStats: UserStats?
    var dataArray: [[Int]] = [[], [], []]
    
    // MARK: - Initialization
    init(userStats: UserStats?) {
        self.userStats = userStats
        loadData()
    }
    
    // MARK: - Data Loading
    func loadData() {
        // populate each of the three slot columns with 101 random indices.....
        for component in 0..<3 {
            dataArray[component] = []
            for _ in 0...100 {
                dataArray[component].append(Int.random(in: 0..<(K.imageArray.count)))
            }
        }
    }
    
    // MARK: - Spin Logic
    func spinSlots() -> [Int] {
        var selectedRows: [Int] = []
        for _ in 0..<3 {
            selectedRows.append(Int.random(in: 3...97))
        }
        return selectedRows
    }
    
    // MARK: - Outcome Calculation
    // Determines the outcome (win/lose) based on the selected rows.
    // - Parameter selectedRows: An array of 3 integers representing the selected row for each slot.
    // - Returns: A tuple containing the result message, the reward value, and a flag indicating if the win sound should play.
    func checkWinOrLose(selectedRows: [Int]) -> (message: String, reward: Int, playWinSound: Bool) {
        guard let stats = userStats else {
            return ("No User Stats", 0, false)
        }
        
        let index0 = dataArray[0][selectedRows[0]]
        let index1 = dataArray[1][selectedRows[1]]
        let index2 = dataArray[2][selectedRows[2]]
        
        // Map the indices to actual emoji strings using constants
        let symbol0 = K.imageArray[index0]
        let symbol1 = K.imageArray[index1]
        let symbol2 = K.imageArray[index2]
        
        var reward = 0
        var message = ""
        var playWinSound = false
        
        if symbol0 == symbol1 && symbol1 == symbol2 {
            // All three symbols match
            if symbol0 == "⓻" {
                reward = 2000
            } else {
                reward = 1000
            }
            message = K.win
            playWinSound = true
        } else if symbol0 == symbol1 || symbol0 == symbol2 || symbol1 == symbol2 {
            // Two symbols match
            reward = 200
            message = "2 In A Row"
        } else {
            // No symbols match
            reward = 50
            message = K.lose
        }
        
        // Update coins
        stats.totalCoins += Int64(reward)
        return (message, reward, playWinSound)
    }
    
    // MARK: - Spin Availability
    func canSpin() -> Bool {
        guard let stats = userStats else { return false }
        return stats.dailySpinsRemaining > 0
    }
    
    func decrementSpin() {
        guard let stats = userStats else { return }
        stats.dailySpinsRemaining -= 1
    }
}
