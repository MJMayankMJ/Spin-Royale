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
    
    // Our grid of 27 cells.
    private(set) var cells: [DragonCellData] = []
    
    // Active row: row 0 is top, row 8 is bottom. Initially active is the bottom row.
    var activeRow: Int
    
    // Coin and betting properties.
    var coinBalance: Int = 10000
    var betAmount: Int = 0
    
    // Current multiplier, starting at 1.0.
    var currentMultiplier: Double = 1.0
    
    // Game over flag.
    var gameOver: Bool = false
    
    // Multipliers for each row (bottom row multiplier is multipliers[0]).
    let multipliers: [Double] = [1.1, 1.3, 1.5, 1.7, 1.9, 2.1, 2.3, 2.5, 2.7]
    
    // Outcome for the currently active row (an array of 3 EggCellState, with exactly one skull).
    var currentRowOutcome: [EggCellState]? = nil
    
    init() {
        activeRow = totalRows - 1
        let totalCount = totalRows * totalColumns
        cells = Array(repeating: DragonCellData(state: .normal), count: totalCount)
        // Set the bottom row to highlighted.
        setRow(activeRow, to: .highlighted)
        // Generate the outcome for the active row.
        currentRowOutcome = generateOutcomeForActiveRow()
    }
    
    var numberOfCells: Int {
        return cells.count
    }
    
    func cellData(at index: Int) -> DragonCellData? {
        guard index >= 0 && index < cells.count else { return nil }
        return cells[index]
    }
    
    // Update an entire row's state.
    func setRow(_ row: Int, to state: EggCellState) {
        guard row >= 0 && row < totalRows else { return }
        for col in 0..<totalColumns {
            let index = row * totalColumns + col
            cells[index].state = state
        }
    }
    
    // Generate a random outcome for the active row:
    // Exactly one skull and two eggs.
    func generateOutcomeForActiveRow() -> [EggCellState] {
        var outcome = [EggCellState](repeating: .egg, count: totalColumns)
        let skullIndex = Int.random(in: 0..<totalColumns)
        outcome[skullIndex] = .skull
        return outcome
    }
    
    // Reveal the active row using the predetermined outcome.
    // This method sets the state of all cells in the active row to the values in currentRowOutcome.
    // Then, it moves the active row up (and if any skull was tapped, currentMultiplier should have already been set to 0).
    func revealActiveRow() {
        guard activeRow >= 0 && activeRow < totalRows, let outcome = currentRowOutcome else { return }
        for col in 0..<totalColumns {
            let index = activeRow * totalColumns + col
            cells[index].state = outcome[col]
        }
        // Move the active row up.
        activeRow -= 1
        if activeRow >= 0 {
            setRow(activeRow, to: .highlighted)
            currentRowOutcome = generateOutcomeForActiveRow()
        } else {
            gameOver = true
        }
    }
    
    // Calculate final winning amount: bet * currentMultiplier.
    func finalAmount(forBet bet: Int) -> Double {
        return Double(bet) * currentMultiplier
    }
    
    // Calculate net gain (final amount minus bet).
    func netGain(forBet bet: Int) -> Double {
        return finalAmount(forBet: bet) - Double(bet)
    }
    
    // Reset the game state for a new round.
    func resetGame() {
        activeRow = totalRows - 1
        currentMultiplier = 1.0
        gameOver = false
        let totalCount = totalRows * totalColumns
        cells = Array(repeating: DragonCellData(state: .normal), count: totalCount)
        setRow(activeRow, to: .highlighted)
        currentRowOutcome = generateOutcomeForActiveRow()
    }
}
