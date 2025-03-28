//
//  DragonViewController.swift
//  Spin Royale
//
//  Created by Mayank Jangid on 3/26/25.
//

import UIKit

class DragonViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var betTextField: UITextField!
    @IBOutlet weak var betButton: UIButton!
    
    // MARK: - ViewModel
    let viewModel = DragonViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Register the EggCell nib.
        let nib = UINib(nibName: "EggCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "EggCell")
        
        collectionView.backgroundColor = .clear
        
        // Initially, the button title is "Bet"
        betButton.setTitle("Bet", for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Fade-in animation.
        collectionView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.collectionView.alpha = 1
        }
    }
    
    // MARK: - IBActions
    @IBAction func betButtonTapped(_ sender: UIButton) {
        // If the button title is "Bet", process a new wager.
        if sender.title(for: .normal) == "Bet" {
            // Read the bet value.
            guard let betText = betTextField.text, let betValue = Int(betText) else {
                print("Invalid bet")
                return
            }
            print("Bet pressed: \(betValue). Starting game...")
            viewModel.betAmount = betValue
            
            // Deduct coins immediately.
            CoinsManager.shared.deductCoins(amount: Int64(betValue)) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        // Start the game by generating the board and highlighting the bottom row.
                        self.viewModel.startGame()
                        self.collectionView.reloadData()
                    case .failure(let error):
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        } else {
            // The button says "Cash out" – cash out the game.
            cashOutGame()
        }
    }
    
    /// Cash out the current game.
    func cashOutGame() {
        // Finalize current winnings.
        let bet = viewModel.betAmount
        let finalAmt = viewModel.finalAmount(forBet: bet)
        let netGain = viewModel.netGain(forBet: bet)
        
        // Optionally, reveal the entire board.
        viewModel.revealEntireBoard()
        viewModel.gameOver = true
        
        // Process the cash-out as a game over.
        UIView.transition(with: collectionView,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: {
            self.collectionView.reloadData()
        }, completion: { _ in
            self.showGameOverAlert(isCashOut: true, finalAmt: finalAmt, netGain: netGain)
        })
    }
}

// MARK: - UICollectionViewDataSource
extension DragonViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EggCell", for: indexPath) as! EggCell
        if let cellData = viewModel.cellData(at: indexPath.item) {
            cell.configureCell(state: cellData.state)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension DragonViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Determine tapped cell's row.
        let row = indexPath.item / viewModel.totalColumns
        
        // Process tap only on active (highlighted) row.
        if row == viewModel.activeRow {
            let col = indexPath.item % viewModel.totalColumns
            let outcome = viewModel.board[row][col]
            
            if outcome == .skull {
                // Skull tapped: reveal board, game over.
                viewModel.revealEntireBoard()
                viewModel.currentMultiplier = 0.0
                viewModel.gameOver = true
                
                UIView.transition(with: collectionView,
                                  duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.collectionView.reloadData()
                }, completion: { _ in
                    self.showGameOverAlert(isCashOut: false, finalAmt: self.viewModel.finalAmount(forBet: self.viewModel.betAmount), netGain: self.viewModel.netGain(forBet: self.viewModel.betAmount))
                })
            } else {
                // Egg tapped: reveal this row.
                viewModel.revealRow(row)
                
                UIView.transition(with: collectionView,
                                  duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.collectionView.reloadData()
                }, completion: { _ in
                    // Move active row up.
                    self.viewModel.activeRow -= 1
                    if self.viewModel.activeRow >= 0 {
                        self.viewModel.highlightRow(self.viewModel.activeRow)
                        self.collectionView.reloadData()
                        // Change button title to "Cash out" after the first row is revealed.
                        self.betButton.setTitle("Cash out", for: .normal)
                    } else {
                        // No more rows: game complete.
                        self.viewModel.gameOver = true
                        self.showGameOverAlert(isCashOut: false, finalAmt: self.viewModel.finalAmount(forBet: self.viewModel.betAmount), netGain: self.viewModel.netGain(forBet: self.viewModel.betAmount))
                    }
                })
            }
        }
    }
}

// MARK: - Game Over Alert
extension DragonViewController {
    /// Presents a game-over alert.
    /// - Parameters:
    ///   - isCashOut: True if this ended by cashing out.
    ///   - finalAmt: Final winning amount.
    ///   - netGain: Net gain (finalAmt - bet).
    private func showGameOverAlert(isCashOut: Bool, finalAmt: Double, netGain: Double) {
        let bet = viewModel.betAmount
        let titleText = isCashOut ? "Cashed Out" : "Game Over"
        let message = "Bet: \(bet)\nFinal Amount: \(Int(finalAmt))\nNet Gain: \(Int(netGain))"
        let alert = UIAlertController(title: titleText, message: message, preferredStyle: .alert)
        
        // "OK" resets the game and, if applicable, adds winnings.
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            if self.viewModel.currentMultiplier > 1.0 {
                // Add winnings via CoinsManager.
                CoinsManager.shared.addCoins(amount: Int64(finalAmt)) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success():
                            print("Winnings added successfully.")
                        case .failure(let error):
                            let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(errorAlert, animated: true)
                        }
                    }
                }
            }
            // Reset game state and update button title back to "Bet".
            self.viewModel.resetGame()
            self.betTextField.text = ""
            self.betButton.setTitle("Bet", for: .normal)
            self.collectionView.reloadData()
        }
        
        // "Replay" simply resets the game with the same bet amount.
        let replayAction = UIAlertAction(title: "Replay", style: .default) { _ in
            self.viewModel.resetGame()
            self.betButton.setTitle("Bet", for: .normal)
            self.collectionView.reloadData()
        }
        
        alert.addAction(okAction)
        alert.addAction(replayAction)
        self.present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DragonViewController: UICollectionViewDelegateFlowLayout {
    
    private var cellSpacing: CGFloat { return 8 }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalColumns = CGFloat(viewModel.totalColumns)  // 3 columns
        let totalRows = CGFloat(viewModel.totalRows)        // 9 rows
        
        let totalHorizontalSpacing = cellSpacing * (totalColumns - 1)
        let totalVerticalSpacing = cellSpacing * (totalRows - 1)
        
        let adjustedWidth = collectionView.bounds.width - totalHorizontalSpacing
        let adjustedHeight = collectionView.bounds.height - totalVerticalSpacing
        
        let cellWidth = adjustedWidth / totalColumns
        let cellHeight = adjustedHeight / totalRows
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
}
