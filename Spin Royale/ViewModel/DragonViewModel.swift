//
//  DragonViewModel.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/26/25.
//

import Foundation

struct DragonCellData {
    var state: EggCellState
}

class DragonViewModel {
    
    let totalRows = 9
    let totalColumns = 3
    
    // Flat array used by the collection view (27 cells).
    var cells: [DragonCellData] = []
    
    // 2D array for full board outcomes
    var board: [[EggCellState]] = []
    
    // Active row index: row 0 is top, row 8 is bottom.
    // Initially no row is active until the game starts.
    var activeRow: Int = -1
    
    var betAmount: Int = 0
    
    var currentMultiplier: Double = 1.0
    var gameOver: Bool = false
    
    // Multipliers: bottom row corresponds to index 0.
    let multipliers: [Double] = [1.1, 1.15, 1.2, 1.25, 1.3, 1.35, 1.4, 1.45, 1.5]
    
    init() {
        // Initialize the flat cells array with .normal state.
        let totalCount = totalRows * totalColumns
        cells = Array(repeating: DragonCellData(state: .normal), count: totalCount)
    }
    
    var numberOfCells: Int {
        return cells.count
    }
    
    func cellData(at index: Int) -> DragonCellData? {
        guard index >= 0 && index < cells.count else { return nil }
        return cells[index]
    }
    
    // MARK: - Game Setup
    
    // Generate the full board (2D array) at the start of the game.
    func generateBoard() {
        board = []
        for _ in 0..<totalRows {
            var row = [EggCellState](repeating: .egg, count: totalColumns)
            // Set one random cell in this row to skull.
            let skullIndex = Int.random(in: 0..<totalColumns)
            row[skullIndex] = .skull
            board.append(row)
            print("DEBUG: Row \(row): skull at column \(skullIndex)") // for testing
        }
    }
    
    func startGame() {
        generateBoard()
        currentMultiplier = 1.0
        gameOver = false
        
        // Reset flat cells array to all normal.
        let totalCount = totalRows * totalColumns
        cells = Array(repeating: DragonCellData(state: .normal), count: totalCount)
        
        // Set active row to bottom row.
        activeRow = totalRows - 1
        highlightRow(activeRow)
    }
    
    // MARK: - Reveal Functions
    
    // Reveal a specific row by copying the outcomes from the board to the flat cells.
    func revealRow(_ row: Int) {
        guard row >= 0 && row < totalRows else { return }
        for col in 0..<totalColumns {
            let index = row * totalColumns + col
            cells[index].state = board[row][col]
        }
        
        // Update multiplier for a successful egg tap.
        let distanceFromBottom = (totalRows - 1) - row  // 0 for bottom row, etc.
        let rowMultiplier = multipliers[distanceFromBottom]
        currentMultiplier *= rowMultiplier
    }
    
    func revealEntireBoard() {
        for row in 0..<totalRows {
            for col in 0..<totalColumns {
                let index = row * totalColumns + col
                cells[index].state = board[row][col]
            }
        }
    }
    
    func highlightRow(_ row: Int) {
        guard row >= 0 && row < totalRows else { return }
        for col in 0..<totalColumns {
            let index = row * totalColumns + col
            cells[index].state = .highlighted
        }
    }
    
    // MARK: - Calculations
    
    func finalAmount(forBet bet: Int) -> Double {
        return Double(bet) * currentMultiplier
    }
    
    func netGain(forBet bet: Int) -> Double {
        return finalAmount(forBet: bet) - Double(bet)
    }
    
    // MARK: - Reset Game
    func resetGame() {
        activeRow = totalRows - 1
        currentMultiplier = 1.0
        gameOver = false
        let totalCount = totalRows * totalColumns
        cells = Array(repeating: DragonCellData(state: .normal), count: totalCount)
        generateBoard()
        highlightRow(activeRow)
    }
}
