//
//  LimboViewModel.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 4/28/25.
//

import Foundation

//i am good at math so if you think the logic is not fair ... check again

class LimboViewModel {
    // MARK: – Inputs
    // The multiplier the user wants to cash out at (1.0…100.0).
    var targetMultiplier: Double = 1.0 {
        didSet { targetMultiplier = min(max(1.0, targetMultiplier), 100.0) }
    }
    var betAmount: Double = 0.0 {
        didSet { betAmount = max(0.0, betAmount) }
    }

    // MARK: – Outputs
    // The chance of winning (in percent).  P(win) = 1/target.
    var winPercentage: Double {
        guard targetMultiplier > 0 else { return 0 }
        return (1.0 / targetMultiplier) * 100.0
    }
    // The profit if you win (net gain).
    var profitIfWin: Double {
        return betAmount * (targetMultiplier - 1.0)
    }

    // MARK: – Play result
    private(set) var crashMultiplier: Double = 1.0
    var didWin: Bool { crashMultiplier >= targetMultiplier }

    // Run one round.
    // - Returns: the crash multiplier (1.00…∞, capped at 100.0).
    func playRound(maxMultiplier: Double = 100.0) -> Double {
        // 1) draw uniform u ∈ (0,1)
        let u = Double.random(in: 0..<1)
        // 2) crash = 1/u   ---  P(crash ≥ m) = P(u ≤ 1/m) = 1/m
        let rawCrash = 1.0 / u
        // 3) clamp to max
        crashMultiplier = min(rawCrash, maxMultiplier)
        return crashMultiplier
    }
}
